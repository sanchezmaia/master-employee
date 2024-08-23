import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsersPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UsersPage> {
  List users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:3000/users'));

    if (response.statusCode == 200) {
      setState(() {
        users = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> deleteUser(int id) async {
    final response =
        await http.delete(Uri.parse('http://localhost:3000/users/$id'));

    if (response.statusCode == 200) {
      setState(() {
        users.removeWhere((user) => user['id'] == id);
      });
    } else {
      throw Exception('Failed to delete user');
    }
  }

  void addUser() {
    // Logika untuk menambah user baru
    showDialog(
        context: context,
        builder: (context) {
          TextEditingController nameController = TextEditingController();
          TextEditingController emailController = TextEditingController();
          return AlertDialog(
              title: Text('Add User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final response = await http.post(
                      Uri.parse('http://localhost:3000/users'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'name': nameController.text,
                        'email': emailController.text,
                      }),
                    );

                    if (response.statusCode == 201) {
                      Navigator.of(context).pop();
                      fetchUsers(); // Refresh user list
                    } else {
                      print('Failed to add user');
                    }
                  },
                  child: Text('Add'),
                ),
              ]);
        });
  }

  void editUser(int id) {
    //Logika untuk mengedit user
    final user = users.firstWhere((user) => user['id'] == id);
    TextEditingController nameController =
        TextEditingController(text: user['name']);
    TextEditingController emailController =
        TextEditingController(text: user['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'email'),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final response = await http.put(
                  Uri.parse('http://localhost:3000/users/$id'),
                  headers: {'Content-type': 'application/json'},
                  body: jsonEncode({
                    'name': nameController.text,
                    'email': emailController.text,
                  }),
                );
                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  fetchUsers(); // Refresh user list
                } else {
                  print('Failed to edit user');
                }
              },
              child: Text('Edit'),
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
        title: Text('Master Users'),
      ),
      body: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return ListTile(
                title: Text(users[index]['name']),
                subtitle: Text(users[index]['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => editUser(users[index]['id']),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteUser(users[index]['id']),
                    ),
                  ],
                ));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: addUser,
        child: Icon(Icons.add),
      ),
    );
  }
}
