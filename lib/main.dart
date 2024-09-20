import 'package:flutter/material.dart';

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

  void addTodoItem(String task) {
    setState(() {
      todos.add({'task': task, 'isChecked': false});
    });
  }

  void toggleTodoItem(int index) {
    setState(() {
      todos[index]['isChecked'] = !todos[index]['isChecked'];
    });
  }

  void removeTodoItem(int index) {
    setState(() {
      todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TIG333 TODO'),
        backgroundColor: Colors.grey,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Checkbox(
                value: todos[index]['isChecked'],
                onChanged: (bool? value) {
                  toggleTodoItem(index);
                },
              ),
              title: Text(
                todos[index]['task'],
                style: TextStyle(
                  decoration: todos[index]['isChecked']
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
