import 'package:car_rental_app/homeScreen.dart';
import 'package:car_rental_app/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web3/ethereum.dart';
import 'package:provider/provider.dart';
import 'car_rental_model.dart'; // Importer votre modèle CarRentalModel.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CarRentalModel(), // Fournir CarRentalModel
        ),
      ],
      child: MaterialApp(
        title: 'Car Rental DApp',
        theme: ThemeData.dark(),
        home:  LoginScreen(),
      ),
    );
  }
}

