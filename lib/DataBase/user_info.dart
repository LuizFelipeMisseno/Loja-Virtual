import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllUserInfo {
  AllUserInfo({
    required this.uid,
    required this.name,
    required this.telephone,
    required this.localization,
    this.card,
    this.history,
    this.bag,
  });

  String uid;
  String name;
  String telephone;
  Localization? localization;
  Cartao? card;
  List? history;
  List? bag;

  //passar dados para mapa
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': name,
      'telefone': telephone,
      'localizacao': localization!.toJson(),
      'cartao': card?.toJson(),
      'historico': history,
      'sacola': bag,
    };
  }
}

class GetFirestoreUserInfo {
  CollectionReference reference =
      FirebaseFirestore.instance.collection('usuarios');

  Future<AllUserInfo> find() async {
    var result = await reference.get();
    User? user = FirebaseAuth.instance.currentUser;

    return result.docs
        .map((e) => AllUserInfo(
              uid: e.data().toString().contains('uid') ? e.get('uid') : '',
              name: e.data().toString().contains('nome') ? e.get('nome') : '',
              telephone: e.data().toString().contains('telefone')
                  ? e.get('telefone')
                  : '',
              localization: e.data().toString().contains('localizacao')
                  ? Localization(
                      cep: e.get('localizacao')['cep'],
                      cidade: e.get('localizacao')['cidade'],
                      endereco: e.get('localizacao')['endereco'],
                      estado: e.get('localizacao')['estado'],
                      setor: e.get('localizacao')['setor'],
                    )
                  : null,
              card: e.data().toString().contains('cartao') &&
                      e.get('cartao') != null
                  ? Cartao(
                      cvv: e.get('cartao')['cvv'],
                      nome: e.get('cartao')['nome'],
                      numero: e.get('cartao')['numero'],
                      validade: e.get('cartao')['validade'],
                    )
                  : null,
              history: e.data().toString().contains('historico') &&
                      e.get('historico') != null
                  ? _firebaseProductsHistory(e.get('historico'))
                  : null,
              bag: e.data().toString().contains('sacola') &&
                      e.get('sacola') != null
                  ? _firebaseProductsBag(e.get('sacola'))
                  : null,
            ))
        .singleWhere((element) => element.uid == user!.email);
  }
}

class Localization {
  String cep;
  String cidade;
  String endereco;
  String estado;
  String setor;
  Localization(
      {required this.cep,
      required this.cidade,
      required this.endereco,
      required this.estado,
      required this.setor});

  factory Localization.fromJson(Map<dynamic, dynamic> json) => Localization(
        cep: json['cep'],
        cidade: json['cidade'],
        endereco: json['endereco'],
        estado: json['estado'],
        setor: json['setor'],
      );

  Map<String, dynamic> toJson() => {
        'cep': cep,
        'cidade': cidade,
        'endereco': endereco,
        'estado': estado,
        'setor': setor,
      };
}

class Cartao {
  String? cvv;
  String? nome;
  String? numero;
  String? validade;
  Cartao({this.cvv, this.nome, this.numero, this.validade});

  factory Cartao.fromJson(Map<dynamic, dynamic> json) => Cartao(
        cvv: json['cvv'],
        nome: json['nome'],
        numero: json['numero'],
        validade: json['validade'],
      );

  Map<String, dynamic> toJson() => {
        'cvv': cvv,
        'nome': nome,
        'numero': numero,
        'validade': validade,
      };
}

class ProdutoHistorico {
  String? loja;
  String? pedido;
  double? preco;
  Timestamp? dia;
  ProdutoHistorico({this.loja, this.pedido, this.preco, this.dia});

  factory ProdutoHistorico.fromJson(Map<dynamic, dynamic> json) =>
      ProdutoHistorico(
        loja: json['loja'],
        pedido: json['pedido'],
        preco: json['preco'],
        dia: json['validade'],
      );

  Map<String, dynamic> toJson() => {
        'loja': loja,
        'pedido': pedido,
        'preco': preco,
        'dia': dia,
      };
}

class ProdutoSacola {
  String? loja;
  String? pedido;
  double? preco;
  int? quantidade;
  ProdutoSacola({this.loja, this.pedido, this.preco, this.quantidade});

  factory ProdutoSacola.fromJson(Map<dynamic, dynamic> json) => ProdutoSacola(
        loja: json['loja'],
        pedido: json['pedido'],
        preco: json['preco'],
        quantidade: json['validade'],
      );

  Map<String, dynamic> toJson() => {
        'loja': loja,
        'pedido': pedido,
        'preco': preco,
        'quantidade': quantidade,
      };
}

_firebaseProductsHistory(List<dynamic> list) {
  List<ProdutoHistorico> produtoHistorico = [];
  List<dynamic> historyMap = list;
  for (var element in historyMap) {
    produtoHistorico.add(ProdutoHistorico(
      loja: element['loja'],
      pedido: element['pedido'],
      preco: element['preco'],
      dia: element['dia'],
    ));
  }
  return produtoHistorico;
}

_firebaseProductsBag(List<dynamic> list) {
  List<ProdutoSacola> produtoSacola = [];
  List<dynamic> historyMap = list;
  for (var element in historyMap) {
    produtoSacola.add(ProdutoSacola(
      loja: element['loja'],
      pedido: element['pedido'],
      preco: element['preco'],
      quantidade: element['quantidade'],
    ));
  }
  return produtoSacola;
}
