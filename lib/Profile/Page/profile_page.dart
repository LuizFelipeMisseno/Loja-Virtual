import 'package:firebase_auth/firebase_auth.dart';
import 'package:loja_usuario/Authentication/Services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loja_usuario/Authentication/Services/google_auth_services.dart';
import 'package:loja_usuario/Components/app_fonts.dart';
import 'package:loja_usuario/DataBase/user_info.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AllUserInfo? userInfo;

  @override
  void initState() {
    super.initState();
    _getFirebaseUser();
  }

  _getFirebaseUser() async {
    userInfo = await GetFirestoreUserInfo().find();
  }

  @override
  Widget build(BuildContext context) {
    //Váriaveis a serem usadas
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //Espaçamento da AppBar
            SizedBox(
              height: AppBar().preferredSize.height + 40,
            ),
            //Foto de perfil e nome
            firstRow(),
            //Espaçamento
            const SizedBox(height: 40),
            //Configurações
            secondRow(),
            //Lista de Opções
            thirdRow(context),
            //Espaçamento
            const SizedBox(height: 40),
            //Créditos
            fourthRow(),
            //Espaçamento BottomBar
            const SizedBox(height: 100)
          ],
        ),
      ),
    );
  }

  //Itens para construção da página
  firstRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.yellow,
              minRadius: 50,
              maxRadius: 70,
            ),
            const SizedBox(
              height: 10,
            ),
            //Nome
            Row(
              children: [
                Text(
                  'Olá, ',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                  ),
                ),
                FutureBuilder(
                  future: GetFirestoreUserInfo().find(),
                  builder: (BuildContext context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return const Text('');
                      case ConnectionState.waiting:
                        return const Text('...');
                      case ConnectionState.active:
                        return const Text('...');
                      case ConnectionState.done:
                        return Text(
                          userInfo?.name ?? '...',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        );
                    }
                  },
                )
              ],
            )
          ],
        ),
      ],
    );
  }

  secondRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Text(
              'Configurações',
              style: AppFonts.title,
            ),
          ),
        ),
      ],
    );
  }

  thirdRow(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 350,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        children: optionsList(context),
      ),
    );
  }

  fourthRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Criado por Luiz Felipe',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

List<Widget> optionsList(BuildContext context) {
  TextStyle? textStyle = AppFonts.normal;
  return <Widget>[
    //Serviços marcados
    TextButton(
      onPressed: () {},
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Serviços marcados',
          style: textStyle,
        ),
      ),
    ),
    //Configurar calendário
    TextButton(
      onPressed: () {},
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Configurar calendário',
          style: textStyle,
        ),
      ),
    ),
    //Gráficos
    TextButton(
      onPressed: () {},
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Gráficos',
          style: textStyle,
        ),
      ),
    ),
    //Notificações
    TextButton(
      onPressed: () {},
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Notificações',
          style: textStyle,
        ),
      ),
    ),
    //Controle de estoque
    TextButton(
      onPressed: () {},
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Controler de estoque',
          style: textStyle,
        ),
      ),
    ),
    //Gerar orçamento
    TextButton(
      onPressed: () {},
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Gerar orçamento',
          style: textStyle,
        ),
      ),
    ),
    //Sair da conta
    TextButton(
      onPressed: () {
        var user = context.read<AuthService>().user;
        if (user!.providerData.first.providerId == 'google.com') {
          context.read<GoogleSignInProvider>().googleLogout();
        } else if (user.providerData.first.providerId == 'password') {
          context.read<AuthService>().logout();
        }
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Sair da conta',
          style: textStyle,
        ),
      ),
    ),
  ];
}
