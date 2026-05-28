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
    if (email == null || email.isEmpty) {
      return 'required';
    } else if (email.length < 3) {
      return 'Veuillez entrer une addresse email valide';
    } else {
      return null;
    }
  }

  static Future<String?> validateEmailUnicity(String? value) async {
    var res = await Security.checkEmailAvailable(email: value?.trim());
    return res ? null : 'Cet email est déjà utilisé';
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    } else if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    String? passwordError = validatePassword(value);
    if (passwordError != null) {
      return 'Veuillez confirmer votre mot de passe';
    } else if (value != password) {
      return 'Les deux mots de passe doivent être identiques';
    }
      return null;
  }
}
