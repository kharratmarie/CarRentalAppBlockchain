import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart'; // Pour les requêtes HTTP
import 'package:flutter/services.dart'; // Pour accéder au rootBundle

class CarRentalModel extends ChangeNotifier {

   final String _rpcUrl = "http://127.0.0.1:7545"; // URL RPC Ganache
  // final String _privateKey = "0x9eb9aeca20776616aa1e8aaa88d76f8651d65f827552c3d73a172656e5d84198"; // Clé privée
   final String _privateKey = "0x153f2ba9fed8ddd79b278e030c6aff64af132806647caeb10978556a138008cd"; // Clé privée
 final String _contractAddress = "0xE9758d4607d8a3d07982af4cF9aaed3f3E6B86C1";

  late Web3Client _client;
    late Credentials _credentials;

  late DeployedContract _contract;
  bool _isInitialized = false; // Vérification de l'initialisation
  String? _account;  // Store account information
  bool _isConnected = false;

  // Getter for account
  String? get account => _account;
  
  // Getter for connection status
  bool get isConnected => _isConnected;

  // Setters
  void setAccount(String account) {
    _account = account;
    _isConnected = true;
    notifyListeners();
  }

  void disconnect() {
    _account = null;
    _isConnected = false;
    notifyListeners();
  }

  late List<Map<String, dynamic>> _cars;  // Liste des voitures

  CarRentalModel() {
        _client = Web3Client(_rpcUrl, Client());

    _init();
  }

  Future<void> _init() async {
      _credentials = EthPrivateKey.fromHex(_privateKey);



  String abi = '''[
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "addBalance",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "model",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "rentalPrice",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "status",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "imageUrl",
				"type": "string"
			}
		],
		"name": "addCar",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "carId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "model",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "rentalPrice",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "status",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "imageUrl",
				"type": "string"
			}
		],
		"name": "CarAdded",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "carCount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "model",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "rentalPrice",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "status",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "imageUrl",
				"type": "string"
			}
		],
		"name": "CarAddedDebug",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "carId",
				"type": "uint256"
			}
		],
		"name": "CarMadeAvailable",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "carId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "renter",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "startDate",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "endDate",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "CarRented",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "carId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "renter",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "newStatus",
				"type": "string"
			}
		],
		"name": "CarReturned",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "carId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "bool",
				"name": "available",
				"type": "bool"
			}
		],
		"name": "DebugCarAvailability",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "carId",
				"type": "uint256"
			}
		],
		"name": "DebugCarId",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "deductBalance",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "carId",
				"type": "uint256"
			}
		],
		"name": "makeCarAvailable",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "email",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "password",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "phone",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "cin",
				"type": "string"
			}
		],
		"name": "registerUser",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "carId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "startDate",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "endDate",
				"type": "uint256"
			}
		],
		"name": "rentCar",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "carId",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "newStatus",
				"type": "string"
			}
		],
		"name": "returnCar",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "email",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "password",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "phone",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "cin",
				"type": "string"
			}
		],
		"name": "UserAdded",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "withdrawFunds",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "balances",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "carCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "cars",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "model",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "rentalPrice",
				"type": "uint256"
			},
			{
				"internalType": "bool",
				"name": "available",
				"type": "bool"
			},
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "status",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "imageUrl",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "startDate",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "endDate",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAllCars",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "model",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "rentalPrice",
						"type": "uint256"
					},
					{
						"internalType": "bool",
						"name": "available",
						"type": "bool"
					},
					{
						"internalType": "address",
						"name": "owner",
						"type": "address"
					},
					{
						"internalType": "string",
						"name": "status",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "imageUrl",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "startDate",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "endDate",
						"type": "uint256"
					}
				],
				"internalType": "struct CarRental.Car[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAllUsers",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "email",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "password",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "phone",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "cin",
						"type": "string"
					}
				],
				"internalType": "struct CarRental.User[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "carId",
				"type": "uint256"
			}
		],
		"name": "getCar",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "rentals",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "rentedCars",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "carId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "startDate",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "endDate",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "userAddresses",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "userCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "UserCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "users",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "email",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "password",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "phone",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "cin",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
''';
   
    // Déploiement du contrat
    _contract = DeployedContract(
      ContractAbi.fromJson(abi, "CarRental"),
        EthereumAddress.fromHex(_contractAddress),
    );

    _isInitialized = true;
    await _loadCars();
    notifyListeners();  // Notifier l'UI que l'initialisation est terminée
  }




  Future<void> _loadCars() async {
  if (!_isInitialized) return;

  final carCountFunction = _contract.function('carCount');
  final carsFunction = _contract.function('cars');

  final carCount = await _client.call(
    contract: _contract,
    function: carCountFunction,
    params: [],
  );

  List<Map<String, dynamic>> carsList = [];
  for (var i = 1; i <= carCount.first.toInt(); i++) {
    final car = await _client.call(
      contract: _contract,
      function: carsFunction,
      params: [BigInt.from(i)],
    );

    // Ajouter l'adresse du propriétaire (compte connecté)
    carsList.add({
      'id': i,
      'model': car[1],
      'rentalPrice': car[2].toString(),
      'available': car[3],
      'status': car[5],
      'imageUrl': car[6],
      'startDate': DateTime.fromMillisecondsSinceEpoch(car[7].toInt() * 1000),
      'endDate': DateTime.fromMillisecondsSinceEpoch(car[8].toInt() * 1000),
      
    });
  }

  _cars = carsList;
  notifyListeners();
}


  List<Map<String, dynamic>> get cars => _cars;
  bool get isInitialized => _isInitialized;

