import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:prbd_2526_a08/app/my_app.dart';
import 'package:prbd_2526_a08/core/tools/params.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Params.init();
  await initializeDateFormatting('fr_FR', null);
  runApp(
    ProviderScope(
      child: MyApp()
    )
  );
}

// class TestPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: .fromSeed(seedColor: Colors.blue),
//       ),
//       home: Scaffold(
//         appBar: AppBar(title: Text('Test Page')),
//         body: Center(
//           child: Text('Welcome group a08!', style: TextStyle(fontSize: 24)),
//         ),
//       ),
//     );
//   }
// }
