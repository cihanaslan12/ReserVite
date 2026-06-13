import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a08/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2526_a08/models/user.dart';
import 'package:prbd_2526_a08/providers/security_provider.dart';

class Signup extends ConsumerStatefulWidget {
  @override
  ConsumerState<Signup> createState() => _SignupState();
}

class _SignupState extends ConsumerState<Signup> {
    final _fullNameController = ValidatingTextEditingController(
      validator: User.validateFullName,
      asyncValidator: User.validateFullNameUnicity,
    );

    final _emailController = ValidatingTextEditingController(
      validator: User.validateEmail,
      asyncValidator: User.validateEmailUnicity,
    );

    final _passwordController = ValidatingTextEditingController(
      validator: User.validatePassword,
    );

    late final ValidatingTextEditingController _confirmPasswordController;


  @override
  void initState() {
    super.initState();
    _fullNameController.onAfterValidated = () => setState(() {});
    _emailController.onAfterValidated = () => setState(() {});
    _passwordController.onAfterValidated = () => setState(() {});

    _confirmPasswordController = ValidatingTextEditingController(
      validator: (value) =>
          User.validateConfirmPassword(value, _passwordController.text),
    );
    _confirmPasswordController.onAfterValidated = () => setState(() {});

    _passwordController.addListener(() {
      if (_confirmPasswordController.text.isNotEmpty) {
        _confirmPasswordController.validate();
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        title: const Text('Inscription'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: _refresh,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 32),
                const Text(
                  'Créez votre compte',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _fullNameFormField(),
                      SizedBox(height: 16),
                      _emailFormField(),
                      SizedBox(height: 16),
                      _passwordFormField(),
                      SizedBox(height: 16),
                      _confirmPasswordFormField(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async => await _submitForm(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('S\'inscrire'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                    },
                  child: const Text('Déjà un compte ? Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fullNameFormField() {
    return TextFormField(
      autofocus: true,
      controller: _fullNameController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.name,
      onFieldSubmitted: (_) => _submitForm(context),
      decoration: InputDecoration(
        labelText: 'Nom complet',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.person),
        errorText: _fullNameController.errorText,
      ),
    );
  }

  Widget _emailFormField() {
    return TextFormField(
      controller: _emailController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.emailAddress,
      onFieldSubmitted: (_) => _submitForm(context),
      decoration: InputDecoration(
        labelText: 'Email',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.email),
        errorText: _emailController.errorText,
      ),
    );
  }

  Widget _passwordFormField() {
    return TextFormField(
      controller: _passwordController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      obscuringCharacter: '*',
      onFieldSubmitted: (_) => _submitForm(context),
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
        errorText: _passwordController.errorText,
      ),
    );
  }
  Widget _confirmPasswordFormField() {
    return TextFormField(
      controller: _confirmPasswordController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      obscuringCharacter: '*',
      onFieldSubmitted: (_) => _submitForm(context),
      decoration: InputDecoration(
        labelText: 'Confirmer le mot de passe',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock_outline),
        errorText: _confirmPasswordController.errorText,
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    final isValid = await _validateForm();
    if (!isValid) return;

    try {
      await ref.read(securityProvider.notifier).signup(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;

      final securityState = ref.read(securityProvider);
      if (ref
          .read(securityProvider.notifier)
          .isLoggedIn && !securityState.hasError) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/home_client', (route) => false);
      } else {
        throw Exception("Inscription invalide");
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Echec de l\'inscription. Veuillez vérifier vos informations.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.fixed,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<bool> _validateForm() async {
    await _fullNameController.validateAndWait();
    await _emailController.validateAndWait();
    await _passwordController.validateAndWait();
    await _confirmPasswordController.validateAndWait();
    return _isFormValid;
  }

  bool get _isFormValid =>
      _fullNameController.isValid == true &&
      _emailController.isValid == true &&
      _passwordController.isValid == true &&
      _confirmPasswordController.isValid == true;

  void _refresh() {
    _fullNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {});
  }
}