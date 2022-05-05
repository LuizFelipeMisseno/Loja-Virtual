import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loja_usuario/Components/app_color.dart';
import 'package:loja_usuario/Components/app_fonts.dart';
import 'package:loja_usuario/DataBase/firebase_services.dart';
import 'package:loja_usuario/DataBase/list_of_products.dart';

class SpotlightProductCard extends StatefulWidget {
  final Map snapshot;

  const SpotlightProductCard(this.snapshot, {Key? key}) : super(key: key);

  @override
  State<SpotlightProductCard> createState() => _SpotlightProductCardState();
}

class _SpotlightProductCardState extends State<SpotlightProductCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Variáveis que serão usadas

    final currency = NumberFormat("R\$ #,##0.00", "pt_BR");
    Produto produto = Produto(
      classification: widget.snapshot['classificacao'] ?? '',
      name: widget.snapshot['nome'] ?? '',
      description: widget.snapshot['descricao'] ?? '',
      spotlight: widget.snapshot['destaque'] ?? '',
      price: widget.snapshot['preco'] ?? 0.0,
      type: widget.snapshot['tipo'] ?? '',
      photos: widget.snapshot['fotos'] ?? [],
      storeName: widget.snapshot['empresa'] ?? '',
    );

    //Criar espaçamento no final da lista apenas

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
            children: [
              //Imagens
              Stack(
                children: [
                  FutureBuilder(
                    future: FirebaseManagement()
                        .getListOfImages(produto.storeName, produto.name),
                    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Algo deu errado');
                      }
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data!.isNotEmpty) {
                        return Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                                offset: Offset(2, 1),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: Image.network(
                              snapshot.data!.last.toString(),
                              fit: BoxFit.cover,
                              height: constraints.maxHeight * 0.70,
                              width: constraints.maxWidth,
                            ),
                          ),
                        );
                      }
                      return Container(
                        height: constraints.maxHeight * 0.70,
                        width: constraints.maxWidth,
                        decoration: const BoxDecoration(
                          color: AppColors.lightColor,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5,
                              offset: Offset(2, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.photo_size_select_actual_outlined,
                          size: 80,
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.highlightColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(80),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                          child: Text(
                            currency.format(produto.price),
                            style: AppFonts.productTitle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              //Nome do produto
              Text(produto.name, style: AppFonts.productTitle),
              Text(
                produto.storeName,
                style: AppFonts.normal,
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
