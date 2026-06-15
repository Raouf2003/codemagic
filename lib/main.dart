import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyA76dIrldA7VZ6Mj9mkKiS4yN9pzY8GA7g',
        authDomain: 'loris-636db.firebaseapp.com',
        projectId: 'loris-636db',
        storageBucket: 'loris-636db.firebasestorage.app',
        messagingSenderId: '530130998004',
        appId: '1:530130998004:web:b77725e68997f8fff984a1',
      ),
    );
  } catch (e) {
    debugPrint('[FCM] Firebase init error (notifications disabled): $e');
  }
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('[FCM] Notification init error: $e');
  }
  runApp(const AppProviders());
}
