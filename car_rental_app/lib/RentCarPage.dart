import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/car_rental_model.dart';
import 'package:car_rental_app/homeScreen.dart';

class RentCarPage extends StatefulWidget {
  final Map<String, dynamic> car;

  const RentCarPage({super.key, required this.car});

  @override
  _RentCarPageState createState() => _RentCarPageState();
}

class _RentCarPageState extends State<RentCarPage> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedStartDate != null && _selectedEndDate != null
          ? DateTimeRange(start: _selectedStartDate!, end: _selectedEndDate!)
          : null,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.brown,
            scaffoldBackgroundColor: Colors.white,
            dialogBackgroundColor: Colors.white,
            colorScheme: ColorScheme.light(
              primary: Colors.brown,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.brown,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.brown),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final carRental = Provider.of<CarRentalModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Location de la voiture: ${widget.car['id']}'),
        backgroundColor: Colors.brown,
      ),
      backgroundColor: Colors.brown.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 7.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Model: ${widget.car['model'] ?? "Non "}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.brown),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        widget.car['imageUrl'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rental price : \$${widget.car['rentalPrice'] ?? "Non spécifié"}',
                      style: const TextStyle(fontSize: 16,color: Colors.brown),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Availability: ${widget.car['available'] == true ? 'Available' : 'Not Available'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.car['available'] == true ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Rent dates:', style: TextStyle(fontSize: 16,color: Colors.brown)),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => _selectDateRange(context),
                  child: Text(
                    _selectedStartDate == null || _selectedEndDate == null
                        ? 'Choose a plage'
                        : '${_selectedStartDate!.toLocal()}'.split(' ')[0] +
                          ' - ' +
                          '${_selectedEndDate!.toLocal()}'.split(' ')[0],
                    style: const TextStyle(fontSize: 16, color: Colors.brown),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            widget.car['available'] == true
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () async {
                      if (_selectedStartDate != null && _selectedEndDate != null) {
                        try {
                          final startDate = _selectedStartDate!.millisecondsSinceEpoch ~/ 1000;
                          final endDate = _selectedEndDate!.millisecondsSinceEpoch ~/ 1000;

                          await carRental.rentCar(widget.car['id'], startDate, endDate);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sucessful rental !')),
                          );
                        } catch (e) {
                          if (e.toString().contains('revert Owner cannot rent their own car')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("revert Owner cannot rent their own car")),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('please add all the form.')),
                        );
                      }
                    },
                    child: const Text('Rent this car'),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: null,
                    child: const Text('Voiture non disponible'),
                  ),
                  const SizedBox(height: 16.0),
              ElevatedButton(
  onPressed: () async {
    // Naviguer vers la page d'enregistrement
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.brown.shade500,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 14.0),
  ),
  child: const Text("Return to home page"),
),
          ],
        ),
      ),
    );
  }
}
