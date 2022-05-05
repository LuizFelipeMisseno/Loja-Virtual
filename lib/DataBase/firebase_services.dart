import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_usuario/DataBase/data.dart';
import 'package:loja_usuario/DataBase/user_info.dart';

class FirebaseManagement {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? downloadURL;
  ListResult? listOfImages;
  List<String> urls = [];

  //Adicionar no Firebase
  addService(Service serviceData) async {
    await _db.collection("services").add(
          serviceData.toMap(),
        );
  }

  //Adicionar Informações da conta
  addAccountInfo(AllUserInfo userInfo) async {
    await _db.collection("usuarios").add(
          userInfo.toMap(),
        );
  }

  //Atualizar no Firebase
  updateService(Service serviceData) async {
    await _db.collection("services").doc(serviceData.id).update(
          serviceData.toMap(),
        );
  }

  //Deletar do Firebase
  Future<void> deleteService(String documentId) async {
    await _db.collection("services").doc(documentId).delete();
  }

  //Pegar imagens do Firebase
  Future<List> getListOfImages(storeName, productName) async {
    try {
      await getList(storeName, productName);
      await createListOfURL();
      return urls;
    } catch (e) {
      debugPrint('O erro foi ' + e.toString());
      return [];
    }
  }

  Future<void> createListOfURL() async {
    for (var element in listOfImages!.items) {
      await element.getDownloadURL().then(
            (value) => urls.add(value),
          );
    }
  }

  Future<void> getList(storeName, productName) async {
    listOfImages =
        await FirebaseStorage.instance.ref('$storeName/$productName').listAll();
  }
}
