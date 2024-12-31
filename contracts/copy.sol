// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CarRental {
    address public owner;

    struct Car {
        uint id;
        string model;
        uint rentalPrice;
        bool available;

        address owner; // Propriétaire de la voiture
        string status; // Nouveau champ : statut de la voiture
        string imageUrl; // Nouveau champ : URL de l'image de la voiture
    }

modifier onlyCarOwner(uint carId) {
    require(msg.sender == cars[carId].owner, "Not the car owner");
    _;
}



    struct User {
        uint256 id;
   
        string name;
        string email;
        string phone;
        string cin;
        bool exists;
    }

mapping(address => User) public users;


    mapping(address => uint256) public balances; // Solde de chaque utilisateur

    mapping(uint => Car) public cars; // Associe un identifiant à chaque voiture
    mapping(address => uint) public rentals;
    uint public carCount = 0;
    event CarAdded(uint carId, string model, uint rentalPrice, string status, string imageUrl );
    event CarRented(uint carId, address renter ,uint startDate, uint endDate );
    event CarReturned(uint carId, address renter, string newStatus);
    event CarAddedDebug(uint carCount, string model, uint rentalPrice, string status, string imageUrl);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

function registerUser(string memory name, string memory email, string memory phone, string memory cin) public {
    require(!users[msg.sender].exists, "User already registered");
    users[msg.sender] = User(block.timestamp, name, email, phone, cin, true);
}

    // Fonction pour ajouter une voiture
    function addCar(string memory model, uint rentalPrice, string memory status, string memory imageUrl) public {
        carCount++;
        cars[carCount] = Car(carCount, model, rentalPrice, true, msg.sender, status, imageUrl); // Ajouter statut et image
        emit CarAdded(carCount, model, rentalPrice, status, imageUrl);
    }

    // Fonction pour obtenir les détails d'une voiture
    function getCar(uint carId) public view returns (uint, string memory, uint, bool, string memory, string memory) {
        Car memory car = cars[carId];
        return (car.id, car.model, car.rentalPrice, car.available, car.status, car.imageUrl);
    }

    // Fonction pour obtenir toutes les voitures
    function getAllCars() public view returns (uint[] memory, string[] memory, uint[] memory, bool[] memory, address[] memory, string[] memory, string[] memory) {
        uint[] memory ids = new uint[](carCount);
        string[] memory models = new string[](carCount);
        uint[] memory rentalPrices = new uint[](carCount);
        bool[] memory available = new bool[](carCount);
        address[] memory owners = new address[](carCount);
        string[] memory statuses = new string[](carCount);
        string[] memory imageUrls = new string[](carCount);

        for (uint i = 1; i <= carCount; i++) {
            Car memory car = cars[i];
            ids[i - 1] = car.id;
            models[i - 1] = car.model;
            rentalPrices[i - 1] = car.rentalPrice;
            available[i - 1] = car.available;
            owners[i - 1] = car.owner;
            statuses[i - 1] = car.status;
            imageUrls[i - 1] = car.imageUrl;
        }

        return (ids, models, rentalPrices, available, owners, statuses, imageUrls);
    }

    // Structure pour stocker les informations de location
struct Rental {
    uint carId;
    uint startDate;
    uint endDate;
}

mapping(address => Rental) public rentedCars; // Pour chaque utilisateur, on garde une location en cours

// Fonction pour louer une voiture avec dates de début et de fin
function rentCar(uint carId, uint startDate, uint endDate) public payable {
    Car storage car = cars[carId];

    // Vérification de la disponibilité de la voiture
    require(car.available, "Car not available");



    // Calcul du remboursement en cas de paiement excessif
    uint refund = msg.value - car.rentalPrice;
    if (refund > 0) {
        payable(msg.sender).transfer(refund); // Rembourser l'excédent
    }

    // Transférer le montant de la location au propriétaire de la voiture
    payable(car.owner).transfer(car.rentalPrice);

    // Marquer la voiture comme louée
    car.available = false;
    rentals[msg.sender] = carId;

    // Sauvegarder les dates de début et de fin dans le mapping
    rentedCars[msg.sender] = Rental(carId, startDate, endDate);

    // Émettre un événement
    emit CarRented(carId, msg.sender ,startDate, endDate);
}


    // Fonction pour rendre une voiture disponible
    function makeCarAvailable(uint carId) public {
        Car storage car = cars[carId];
        car.available = true;
        emit CarMadeAvailable(carId);
    }

    // Fonction pour ajouter des fonds à un utilisateur
    function addBalance(address user, uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        balances[user] += amount;
    }

    // Fonction pour soustraire des fonds d'un utilisateur
    function deductBalance(address user, uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(balances[user] >= amount, "Insufficient balance");
        balances[user] -= amount;
    }
   function returnCar(uint carId, string memory newStatus) public {
    Car storage car = cars[carId];
    
    // Vérifiez si la voiture existe
    require(car.id != 0, "Car does not exist");

    // Vérifiez si l'utilisateur a bien loué cette voiture
    require(rentals[msg.sender] == carId, "You have not rented this car");

    // Mise à jour du statut de la voiture
    car.status = newStatus;
    car.available = true;
    
    // Annuler la location
    rentals[msg.sender] = 0;

    // Émettre l'événement
    emit CarReturned(carId, msg.sender, newStatus);
}


    event CarMadeAvailable(uint carId);
    event DebugCarId(uint carId);
    event DebugCarAvailability(uint carId, bool available);
    
}
