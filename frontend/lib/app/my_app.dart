import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:prbd_2526_a08/providers/security_provider.dart';

import 'package:prbd_2526_a08/views/pages/home_client.dart';
import 'package:prbd_2526_a08/views/pages/login.dart';
import 'package:prbd_2526_a08/views/pages/my_restaurants.dart';
import 'package:prbd_2526_a08/views/pages/reservation_form.dart';
import 'package:prbd_2526_a08/views/pages/search_restaurants.dart';
import 'package:prbd_2526_a08/views/pages/signup.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityNotifier = ref.read(securityProvider.notifier);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReserVite',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: securityNotifier.isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => Login(),
        '/signup': (context) => Signup(),
        '/home_client': (context) => HomeClient(),
        '/search_restaurants': (context) => SearchRestaurants(),
        '/reservation_form': (context) => ReservationForm(),
        '/my_restaurants': (context) => MyRestaurants(),
      }
    );
  }
}