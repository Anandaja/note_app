import 'package:flutter/material.dart';
import 'package:note_app/ui/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  Future<void> _loadthemepreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool isDarkmode = pref.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkmode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme(bool isDarkMode) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      pref.setBool('isDarkModel', isDarkMode);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadthemepreference();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NoteApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light
      ),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: _themeMode,
      home: Home(onThemechange:_toggleTheme),
    );
  }
}
