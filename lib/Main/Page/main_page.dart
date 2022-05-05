import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:loja_usuario/Chat/Components/chat_page_app_bar.dart';
import 'package:loja_usuario/Chat/Page/chat_page.dart';
import 'package:loja_usuario/Components/app_color.dart';
import 'package:loja_usuario/Home/Components/home_page_app_bar.dart';
import 'package:loja_usuario/Home/Page/home_page.dart';
import 'package:loja_usuario/Profile/Components/profile_page_app_bar.dart';
import 'package:loja_usuario/Profile/Page/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: IndexedStack(
          index: selectedIndex,
          children: _selectedAppBar,
        ),
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: _selectedPage,
      ),
      bottomNavigationBar: bottomBar(),
    );
  }

  static const List<Widget> _selectedPage = <Widget>[
    HomePage(),
    ChatPage(),
    ProfilePage(),
  ];
  static const List<Widget> _selectedAppBar = <Widget>[
    HomePageAppBar(),
    ChatPageAppBar(),
    ProfilePageAppBar(),
  ];

  bottomBar() {
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: ClipRect(
        //Efeito de embaçamento
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10.0,
            sigmaY: 10.0,
          ),
          child: Opacity(
            //Mudar opacidade da barra de navegação
            opacity: 0.8,
            child: BottomNavigationBar(
              backgroundColor: AppColors.appBackgroundColor
                  .withOpacity(0.5), //here set your transparent level
              elevation: 0,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              currentIndex: selectedIndex, //New
              onTap: _onItemTapped,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home, size: 40), label: 'Início'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat_rounded, size: 40),
                    label: 'Conversa'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person, size: 40), label: 'Perfil')
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
