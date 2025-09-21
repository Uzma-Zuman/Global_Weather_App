import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await dotenv.load(fileName: "assets/config/.env");
  } else {
    await dotenv.load(fileName: ".env");
  }

  runApp(const WeatherApp());
}
