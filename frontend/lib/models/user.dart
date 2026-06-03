import 'package:prbd_2526_a08/models/security.dart';

class User {
  static String? validateFullName(String? fullName) {
    if (fullName!.length < 5) {
      return 'Le nom complet doit contenir au moins 5 caractères';
    } else {
      return null;
    }
  }

  static Future<String?> validateFullNameUnicity(String? value) async {
    var res = await Security.checkFullNameAvailable(fullName: value?.trim());
    return res ? null : 'Ce nom complet est déjà utilisé';
  }

  static String? validateEmail(String? email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email!)) {
      return 'Veuillez entrer une adresse email valide';
    }
    return null;
  }

  static Future<String?> validateEmailUnicity(String? value) async {
    var res = await Security.checkEmailAvailable(email: value?.trim());
    return res ? null : 'Cet email est déjà utilisé';
  }

  static String? validatePassword(String? value) {
    final upperRegex = RegExp(r'[A-Z]');
    final numberRegex = RegExp(r'[\d]');
    final specRegex = RegExp(r'[,;.:!?_]');
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    } else if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    } else if (!upperRegex.hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une lettre majuscule';
    } else if (!specRegex.hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins un caractère spécial (,;.:!?_)';
    } else if (!numberRegex.hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    } else if (value != password) {
      return 'Les deux mots de passe doivent être identiques';
    }
   return null;
  }
}
