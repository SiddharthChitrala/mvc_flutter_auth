import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';

class SignupScreen extends StatelessWidget {
  final UserController controller = UserController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Name Field
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

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

            // Signup Button
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                if (name.isEmpty || email.isEmpty || password.isEmpty) {
                  // Show an error if any field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required!")),
                  );
                  return;
                }

                try {
                  // Generate a unique ID (you can change this logic)
                  final id = DateTime.now().millisecondsSinceEpoch.toString();

                  // Call the signup method
                  final user = await controller.signup(id, name, email, password);
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Account created for ${user.email}!")),
                  );
                  // Optionally navigate to login or home screen
                } catch (e) {
                  // Show error message if signup fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Signup failed: $e")),
                  );
                }
              },
              child: const Text("Signup"),
            ),
          ],
        ),
      ),
    );
  }
}
