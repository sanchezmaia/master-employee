import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmployeesPage extends StatefulWidget {
  @override
  _EmployeesPageState createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  List employees = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/employees'));

    if (response.statusCode == 200) {
      setState(() {
        employees = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load employees');
    }
  }

  Future<void> deleteEmployee(int id) async {
    final response =
        await http.delete(Uri.parse('http://localhost:3000/employees/$id'));

    if (response.statusCode == 204) {
      setState(() {
        employees.removeWhere((employee) => employee['id'] == id);
      });
    } else {
      throw Exception('Failed to delete employee');
    }
  }

  void editEmployee(int id) {
    final employee = employees.firstWhere((employee) => employee['id'] == id);
    TextEditingController usernameController =
        TextEditingController(text: employee['username']);
    TextEditingController roleIdController =
        TextEditingController(text: employee['role_id']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: roleIdController,
                decoration: InputDecoration(labelText: 'Role ID'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final response = await http.put(
                  Uri.parse('http://localhost:3000/employees/$id'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'username': usernameController.text,
                    'role_id': roleIdController.text,
                  }),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  fetchEmployees();
                } else {
                  print('Failed to edit employee');
                }
              },
              child: Text('Edit Employee'),
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
        title: Text('Master Employee'),
      ),
      body: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(employees[index]['username']),
            subtitle: Text(employees[index]['role_id'].toString()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => editEmployee(employees[index]['id']),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteEmployee(employees[index]['id']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
