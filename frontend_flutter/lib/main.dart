import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'splash/splash_screen.dart';
import 'providers/caretaker_dashboard_provider.dart';
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const NoctraApp());
}

class NoctraApp extends StatelessWidget {
  const NoctraApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        /// dashboard provider
        ChangeNotifierProvider(
          create: (_) => CaretakerDashboardProvider(),
        ),

      ],

      child: MaterialApp(
        scaffoldMessengerKey: messengerKey,
        debugShowCheckedModeBanner: false,

        title: "NOCTRA",

        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: "Roboto",
        ),

        home: const SplashScreen(),
      ),
    );
  }
}