  Future<BigInt> getBalance(EthereumAddress address) async {
    if (!_isInitialized) throw Exception("Le client n'est pas initialisé");
    try {
      final balance = await _client.getBalance(address);
      return balance.getInWei; // Retourne le solde en Wei
    } catch (e) {
      print("Erreur lors de la récupération du solde: $e");
      return BigInt.zero;
    }
  }

  Future<void> addCar(String model, int rentalPrice, String status, String imageUrl ) async {
  if (!_isInitialized) return;
  
  final credentials = EthPrivateKey.fromHex(_privateKey);
  final addCarFunction = _contract.function("addCar");

  try {
    // Convertir l'adresse en EthereumAddress

    // Appel de la fonction
    await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _contract,
        function: addCarFunction,
        parameters: [
          model, 
          BigInt.from(rentalPrice),  // rentalPrice en BigInt
          status,
          imageUrl,

        ],
      ),
      chainId: 1337,  // Ganache chainId
    );
    print(imageUrl);
    
    await _loadCars();  // Recharger la liste des voitures
  } catch (e) {
    print("Erreur lors de l'envoi de la transaction: $e");
  }
}

  Future<void> makeCarAvailable(int carId) async {
    if (!_isInitialized) return;
    final credentials = EthPrivateKey.fromHex(_privateKey);
    final returnCarFunction = _contract.function("returnCar");

    try {
      await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: _contract,
          function: returnCarFunction,
          parameters: [BigInt.from(carId)],
        ),
        chainId: 1337,
      );
      await _loadCars();  // Recharger la liste des voitures
      print("$_cars");
    } catch (e) {
      print("Erreur lors de l'envoi de la transaction: $e");
    }
  }

  Future<void> returnCar(int carId, String newStatus) async {
  if (!_isInitialized) return;

  final credentials = EthPrivateKey.fromHex(_privateKey);
  final returnCarFunction = _contract.function("returnCar");
  final address = credentials.address;
  final balance = await getBalance(address);
    print("Balance aprés location: $balance wei");

  // Recherche de la voiture dans la liste des voitures
    final car = _cars.firstWhere((car) => car['id'] == carId);

  // Si la voiture n'existe pas, on renvoie une erreur
  if (car == null) {
    print("Car not found!");
    return;
  }

  // Affichage de la voiture et de son statut actuel
  print("Calling returnCar with carId: $carId, current status: ${car['status']}");

  try {
    if (newStatus != car['status']) {
      print("Tu es pénalisé de 20 wei");
      
      // Calculer le nouveau solde après la pénalité
      BigInt newBalance = balance - BigInt.from(20);
    print("Balance aprés location: $newBalance wei");

      // Si le solde est insuffisant pour payer la pénalité, afficher un message
      if (newBalance < BigInt.zero) {
        print("Solde insuffisant pour appliquer la pénalité.");
        return;
      }
         final balance1 = await getBalance(address);
    print("Balance aprés location: $balance1 wei");

      // Vous devez maintenant mettre à jour le solde de l'utilisateur
      // Cette logique peut inclure un appel à un contrat intelligent pour enregistrer cette modification.
      // Exemple d'appel à un contrat pour mettre à jour le solde si nécessaire (à ajouter)
      //  await _updateBalance(address, newBalance);
    }
   


    // Appel à la fonction de contrat pour mettre à jour le statut de la voiture
    await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _contract,
        function: returnCarFunction,
        parameters: [
          BigInt.from(carId),
          newStatus, // Nouveau statut
        ],
      ),
      chainId: 1337,
    );

    print("Voiture retournée avec succès avec le statut : $newStatus");
    await _loadCars(); // Recharger les données
  } catch (e) {
    print("Erreur lors de la transaction de retour : $e");
  }
}


  Future<void> rentCar(int carId,int startDate, int endDate ) async {
    if (!_isInitialized) return;

    final credentials = EthPrivateKey.fromHex(_privateKey);
    final rentCarFunction = _contract.function("rentCar");
    final address = credentials.address;
    final balance = await getBalance(address);


    print("Balance initiale: $balance wei");

    final car = _cars.firstWhere((car) => car['id'] == carId);

    if (car == null) {
      print("Voiture non trouvée !");
      return;
    }

    final rentalPrice = BigInt.from(int.parse(car['rentalPrice']));

    print("Prix de location: $rentalPrice Wei");


    if (balance < rentalPrice) {
      print("Solde insuffisant pour louer cette voiture !");
      return;
    }

    EtherAmount etherAmount = EtherAmount.fromUnitAndValue(EtherUnit.wei, rentalPrice);
print([BigInt.from(carId)]); 
    try {
      await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: _contract,
          function: rentCarFunction,
    parameters: [BigInt.from(carId), BigInt.from(startDate), BigInt.from(endDate)],
          value: etherAmount,  // Passer EtherAmount
        ),
        chainId: 1337,  // ID de la chaîne Ganache
      );

      print("Voiture louée avec succès !");

      BigInt newBalance = balance - rentalPrice;

      BigInt refund = etherAmount.getInWei - rentalPrice;
      if (refund > BigInt.zero) {
        newBalance = newBalance + refund;
        print("Remboursement: $refund Wei");
      }


    final balance1 = await getBalance(address);


    print("Balance aprés location: $balance1 wei");
print(cars);
      await _loadCars();  // Recharger la liste des voitures
      notifyListeners();  // Mettre à jour l'UI
    } catch (e) {
      print("Erreur lors de l'envoi de la transaction: $e");
    }
  }

  Future<List<dynamic>> getCarDetails(int carId) async {
    if (!_isInitialized) return [];
    final getCarFunction = _contract.function("getCar");
    final result = await _client.call(
      contract: _contract,
      function: getCarFunction,
      params: [BigInt.from(carId)],
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllCars() async {
    if (!_isInitialized) return [];
    return _cars;
  }
}