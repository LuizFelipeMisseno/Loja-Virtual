import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_usuario/Components/app_fonts.dart';
import 'package:loja_usuario/DataBase/user_info.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loja_usuario/DataBase/list_of_products.dart';
import 'package:loja_usuario/Home/Components/spotlight_product.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference services = FirebaseFirestore.instance.collection('lojas');
  AllUserInfo? userInfo;
  List<Produto>? itens;
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
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      clipBehavior: Clip.none,
      //margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Espaçamento da AppBar
            SizedBox(
              height: AppBar().preferredSize.height + 40,
            ),
            //Cabeçalho
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: header(),
            ),
            //Espaçamento
            const SizedBox(
              height: 15,
            ),
            //Slider de opções
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: chooseProduct(),
            ),
            //Cards de Produto
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: spotlight(screenHeight),
            ),
            //Espaçamento
            const SizedBox(height: 10),
            //Mais próximos de você
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: nearest(),
            ),
            //Espaçamento BottomBar
            const SizedBox(height: 90)
          ],
        ),
      ),
    );
  }

  header() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
                    return Text(userInfo?.name ?? '...',
                        style: AppFonts.subtitle);
                }
              },
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'O que sua fome pede hoje?',
              style: AppFonts.description,
            ),
          ],
        ),
      ],
    );
  }

  //Slider de opções
  chooseProduct() {
    return SizedBox(
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 20);
        },
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () async {},
            child: Column(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 180, 180, 180),
                        blurRadius: 6,
                        offset: Offset(0, 5),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      options.elementAt(index)['icon'],
                      size: 40.0,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(options.elementAt(index)['titulo'],
                    style: AppFonts.littleOption),
              ],
            ),
          );
        },
      ),
    );
  }

  //Destaques do dia
  spotlight(screenHeight) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Destaques do Dia', style: AppFonts.subtitle),
            ],
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder(
          stream: services.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return createList(snapshot).isNotEmpty
                  ? CarouselSlider.builder(
                      options: CarouselOptions(
                        aspectRatio: 13 / 8,
                      ),
                      itemCount: createList(snapshot).length,
                      itemBuilder: (context, index, i) {
                        return SpotlightProductCard(
                          createList(snapshot).elementAt(index),
                        );
                      },
                    )
                  : SizedBox(
                      height: screenHeight,
                      child: Center(
                        child: Text('Nenhum produto disponível',
                            style: AppFonts.description),
                      ),
                    );
            }
            return const Align(
              child: CircularProgressIndicator(),
              alignment: Alignment.center,
            );
          },
        ),
      ],
    );
  }

  //Mais próximos de você
  nearest() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Mais próximos de você', style: AppFonts.subtitle),
          ],
        ),
      ],
    );
  }

  createList(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    List listaInicial = [];
    List listaFinal = [];
    for (var element in snapshot.data!.docs) {
      listaInicial.add(element['produtos']);
    }
    for (var element in listaInicial) {
      for (var e in element) {
        listaFinal.add(e);
      }
    }
    return listaFinal;
  }
}

List options = [
  {
    'titulo': 'Sanduíches',
    'icon': LineIcons.hamburger,
  },
  {
    'titulo': 'Pizzas',
    'icon': LineIcons.pizzaSlice,
  },
  {
    'titulo': 'Sorvetes',
    'icon': LineIcons.iceCream,
  },
  {
    'titulo': 'Bebidas',
    'icon': LineIcons.beer,
  },
];
