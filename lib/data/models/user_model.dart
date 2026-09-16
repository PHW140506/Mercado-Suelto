class UserModel {
  final int id;
  final String email;
  final String username;
  final String phone;
  final NameModel name;
  final AddressModel? address; 

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.phone,
    required this.name,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? 'Sin correo',
      username: json['username'] ?? 'Sin usuario',
      phone: json['phone'] ?? 'Sin teléfono',
      name: json['name'] != null 
          ? NameModel.fromJson(json['name']) 
          : NameModel(firstname: 'Desconocido', lastname: ''),
      address: json['address'] != null 
          ? AddressModel.fromJson(json['address']) 
          : null,
    );
  }
}

class NameModel {
  final String firstname;
  final String lastname;

  NameModel({required this.firstname, required this.lastname});

  factory NameModel.fromJson(Map<String, dynamic> json) {
    return NameModel(
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
    );
  }

  String get fullName => '${firstname.capitalize()} ${lastname.capitalize()}'.trim();
}

class AddressModel {
  final String city;
  final String street;
  final int number;
  final String zipcode;
  final GeolocationModel? geolocation;

  AddressModel({
    required this.city,
    required this.street,
    required this.number,
    required this.zipcode,
    this.geolocation,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      city: json['city'] ?? '',
      street: json['street'] ?? '',
      number: json['number'] ?? 0,
      zipcode: json['zipcode'] ?? '',
      geolocation: json['geolocation'] != null 
          ? GeolocationModel.fromJson(json['geolocation']) 
          : null,
    );
  }
}

class GeolocationModel {
  final String lat;
  final String long;

  GeolocationModel({required this.lat, required this.long});

  factory GeolocationModel.fromJson(Map<String, dynamic> json) {
    return GeolocationModel(
      lat: json['lat'] ?? '0.0',
      long: json['long'] ?? '0.0',
    );
  }
}

// Extensión para que los nombres se vean bonitos con la primera letra mayúscula
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}