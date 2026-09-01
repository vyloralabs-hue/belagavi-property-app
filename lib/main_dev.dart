import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'bootstrap/bootstrap.dart';

void main() async {
  await initializeApp('dev');
  runApp(
    const ProviderScope(
      child: BelagaviApp(),
    ),
  );
}
