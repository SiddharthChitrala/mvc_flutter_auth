import 'package:flutter/material.dart';
import '/pages/details_screen.dart'; // Make sure this is the correct path for your details page
import '../controllers/user_controller.dart';

class LoginScreen extends StatelessWidget {
  final UserController controller = UserController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email Field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Password Field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                // Check if email or password is empty
                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email and password cannot be empty!")),
                  );
                  return;
                }

                try {
                  // Attempt login using the controller
                  final user = await controller.login(email, password);

                  if (user != null) {
                    // Login successful, show welcome message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Welcome, ${user.email}!")),
                    );

                    // Navigate to the details page (pass the correct userId)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(userId: user.id), // Use user.id instead of an empty string
                      ),
                    );
                  } else {
                    // User not found, show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User not found!")),
                    );
                  }
                } catch (e) {
                  // Handle login failure
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Login failed: $e")),
                  );
                }
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
