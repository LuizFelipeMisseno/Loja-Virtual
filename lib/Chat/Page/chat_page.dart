import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:loja_usuario/Components/app_fonts.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  double? _height;
  List<BoxShadow> standardShadow = [
    const BoxShadow(
      color: Colors.black38,
      blurRadius: 3,
      offset: Offset(3, 4),
    ),
  ];
  final nameController = TextEditingController();
  int index = 0;

  @override
  void initState() {
    _height = 500;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [
      nameTextField(),
      numberTextField(),
    ];
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              height: _height,
              decoration: const BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(80),
                  topRight: Radius.circular(80),
                ),
              ),
              child: IndexedStack(
                index: index,
                children: stack,
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                index == 0 ? index = 1 : index = 0;
                setState(() {
                  _height = Random().nextDouble() * 700;
                });
              },
              child: const Text('mudar tamanho'),
            ),
          ),
        ],
      ),
    );
  }

  nameTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          boxShadow: standardShadow,
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
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          boxShadow: standardShadow,
        ),
        child: TextFormField(
          style: AppFonts.textField,
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
}



    /* Center(
      child: Text('Aguardando contrução...', style: AppFonts.subtitle),
    ); */

    //Código para listar imagens

    /* Center(
      child: FutureBuilder(
          future: FirebaseManagement()
              .getListOfImages('Loja do Luiz', 'Sanduiche do Cheff'),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: ((context, index) {
                  return Image.network(
                    snapshot.data!.elementAt(index),
                  );
                }),
              );
            } else {
              return const Text('Erro');
            }
          }),
    ); */

