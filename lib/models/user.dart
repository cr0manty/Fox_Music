import 'dart:convert';

String userToJson(User data) {
  final str = data.toJson();
  return json.encode(str);
}

User userFromJson(String str) {
  if (str != null && str.isNotEmpty) {
    final data = json.decode(str);
    return User.fromJson(data);
  }
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
  bool can_use_vk;
  int id;
  int user_id;
  final String username;
  final String token;

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
      this.last_login,
      this.can_use_vk});

  @override
  int get hashCode => id.hashCode;

  bool operator ==(o) => id == o.id;

  @override
  toString() {
    return username;
  }

  factory User.fromJson(Map<String, dynamic> json) => new User(
      username: json['username'],
      token: json['token'],
      user_id: json['user_id'],
      id: json['id'],
      image: json['image'],
      email: json['email'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      date_joined: json['date_joined'],
      vk_auth: json['vk_auth'] ?? false,
      is_staff: json['is_staff'] ?? false,
      can_use_vk: json['can_use_vk'] ?? false);

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
        'id': id,
        'can_use_vk': can_use_vk
      };
}
