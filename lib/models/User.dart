class User {
  String firstName;
  String lastName;
  String image;
  String email;
  DateTime joined;
  final String password;
  final String username;
  final int userId;
  final String token;

  User(this.username, this.token, this.userId, this.password);

  User.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        token = json['token'],
        password = json['password'],
        userId = json['userId'];

  Map<String, dynamic> toJson() => {
        'name': username,
        'token': token,
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'image': image,
      };
}
