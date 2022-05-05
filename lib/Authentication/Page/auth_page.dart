import 'package:loja_usuario/Authentication/Services/auth_services.dart';
import 'package:loja_usuario/Authentication/Services/google_auth_services.dart';
import 'package:loja_usuario/Login/Page/login_page.dart';
import 'package:loja_usuario/Login/Page/teste_login.dart';
import 'package:loja_usuario/Main/Page/main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    AuthService auth = Provider.of<AuthService>(context);
    if (auth.isLoading) {
      return loading();
    } else if (auth.user == null) {
      return const TestLogin();
    } else {
      return const MainPage();
    }
  }

  loading() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
