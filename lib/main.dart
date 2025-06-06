import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'views/news_list_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  // Force the status bar to be black with white icons/text.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Set status bar background to black.
      statusBarIconBrightness: Brightness.light, // For Android: white icons.
      statusBarBrightness: Brightness.dark, // For iOS: white text.
    ),
  );
  
  runApp(BeeMarzApp());
}

class BeeMarzApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BeeMarz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Container(child: NewsListPage(),margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),),
    );
  }
}
