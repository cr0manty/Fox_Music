import 'dart:convert';

import 'package:fox_music/utils/constants.dart';

String userToJson(User data) {
  final str = data.toJson();
  return json.encode(str);
}

User userFromJson(String str) {
  if (str != null && str.isNotEmpty) {
    final data = json.decode(str);
    return User.fromJson(data);
  }
  return null;
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
  bool canUseVk;
  int id;
  int userId;
  final String username;

  User(
      {this.id,
      this.username,
      this.userId,
      this.image,
      this.email,
      this.firstName,
      this.joined,
      this.lastName,
      this.vkAuth,
      this.isStaff,
      this.lastLogin,
      this.canUseVk});

  @override
  int get hashCode => id.hashCode;

  bool operator ==(o) => id == o.id;

  @override
  toString() {
    return username;
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
      username: json['username'],
      userId: json['user_id'],
      id: json['id'],
      image: json['image'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      joined: json['date_joined'],
      vkAuth: json['vk_auth'] ?? false,
      isStaff: json['is_staff'] ?? false,
      canUseVk: json['can_use_vk'] ?? false);

  String imageUrl() {
    if (image == null) return '';
    if (image.startsWith('http')) return image;
    return BASE_URL + image;
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'user_id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'date_joined': joined,
        'image': image,
        'vk_auth': vkAuth,
        'is_staff': isStaff,
        'id': id,
        'can_use_vk': canUseVk
      };
}
