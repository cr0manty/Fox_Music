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
  String first_name;
  String last_name;
  String image;
  String email;
  String date_joined;
  String last_login;
  bool vk_auth;
  bool is_staff;
  int id;
  bool can_use_vk;
  final String username;
  final String token;
  final int user_id;

  User(
      {this.id,
      this.username,
      this.token,
      this.user_id,
      this.image,
      this.email,
      this.first_name,
      this.date_joined,
      this.last_name,
      this.vk_auth,
      this.is_staff,
      this.last_login});

  factory User.fromJson(Map<String, dynamic> json) => new User(
      username: json['username'],
      token: json['token'],
      user_id: json['user_id'],
      id: json['id'],
      image: json['image'],
      email: json['email'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      last_login: json['last_login'],
      date_joined: json['date_joined'],
      vk_auth: json['vk_auth'],
      is_staff: json['is_staff']);

  Map<String, dynamic> toJson() => {
        'username': username,
        'token': token,
        'user_id': user_id,
        'first_name': first_name,
        'last_name': last_name,
        'email': email,
        'date_joined': date_joined,
        'image': image,
        'vk_auth': vk_auth,
        'is_staff': is_staff,
        'last_login': last_login,
        'id': id
      };
}
