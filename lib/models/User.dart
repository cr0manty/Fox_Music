import 'dart:convert';

User clientFromJson(String str) {
  final jsonData = json.decode(str);
  return User.fromJson(jsonData);
}

String clientToJson(User data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class User {
  String firstName;
  String lastName;
  String image;
  String email;
  DateTime joined;
  final String username;
  final int userId;
  final String token;

  User(
      {this.username,
      this.token,
      this.userId,
      this.image,
      this.email,
      this.firstName,
      this.joined,
      this.lastName});

  factory User.fromJson(Map<String, dynamic> json) => new User(
      username: json['username'],
      token: json['token'],
      userId: json['userId'],
      image: json['image'],
      email: json['email'],
      firstName: json['firstName'],
      joined: json['joined'],
      lastName: json['lastName']);

  Map<String, dynamic> toJson() => {
        'username': username,
        'token': token,
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'email': lastName,
        'joined': lastName,
        'image': image,
      };
}


