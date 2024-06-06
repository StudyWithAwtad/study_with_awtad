import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import './firebase/auth/firebase_auth.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;
late UserCredential? credentials;

// This class was added to make http requests possible only in development moode
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    auth = FirebaseAuth.instanceFor(app: app);
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  // This line was added to make http requests possible only in development moode
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _createUserHandler() async {
    credentials = await createUser("mukabha99@gmail.com", "123456789");
    // do somthing with credentials after successfully creating new user
    print('credentials: $credentials');
  }

  void _createUserWithPhoneNumberHandler() async {
    createUserWithPhoneNumber("+9720551112233");
    // do somthing with credentials after successfully creating new user
  }

  void _healthCheck() async {
    var response = await http
        .get(Uri.parse('https://10.0.2.2:7134/api/Users/healthcheck'));
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print('A network error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: () {
                //_createUserHandler();
                _createUserWithPhoneNumberHandler();
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Custom Elevated Button'),
            ),
            ElevatedButton(
              onPressed: () {
                //_createUserHandler();
                _healthCheck();
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Healthy Check'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
