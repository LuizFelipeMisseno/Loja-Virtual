import 'package:loja_usuario/Authentication/Page/auth_page.dart';
import 'package:loja_usuario/Authentication/Services/auth_services.dart';
import 'package:loja_usuario/Authentication/Services/google_auth_services.dart';
import 'package:loja_usuario/Chat/Components/date_picker_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DatePicker>(create: (context) => DatePicker()),
        ChangeNotifierProvider<AuthService>(create: (context) => AuthService()),
        ChangeNotifierProvider<GoogleSignInProvider>(
            create: (context) => GoogleSignInProvider()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale("pt", "BR")],
        title: 'Loja de Teste',
        theme: ThemeData(
          fontFamily: 'Schyler',
          primarySwatch: Colors.yellow,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthCheck(),
        /* routes: {
        AppRoutes.HOMEPAGE: (_) => HomePage(),
        AppRoutes.PROFILE: (_) => ProfilePage(),
        AppRoutes.CHAT: (_) => ChatPage(),
        AppRoutes.CART: (_) => CartPage(),
        AppRoutes.SEEMORE: (_) => SeeMorePage(),
        AppRoutes.MYSHOPPING: (_) => MyShoppingPage(),
        AppRoutes.FAVORITES: (_) => FavoritesPage(),
        AppRoutes.PROMOTIONS: (_) => PromotionsPage(),
        AppRoutes.SETTINGS: (_) =>
            SettingsPage(), 
      }, */
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
