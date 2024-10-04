import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TIG333 TODO',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  TodoListScreenState createState() => TodoListScreenState();
}

class TodoListScreenState extends State<TodoListScreen> {
  final List<Map<String, dynamic>> todos = [];
  final String apiUrl = 'https://todoapp-api.apps.k8s.gu.se/todos';
  final String apiKey = '95e1b724-355e-47e9-818d-09e8ef693f94'; 
  String filterType = 'All'; 

  @override
  void initState() {
    super.initState();
    fetchTodos(); 
  }

  Future<void> fetchTodos() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl?key=$apiKey'), 
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          todos.clear();
          todos.addAll(data.map((item) => {
                'id': item['id'] ?? '', 
                'task': item['title'] ?? '', 
                'isChecked': item['done'] ?? false, 
              }));
        });
      }
    } catch (e) {
      debugPrint('Error fetching todos: $e');
    }
  }

  Future<void> addTodoItem(String task) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'), 
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'title': task, 'done': false}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> updatedTodos = json.decode(response.body);
        setState(() {
          todos.clear();
          todos.addAll(updatedTodos.map((item) => {
                'id': item['id'] ?? '', 
                'task': item['title'] ?? '', 
                'isChecked': item['done'] ?? false, 
              }));
        });
      } else {
        debugPrint('Failed to add task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  Future<void> toggleTodoItem(int index) async {
    final todo = todos[index];
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${todo['id']}?key=$apiKey'), 
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': todo['task'], 
          'done': !todo['isChecked'],
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          todos[index]['isChecked'] = !todo['isChecked'];
        });
      }
    } catch (e) {
      debugPrint('Error toggling todo: $e');
    }
  }

  Future<void> removeTodoItem(int index) async {
    final todo = todos[index];
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/${todo['id']}?key=$apiKey'), 
      );

      if (response.statusCode == 200) {
        setState(() {
          todos.removeAt(index);
        });
      }
    } catch (e) {
      debugPrint('Error removing todo: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredTodos() {
    if (filterType == 'Done') {
      return todos.where((todo) => todo['isChecked'] == true).toList();
    } else if (filterType == 'Undone') {
      return todos.where((todo) => todo['isChecked'] == false).toList();
    }
    return todos; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TIG333 TODO'),
        backgroundColor: Colors.grey,
        actions: [
          DropdownButton<String>(
            value: filterType,
            onChanged: (String? newValue) {
              setState(() {
                filterType = newValue!;
              });
            },
            items: <String>['All', 'Done', 'Undone']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: getFilteredTodos().length,
          itemBuilder: (context, index) {
            var filteredTodos = getFilteredTodos();
            return ListTile(
              leading: Checkbox(
                value: filteredTodos[index]['isChecked'],
                onChanged: (bool? value) {
                  toggleTodoItem(index);
                },
              ),
              title: Text(
                filteredTodos[index]['task'],
                style: TextStyle(
                  decoration: filteredTodos[index]['isChecked']
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  removeTodoItem(index);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddTodoScreen(addTodo: addTodoItem)),
          );
        },
        backgroundColor: Colors.grey,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTodoScreen extends StatelessWidget {
  final Function(String) addTodo;

  const AddTodoScreen({super.key, required this.addTodo});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('TIG333 TODO'),
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'What are you going to do?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  addTodo(controller.text);
                  Navigator.pop(context);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text('+ ADD'),
            ),
          ],
        ),
      ),
    );
  }
}
