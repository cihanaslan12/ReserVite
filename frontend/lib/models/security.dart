import 'dart:convert';

import 'package:prbd_2526_a08/core/services/api_client.dart';

class Security {
  static Future<String?> login(String email, String password) async {
    final response = await ApiClient.post(
      'login',
      body: json.encode({'email': email, 'password': password}),
      anonymous: true,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to login');
    }
    final dynamic body = json.decode(response.body);
    String token = body['token'];
    return token;
  }

  static Future<bool> checkFullNameAvailable({String? fullName}) async {
    final response = await ApiClient.post(
      'is_full_name_available',
      body: json.encode({'full_name': fullName}),
      anonymous: true,
    );
    final dynamic body = json.decode(response.body);
    if (response.statusCode != 200) {
      throw Exception('Failed to validate full_name\n\n${body['message']}');
    }
    return body;
  }

  static Future<bool> checkEmailAvailable({String? email}) async {
    final response = await ApiClient.post(
      'is_email_available',
      body: json.encode({'email': email}),
      anonymous: true,
    );
    final dynamic body = json.decode(response.body);
    if (response.statusCode != 200) {
      throw Exception('Failed to validate email\n\n${body['message']}');
    }
    return body;
  }

  static Future<void> signup({
    required String fullName,
    required String email,
    required String password,
    String? phone
  }) async {
    final response = await ApiClient.post(
      'signup',
      body: json.encode({'full_name': fullName, 'email': email, 'password': password, 'phone': phone}),
      anonymous: true,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to signup\n\n${response.body}');
    }
  }

  static Future<void> resetDatabase() async {
    final response = await ApiClient.post(
      'reset_database',
      anonymous: true,
    );
    if (response.statusCode != 204) {
      throw Exception ('Failed to reset database \n\n${response.body}');
    }
  }
}
