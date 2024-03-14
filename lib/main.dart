import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Work management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Map<String, dynamic>> _todoItems = [];

  @override
  void initState() {
    super.initState();
    _fetchTodoItems();
  }

  Future<void> _fetchTodoItems() async {
    final response = await http.get(Uri.parse('https://638719ade399d2e473f47997.mockapi.io/api/todolist'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _todoItems = List<Map<String, dynamic>>.from(data);
      });
    } else {
      throw Exception('Failed to load todo items');
    }
  }

  Future<void> _deleteTodoItem(String id) async {
    final response = await http.delete(Uri.parse('https://638719ade399d2e473f47997.mockapi.io/api/todolist/$id'));
    if (response.statusCode == 200) {
      _fetchTodoItems(); // Reload todo items after deletion
    } else {
      throw Exception('Failed to delete todo item');
    }
  }

  Future<void> _addTodoItem(String title, String description, String deadline, String priority, String status) async {
    final response = await http.post(
      Uri.parse('https://638719ade399d2e473f47997.mockapi.io/api/todolist'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'description': description,
        'deadline': deadline,
        'priority': priority,
        'status': status,
      }),
    );
    if (response.statusCode == 201) {
      _fetchTodoItems(); // Reload todo items after addition
    } else {
      throw Exception('Failed to add todo item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Work management todo list'),
      ),
      body: _todoItems.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _todoItems.length,
        itemBuilder: (context, index) {
          final todo = _todoItems[index];
          return TodoItemCard(todo: todo, onDelete: () => _deleteTodoItem(todo['id']));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTodoScreen(addTodoItem: _addTodoItem)),
          );
        },
        tooltip: 'Add task',
        child: Icon(Icons.add),
      ),
    );
  }
}

class TodoItemCard extends StatelessWidget {
  final Map<String, dynamic> todo;
  final VoidCallback onDelete;

  const TodoItemCard({required this.todo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 4.0,
      child: ListTile(
        title: Text(
          todo['title'] ?? 'No Title',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.0),
            Text(
              'Description: ${todo['description'] ?? 'No Description'}',
            ),
            SizedBox(height: 4.0),
            Text(
              'Deadline: ${todo['deadline'] ?? 'No Deadline'}',
            ),
            SizedBox(height: 4.0),
            Text(
              'Priority: ${todo['priority'] ?? 'No Priority'}',
            ),
            SizedBox(height: 4.0),
            Text(
              'Status: ${todo['status'] ?? 'No Status'}',
            ),
            SizedBox(height: 8.0),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class AddTodoScreen extends StatefulWidget {
  final Future<void> Function(String, String, String, String, String) addTodoItem;

  const AddTodoScreen({required this.addTodoItem});

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề công việc',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô tả công việc',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _deadlineController,
              decoration: InputDecoration(
                labelText: 'Thời hạn hoàn thành',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _priorityController,
              decoration: InputDecoration(
                labelText: 'Mức độ ưu tiên',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _statusController,
              decoration: InputDecoration(
                labelText: 'Trạng thái công việc',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await widget.addTodoItem(
                  _titleController.text,
                  _descriptionController.text,
                  _deadlineController.text,
                  _priorityController.text,
                  _statusController.text,
                );
                Navigator.pop(
                    context); // Return to previous screen after adding todo item
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}