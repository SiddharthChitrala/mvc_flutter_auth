import 'dart:convert';
import 'dart:io';

class User {
  final String id;
  final String name;
  final String email;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  // Convert JSON into a User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }

  // Convert User object into JSON
  Map<String, dynamic> toJson({bool isSignup = false}) {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  // Load users from local storage
  static Future<List<User>> loadFromLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception("Failed to load users from local file: $e");
    }
  }

  // Save users to local storage
  static Future<void> saveToLocalFile(List<User> users, String filePath) async {
    final file = File(filePath);
    final jsonString = jsonEncode(users.map((u) => u.toJson()).toList());
    await file.writeAsString(jsonString);
  }
}
