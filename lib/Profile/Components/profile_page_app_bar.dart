import 'package:flutter/material.dart';
import 'package:loja_usuario/Components/app_color.dart';
import 'package:loja_usuario/Components/app_fonts.dart';

class ProfilePageAppBar extends StatelessWidget {
  const ProfilePageAppBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appBackgroundColor.withOpacity(0.1),
      elevation: 0,
      title: Text(
        'Perfil',
        style: AppFonts.title,
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.edit, color: Colors.black),
        ),
        const SizedBox(width: 10)
      ],
    );
  }
}
