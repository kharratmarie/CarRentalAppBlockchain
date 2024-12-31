import 'package:car_rental_app/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/car_rental_model.dart';

class AddCarPage extends StatelessWidget {
  AddCarPage({super.key});

  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final carRental = Provider.of<CarRentalModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Car"),
        backgroundColor: Colors.brown[300], // Couleur de l'AppBar
      ),
      body: Container(
        color: Colors.white, // Arrière-plan blanc
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: "Car Model",
                labelStyle: TextStyle(color: Color.fromARGB(255, 114, 48, 23)),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: "Rental Price",
                labelStyle: TextStyle(color: Color.fromARGB(255, 114, 48, 23)),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(
                labelText: "Car Status",
                labelStyle: TextStyle(color: Color.fromARGB(255, 114, 48, 23)),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: "Image URL",
                labelStyle: TextStyle(color: Color.fromARGB(255, 114, 48, 23)),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final model = _modelController.text;
                final price = int.tryParse(_priceController.text) ?? 0;
                final status = _statusController.text;
                final imageUrl = _imageUrlController.text;

                await carRental.addCar(model, price, status, imageUrl);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[300], // Couleur du bouton
              ),
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}
