import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: MaterialApp(
        title: 'Global Weather',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F1724),
          cardColor: const Color(0xFF0B1220),
          textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: 'Roboto',
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
// app.dart
