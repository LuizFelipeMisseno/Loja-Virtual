import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loja_usuario/Components/app_color.dart';
import 'package:loja_usuario/Components/app_fonts.dart';

class HomePageAppBar extends StatelessWidget {
  const HomePageAppBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      //Efeito de embaçamento
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.0,
          sigmaY: 10.0,
        ),
        child: Opacity(
          //Mudar opacidade da barra de navegação
          opacity: 0.8,
          child: AppBar(
            backgroundColor: AppColors.appBackgroundColor.withOpacity(0.1),
            elevation: 0,
            title: Text(
              'Início',
              style: AppFonts.title,
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_bag, color: Colors.black),
              ),
              const SizedBox(width: 10)
            ],
          ),
        ),
      ),
    );
  }
}
