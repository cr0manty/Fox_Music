import 'dart:convert';

User userFromJson(String str) {
  final data = json.decode(str);
  return User.fromJson(data);
}

String userToJson(User data) {
  final str = data.toJson();
  return json.encode(str);
}

class User {
  String firstName;
  String lastName;
  String image;
  String email;
  String joined;
  String lastLogin;
  bool vkAuth;
  bool isStaff;
  int id;
  final String username;
  final String token;
  final int userId;

  User(
      {this.id,
      this.username,
      this.token,
      this.userId,
      this.image,
      this.email,
      this.firstName,
      this.joined,
      this.lastName,
      this.vkAuth,
      this.isStaff,
      this.lastLogin});

  factory User.fromJson(Map<String, dynamic> json) => new User(
      username: json['username'],
      token: json['token'],
      userId: json['user_id'],
      id: json['id'],
      image: json['image'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      lastLogin: json['last_login'],
      joined: json['date_joined'],
      vkAuth: json['vk_auth']);

  Map<String, dynamic> toJson() => {
        'username': username,
        'token': token,
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'joined': joined,
        'image': image,
        'vkAuth': vkAuth,
        'isStaff': isStaff,
        'lastLogin': lastLogin,
        'id': id
      };
}
