import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loja_usuario/Authentication/Services/auth_services.dart';
import 'package:loja_usuario/Authentication/Services/google_auth_services.dart';
import 'package:loja_usuario/Components/app_color.dart';
import 'package:loja_usuario/Components/app_fonts.dart';
import 'package:loja_usuario/DataBase/firebase_services.dart';
import 'package:loja_usuario/DataBase/user_info.dart';
import 'package:loja_usuario/Login/Components/states_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final addressController = TextEditingController();
  final cepController = TextEditingController();
  final setorController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final numberFormat = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  final cepFormat = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  bool isLogin = true;
  bool finishRegistration = false;
  bool loading = false;
  bool googleLoading = false;
  bool _passwordVisible = true;
  late String title;
  late String headerInstruction;
  late String actionButton;
  late RichText toggleButton;
  late String headerPhrase;
  User? user = FirebaseAuth.instance.currentUser;
  GoogleSignInAccount? _user;
  String? dropdownValue;

  @override
  void initState() {
    super.initState();
    setFormAction(true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  setFormAction(bool action) {
    setState(() {
      isLogin = action;
      if (isLogin) {
        title = 'Bem vindo';
        headerPhrase = '';
        actionButton = 'Entrar';
        toggleButton = RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontStyle: FontStyle.normal,
              fontSize: 14,
            ),
            children: const <TextSpan>[
              TextSpan(text: 'Ainda não tem conta? '),
              TextSpan(
                text: 'Crie uma agora.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        );
        headerInstruction = 'Entre com sua conta';
      } else {
        title = 'Bem vindo';
        headerPhrase = 'Novo por aqui? É um prazer recebê-lo';
        actionButton = 'Criar conta';
        toggleButton = RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontStyle: FontStyle.normal,
              fontSize: 14,
            ),
            children: const <TextSpan>[
              TextSpan(
                text: 'Voltar para o Login',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        );
        headerInstruction = 'Informações para a conta';
      }
    });
  }

  firebaseLogin() async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().login(
          emailController.text.removeAllWhitespace, passwordController.text);
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    }
  }

  chooseAccount() async {
    setState(() => googleLoading = true);
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    try {
      await provider.chooseAccount().then(
            (firstAccess) => setState(() {
              if (firstAccess.first) {
                context.read<GoogleSignInProvider>().googleLogin();
              } else {
                _user = firstAccess.last;
                finishRegistration = true;
              }
            }),
          );
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    }
  }

  register() async {
    setState(() => loading = true);

    try {
      //Checa se cadastra email ou conta do google
      if (emailController.text != '') {
        //Cadastra email
        await context
            .read<AuthService>()
            .register(emailController.text, passwordController.text);
        AllUserInfo userInfo = AllUserInfo(
          uid: _user?.email ?? emailController.text,
          name: nameController.text,
          telephone: numberController.text,
          localization: Localization(
            cep: cepController.text,
            cidade: cityController.text,
            endereco: addressController.text,
            estado: dropdownValue!,
            setor: setorController.text,
          ),
        );

        FirebaseManagement().addAccountInfo(userInfo);
      } else {
        //Cadastra conta do google
        await context.read<GoogleSignInProvider>().googleLogin();
        AllUserInfo userInfo = AllUserInfo(
          uid: _user!.email,
          name: nameController.text,
          telephone: numberController.text,
          localization: Localization(
            cep: cepController.text,
            cidade: cityController.text,
            endereco: addressController.text,
            estado: dropdownValue!,
            setor: setorController.text,
          ),
        );

        FirebaseManagement().addAccountInfo(userInfo);
      }
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    }
  }

  buscaCep() async {
    String cep = cepController.text;
    String url =
        'https://viacep.com.br/ws/${cep.replaceAll(RegExp('-'), '')}/json/';
    http.Response response;
    response = await http.get(Uri.parse(url));
    Map<String, dynamic>? address = json.decode(response.body);
    if (address?['logradouro'] != null && address?['bairro'] != null) {
      addressController.text = address?['logradouro'];
      setorController.text = address?['bairro'];
      cityController.text = address?['localidade'];
      setState(() {
        dropdownValue = address?['uf'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        if (isLogin == false) {
          setState(() {
            isLogin = true;
          });
          return false;
        }
        {
          return true;
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: isLogin
            ? finishRegistration
                ? secondRegisterPage(screenHeight)
                : loginPage(screenHeight)
            : finishRegistration
                ? secondRegisterPage(screenHeight)
                : firstRegisterPage(screenHeight),
      ),
    );
  }

  //------Páginas de login------//

  loginPage(screenHeight) {
    return Scaffold(
      body: SingleChildScrollView(
        //physics: const NeverScrollableScrollPhysics(),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              loginHeader(screenHeight),
              Container(
                height: screenHeight * .5,
                decoration: const BoxDecoration(
                  color: AppColors.highlightColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                    topRight: Radius.circular(80),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Instrução
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: initialMessage(),
                        ),
                      ),
                      Column(
                        children: [
                          //TextField do email
                          emailTextField(),
                          //TextField da senha
                          passwordTextField(),
                          //Botão de login
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Row(
                          children: [
                            googleLoginButton(),
                            const SizedBox(width: 20),
                            facebookLoginButton(),
                            Expanded(child: Container()),
                            loginButton(),
                          ],
                        ),
                      ),
                      //Botão para cadastro ou voltar para login
                      Flexible(child: changeToRegistration()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  firstRegisterPage(screenHeight) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                firstRegisterHeader(screenHeight),
                Container(
                  height: (screenHeight) * 0.70,
                  decoration: const BoxDecoration(
                    color: AppColors.highlightColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(80),
                      topRight: Radius.circular(80),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Instrução
                        initialMessage(),
                        Column(
                          children: [
                            //TextField do email
                            emailTextField(),
                            //TextField da senha
                            passwordTextField(),
                            //Confirmar senha
                            confirmPasswordTextField(),
                            //Botão de criar conta
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 40, 30, 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //Botão de login
                                  loginButton(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        //Voltar para login
                        changeToRegistration(),
                        //Espaçamento
                        Get.bottomBarHeight == 0
                            ? const SizedBox(height: 10)
                            : const SizedBox()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  secondRegisterPage(screenHeight) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              secondRegisterHeader(screenHeight),
              Container(
                constraints: BoxConstraints(
                  minHeight: screenHeight * 0.80,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.highlightColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                    topRight: Radius.circular(80),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Textfield do nome
                      nameTextField(),
                      //Textfield do telefone
                      numberTextField(),
                      //TextFields CEP e setor
                      Row(
                        children: [
                          Flexible(
                            child: cepTextField(),
                          ),
                          Expanded(
                            child: stateTextField(),
                          )
                        ],
                      ),
                      //Textfield da cidade
                      cityTextField(),
                      //Texfield do setor
                      setorTextField(),
                      //TextField da rua
                      addressTextField(),
                      //Botão de login
                      Row(
                        children: [
                          Expanded(child: Container()),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: finishRegistrationButon(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //------Cabeçalhos------//

  firstRegisterHeader(screenHeight) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SizedBox(
        height: screenHeight * 0.20,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                fontSize: 36,
              ),
            ),
            Text(
              headerPhrase,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  secondRegisterHeader(screenHeight) {
    return SizedBox(
      height: screenHeight * 0.30,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'É bom ter você aqui',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                fontSize: 30,
              ),
            ),
            Text(
              'Precisamos só de mais algumas informações',
              maxLines: 2,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  loginHeader(screenHeight) {
    return SizedBox(
      height: screenHeight * 0.50,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                fontSize: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //------Itens do formulário------//

  initialMessage() {
    return Text(
      headerInstruction,
      style: AppFonts.mainDescriptions,
    );
  }

  nameTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(3, 4),
            ),
          ],
        ),
        child: TextFormField(
          style: AppFonts.textField,
          controller: nameController,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(30, 20, 24, 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            labelText: 'Nome',
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Informe seu nome';
            }
            return null;
          },
        ),
      ),
    );
  }

  numberTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(3, 4),
            ),
          ],
        ),
        child: TextFormField(
          style: AppFonts.textField,
          inputFormatters: [numberFormat],
          controller: numberController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(30, 20, 24, 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            labelText: 'Telefone',
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Informe seu telefone';
            }
            return null;
          },
        ),
      ),
    );
  }

  cepTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(3, 4),
            ),
          ],
        ),
        child: TextFormField(
          style: AppFonts.textField,
          inputFormatters: [cepFormat],
          controller: cepController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(30, 20, 24, 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            labelText: 'CEP',
          ),
          onChanged: (value) {
            if (value.length == 9) {
              buscaCep();
            }
            {
              addressController.text = '';
              setorController.text = '';
              cityController.text = '';
              setState(() {
                dropdownValue = null;
              });
            }
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Informe seu CEP';
            }
            return null;
          },
        ),
      ),
    );
  }

  stateTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(3, 4),
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(60)),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 5, 10, 10),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              enabledBorder: InputBorder.none,
            ),
            validator: (value) {
              if (value == null) {
                return 'Selecione um estado';
              }
              return null;
            },
            hint: Text('Estado', style: AppFonts.textField),
            value: dropdownValue,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            elevation: 16,
            style: AppFonts.textField,
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            },
            items:
                brazilianStates.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: AppFonts.textField),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  cityTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(3, 4),
            ),
          ],
        ),
        child: TextFormField(
          style: AppFonts.textField,
          controller: cityController,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(30, 20, 24, 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            labelText: 'Cidade',
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Informe sua Cidade';
            }
            return null;
          },
        ),
      ),
    );
  }

  setorTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(3, 4),
            ),
          ],
        ),
        child: TextFormField(
          style: AppFonts.textField,
          controller: setorController,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(30, 20, 24, 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            labelText: 'Setor',
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Informe seu Setor';
            }
            return null;
          },
        ),
      ),
    );
  }

  addressTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(3, 4),
            ),
          ],
        ),
        child: TextFormField(
          style: AppFonts.textField,
          controller: addressController,
          maxLines: 3,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(30, 20, 24, 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            labelText: 'Endereço',
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Informe seu endereço';
            }
            return null;
          },
        ),
      ),
    );
  }

  emailTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(3, 4),
            ),
          ],
        ),
        child: TextFormField(
          style: AppFonts.textField,
          controller: emailController,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(30, 20, 24, 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            labelText: 'Email',
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Informe o email corretamente';
            }
            return null;
          },
        ),
      ),
    );
  }

  passwordTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(3, 4),
            ),
          ],
        ),
        child: TextFormField(
          style: AppFonts.textField,
          controller: passwordController,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(30, 20, 24, 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            labelText: 'Senha',
            suffixIcon: isLogin
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: IconButton(
                      icon: Icon(
                        // Based on passwordVisible state choose the icon
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        // Update the state i.e. toogle the state of passwordVisible variable
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  )
                : null,
          ),
          obscureText: _passwordVisible,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Informe sua senha!';
            } else if (value.length < 6) {
              return 'Sua senha deve ter no mínimo 6 caracteres';
            }
            return null;
          },
        ),
      ),
    );
  }

  confirmPasswordTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(3, 4),
            ),
          ],
        ),
        child: TextFormField(
          style: AppFonts.textField,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(30, 20, 24, 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            labelText: 'Confirme sua senha',
          ),
          obscureText: true,
          validator: (value) {
            if (value != passwordController.text) {
              return 'As senhas não correspondem';
            }
            return null;
          },
        ),
      ),
    );
  }

  googleLoginButton() {
    return GestureDetector(
      onTap: () {
        chooseAccount();
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(9),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(3, 4),
            ),
          ],
        ),
        child: googleLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset('assets/images/google_logo.png'),
              ),
      ),
    );
  }

  facebookLoginButton() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 3,
            offset: Offset(3, 4),
          ),
        ],
        color: Colors.blue.shade800,
        borderRadius: const BorderRadius.all(
          Radius.circular(9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset('assets/images/facebook_white_logo.png'),
      ),
    );
  }

  loginButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.contrastColor,
        border: Border.all(
          color: Colors.black,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 3,
            offset: Offset(3, 4),
          ),
        ],
        borderRadius: const BorderRadius.all(
          Radius.circular(100),
        ),
      ),
      child: TextButton(
        style: ButtonStyle(
          maximumSize: MaterialStateProperty.all(
            const Size(170, 50),
          ),
          minimumSize: MaterialStateProperty.all(
            const Size(30, 15),
          ),
        ),
        onPressed: () {
          if (formKey.currentState!.validate()) {
            if (isLogin) {
              firebaseLogin();
            } else {
              setState(() {
                finishRegistration = true;
              });
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: (loading)
              ? [
                  const Flexible(
                    child: CircularProgressIndicator(
                      color: Colors.yellow,
                    ),
                  ),
                ]
              : [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                    child: Text(
                      actionButton,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.white)
                ],
        ),
      ),
    );
  }

  finishRegistrationButon() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Container(
        //constraints: const BoxConstraints(minWidth: 50, maxWidth: 200),
        decoration: BoxDecoration(
          color: AppColors.contrastColor,
          border: Border.all(
            color: Colors.black,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(3, 4),
            ),
          ],
          borderRadius: const BorderRadius.all(
            Radius.circular(100),
          ),
        ),
        child: TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              register();
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (loading)
                ? [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: Colors.yellow,
                      ),
                    ),
                  ]
                : [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: Text(
                        'Ir às compras',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white)
                  ],
          ),
        ),
      ),
    );
  }

  changeToRegistration() {
    return TextButton(
      onPressed: () {
        setFormAction(!isLogin);
        emailController.text = '';
        passwordController.text = '';
      },
      child: toggleButton,
    );
  }
}
