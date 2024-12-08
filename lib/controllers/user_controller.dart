import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; // Path provider for local file storage
import '../models/user_model.dart';

class UserController {
  final String apiBaseUrl =
      "https://example.com/api"; // Replace with your base URL

  // Function to get the path for the local users.json file
  Future<String> _getLocalFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final dataDirectory =
        Directory('${directory.path}/local_data'); // Directory to store data

    // Check if the directory exists, if not, create it
    if (!await dataDirectory.exists()) {
      await dataDirectory.create(
          recursive: true); // Create the directory if not exists
      print("Directory created at ${dataDirectory.path}");
    }

    // Full path for the users.json file
    return '${dataDirectory.path}/users.json';
  }

  // Login method (first check local, then API)
  Future<User?> login(String email, String password) async {
    try {
      final filePath = await _getLocalFilePath();
      final users = await User.loadFromLocalFile(filePath);

      // Try to find user locally first
      try {
        return users.firstWhere(
          (user) => user.email == email && user.password == password,
        );
      } catch (e) {
        print("User not found locally, trying API.");
      }

      // If not found locally, fallback to API
      final response = await http.post(
        Uri.parse('$apiBaseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception("Login failed: ${response.body}");
      }
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }

  // Signup method (add to local storage and API)
  Future<User> signup(
      String id, String name, String email, String password) async {
    try {
      final newUser =
          User(name: name, email: email, password: password, id: '1');
      final filePath = await _getLocalFilePath();

      final users = await User.loadFromLocalFile(filePath);

      // Check if the email already exists locally
      if (users.any((user) => user.email == email)) {
        throw Exception("Signup failed: Email already exists locally.");
      }

      // Add the new user to the list and save to the local file
      users.add(newUser);
      await User.saveToLocalFile(users, filePath);

      // Send to API
      final response = await http.post(
        Uri.parse('$apiBaseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newUser.toJson(isSignup: true)),
      );

      if (response.statusCode == 201) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Signup failed: ${response.body}");
      }
    } catch (e) {
      print("Error during signup: $e");
      rethrow;
    }
  }
}
