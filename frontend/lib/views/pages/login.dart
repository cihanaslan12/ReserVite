import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:prbd_2526_a08/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2526_a08/core/widgets/dialog_box.dart';
import 'package:prbd_2526_a08/models/user.dart';
import 'package:prbd_2526_a08/providers/security_provider.dart';

class Login extends ConsumerStatefulWidget {
  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final _emailController = ValidatingTextEditingController(
    validator: User.validateEmail,
    initialValue: '',
  );
  final _passwordController = ValidatingTextEditingController(
    validator: User.validatePassword,
    initialValue: '',
  );


  @override
  void initState() {
    _emailController.onAfterValidated = () => setState(() {});
    _passwordController.onAfterValidated = () => setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              _refresh();
            },
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message:
                'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                      .format(simulatedTime),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      const Icon(
                        Icons.restaurant,
                        size: 80,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Connectez-vous',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        onFieldSubmitted: (_) => _submitForm(context),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _submitForm(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Se connecter'),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                        child: const Text(
                          'Pas encore de compte ? S\'inscrire',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Raccourcis de débogage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Se connecter directement en tant que :',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _login(context, 'brlacroix@epfc.eu', password: 'Password1,');
                          },
                          icon: const Icon(Icons.person),
                          label: const Text('Client (Bruno)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _login(context, 'mamichel@epfc.eu', password: 'Password1,');
                          },
                          icon: const Icon(Icons.person),
                          label: const Text('Client (Marc)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _login(context, 'bepenelle@epfc.eu', password: 'Password1,');
                          },
                          icon: const Icon(Icons.manage_accounts),
                          label: const Text('Manager (Benoît)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _login(context, 'gedielman@epfc.eu', password: 'Password1,');
                          },
                          icon: const Icon(Icons.manage_accounts),
                          label: const Text('Manager (Geoffrey)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final action = await DialogBox(
                          title: 'Réinitialiser la base de données',
                          message: 'Êtes-vous sûr de vouloir réinitialiser la base de données?'
                              ' Cette action supprimera toutes les données et les restauraera aux valeurs par défaut.',
                          actions: const ['Annuler', 'Réinitialiser'],
                        ).show(context);

                        if (action == 'Réinitialiser') {
                          try {
                            await ref.read(securityProvider.notifier).resetDatabase();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Base de données réinitialisée avec succès'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.fixed,
                                  duration: Duration(seconds: 5),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('La réinitialisation a échouée'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.fixed,
                                    duration: Duration(seconds: 5),
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réinitialiser la base de données'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    _emailController.validate();
    _passwordController.validate();
    if(_emailController.isValid == true && _passwordController.isValid == true) {
      _login(context, _emailController.text, password: _passwordController.text);
    }
  }

  void _login(BuildContext context, String mail, {String? password}) async {
    final securityNotifier = ref.read(securityProvider.notifier);
    await securityNotifier.login(mail, password ?? mail);
    if (!mounted) return;

    if (securityNotifier.isLoggedIn) {
      final isClient = securityNotifier.isClient;
      if (isClient) {
        Navigator.pushReplacementNamed(context, '/home_client');
      } else {
        Navigator.pushReplacementNamed(context, '/my_restaurants');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email ou mot de passe incorrect'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.fixed,
            duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void _refresh() {
    _emailController.clear();
    _passwordController.clear();
    setState(() {});
  }
}