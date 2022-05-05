import 'package:cloud_firestore/cloud_firestore.dart';

class Produto {
  Produto({
    required this.classification,
    required this.name,
    required this.description,
    required this.spotlight,
    required this.price,
    this.photos,
    required this.type,
    required this.storeName,
  });

  String classification;
  String name;
  String description;
  String spotlight;
  double price;
  dynamic photos;
  String type;
  String storeName;

  //passar dados para mapa
  Map<String, dynamic> toMap() {
    return {
      'classification': classification,
      'nome': name,
      'descricao': description,
      'destaque': spotlight,
      'preco': price,
      'fotos': photos,
      'tipo': type,
      'empresa': storeName,
    };
  }
}

class GetFirestoreProductsList {
  CollectionReference reference =
      FirebaseFirestore.instance.collection('lojas');

  Future<List<Produto>> get() async {
    var result = await reference.get();
    List<Produto> itens = [];

    result.docs.map((e) => e).forEach((element) {
      itens.add(Produto(
        name: element['produtos'],
        type: element['tipo'],
        classification: element['classificacao'],
        description: element['descricao'],
        price: element['preco'],
        spotlight: element['destaque'],
        storeName: element['empresa'],
      ));
    });

    return itens;
  }
}
