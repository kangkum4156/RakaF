import 'package:flutter/material.dart';
import 'package:rokafirst/intro.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ko_KR', null);
  Intl.defaultLocale = 'ko_KR';
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen()
    ),
  );
}

