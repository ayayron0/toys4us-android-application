import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'firebase_options.dart';
import 'core/local_notification_service.dart';
import 'features/auth/logon.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if(!kIsWeb && (Platform.isAndroid || Platform.isIOS)){
    Stripe.publishableKey = 'pk_test_51TVHQC2fXz6tcjzdtnfzlibOIqLh085abRndwrPXHqMKzDeTplb93NyzYJrUoythAyt1zHSJGEncdjG0jX0IuQ8n00EWwhnyTf';
    await Stripe.instance.applySettings();
  }

  await LocalNotificationService.initialize();

  runApp(const MyApp());
}
