//tes
import 'package:flutter/material.dart';
import 'package:loja_usuario/Components/app_color.dart';
import 'package:loja_usuario/Components/app_fonts.dart';

class ChatPageAppBar extends StatelessWidget {
  const ChatPageAppBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appBackgroundColor.withOpacity(0.1),
      elevation: 0,
      title: Text(
        'Conversas',
        style: AppFonts.title,
      ),
      actions: const [
        SizedBox(width: 10),
      ],
    );
  }
}
