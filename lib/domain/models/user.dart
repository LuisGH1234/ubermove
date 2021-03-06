import 'package:ubermove/domain/core/base.domain.dart';

class User extends Entity {
  /// User Id
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final bool active;
  final String password;
  final String phone;

  User(
      {this.id,
      this.email,
      this.firstName,
      this.lastName,
      this.active,
      this.phone,
      this.password});
  // : assert(email != null);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      active: json['active'],
      password: json['password'],
      phone: json['phone'],
    );
  }

  @override
  Map<String, dynamic> convertirJson() => {
        "id": id,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "password": password,
        "phone": phone,
      };

  @override
  List<Object> get props => [id, email, firstName, lastName, active];
}
