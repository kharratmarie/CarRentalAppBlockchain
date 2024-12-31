import 'package:car_rental_app/car_rental_model.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/AddCarPage.dart';
import 'package:car_rental_app/RentCarPage.dart';
import 'package:flutter_web3/ethereum.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _email = ""; // Variable pour stocker l'email récupéré
  String account = '';  // Variable pour stocker l'adresse du compte
  bool isConnected = false; // État de la connexion

  @override
  void initState() {
    super.initState();
    connectToMetaMask();
  }

  

  Future<void> connectToMetaMask() async {
    if (ethereum != null) {
      try {
        final accounts = await ethereum!.requestAccount();
        final account = accounts.first;

        setState(() {
          this.account = account;
          isConnected = true;
        });

        Provider.of<CarRentalModel>(context, listen: false).setAccount(account);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to MetaMask: $account')),
        );
      } catch (e) {
        setState(() {
          isConnected = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('MetaMask is not available in this browser.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final carRental = Provider.of<CarRentalModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Car Rental App"),
        centerTitle: true,
        backgroundColor: Colors.brown.shade700,
      ),
      body: Container(
        color: Colors.brown.shade50,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_email != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                
              ),

            SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: connectToMetaMask,
              icon: Icon(isConnected ? Icons.refresh : Icons.wallet),
              label: Text(isConnected ? 'Reconnect to MetaMask' : 'Connect to MetaMask'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected ? Color.fromARGB(255, 255, 212, 221) : Colors.brown.shade700,
              ),
            ),

            if (isConnected)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Connected Account: $account',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown.shade800),
                ),
              ),

       ElevatedButton(
  onPressed: () async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AddCarPage()),
    );
  },
  child: Text("Add Car"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.brown.shade700,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: EdgeInsets.symmetric(vertical: 14.0),
    shadowColor: Colors.brown.shade900,
    elevation: 5,
  ),
),
const SizedBox(height: 16.0),

            Expanded(
              child: Consumer<CarRentalModel>(
                builder: (context, carRentalModel, _) {
                  final cars = carRentalModel.cars;

                  if (cars.isEmpty) {
                    return Center(
                      child: Text(
                        "No cars available",
                        style: TextStyle(color: Colors.brown.shade800),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      return Card(
                        color: Colors.white,
                        elevation: 5,
                        margin: EdgeInsets.all(4.0),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: ${car['id']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown.shade800)),
                              SizedBox(height: 5),
                              Text('Price: ${car['rentalPrice']} WEI', style: TextStyle(color: Colors.brown.shade600)),
                              Text('Model: ${car['model']}', style: TextStyle(color: Colors.brown.shade600)),
                              Text('Status: ${car['status']}', style: TextStyle(color: Colors.brown.shade600)),
                              SizedBox(height: 4),
                              car['imageUrl'] != null && car['imageUrl'].isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        car['imageUrl'],
                                        width: double.infinity,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Text('No image available', style: TextStyle(color: Colors.brown.shade600)),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    car['available'] ? 'Available' : 'Rented',
                                    style: TextStyle(
                                      color: car['available'] ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      car['available'] ? Icons.car_rental : Icons.arrow_back,
                                      color: Colors.brown.shade800,
                                    ),
                                    onPressed: () async {
                                      if (car['available']) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RentCarPage(car: car),
                                          ),
                                        );
                                      } else {
                                        String? carState = await showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            TextEditingController stateController = TextEditingController();
                                            return AlertDialog(
                                              title: Text('Return Car'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Please enter the condition of the car upon return:'),
                                                  TextField(
                                                    controller: stateController,
                                                    decoration: InputDecoration(hintText: 'Car condition'),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text('Cancel'),
                                                  onPressed: () => Navigator.of(context).pop(null),
                                                ),
                                                TextButton(
                                                  child: Text('Submit'),
                                                  onPressed: () => Navigator.of(context).pop(stateController.text.trim()),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (carState != null && carState.isNotEmpty) {
                                          await carRentalModel.returnCar(car['id'], carState);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Car returned successfully')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Car return canceled')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
