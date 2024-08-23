import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController roleIdController = TextEditingController();

  Future<void> register(BuildContext context) async {
    String username = usernameController.text;
    String password = passwordController.text;
    String roleId = roleIdController.text;

    if (username.isNotEmpty && password.isNotEmpty && roleId.isNotEmpty) {
      var response = await http.post(
        Uri.parse('http://localhost:3000/employees/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
          'role_id': roleId,
        }),
      );

      if (response.statusCode == 201) {
        // Jika registrasi berhasil, arahkan kembali ke halaman login
        Navigator.pop(context);
      } else {
        // Tampilkan pesan error jika ada masalah dengan server
        _showErrorDialog(context, 'Registrasi gagal: ${response.body}');
      }
    } else {
      // Tampilkan pesan error jika ada input yang kosong
      _showErrorDialog(context, 'Semua field harus diisi.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Registrasi Gagal'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: roleIdController,
              decoration: InputDecoration(labelText: 'Role ID'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                register(context);
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
