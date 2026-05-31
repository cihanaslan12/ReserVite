import 'dart:convert';
import 'package:prbd_2526_a08/core/services/api_client.dart';

class Reservation {
  final int id;
  final String restaurantName;
  final String city;
  final DateTime datetime;
  final int numberOfGuests;
  final String status;

  Reservation({
    required this.id,
    required this.restaurantName,
    required this.city,
    required this.datetime,
    required this.numberOfGuests,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json){
    return Reservation(
      id: json['id'] ?? 0,
      restaurantName: json['restaurant_name'] ?? 'Restaurant inconnu',
      city: json['city'] ?? 'Ville inconnue',
      datetime: DateTime.parse(json['datetime'] ?? DateTime.now().toIso8601String()),
      numberOfGuests: json['number_of_guests'] ?? 0,
      status: json['status'] ?? 'pending',
    );
  }

  static Future<List<Reservation>> getMyReservations() async {
    final response = await ApiClient.post(
        'get_my_reservations');
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Reservation.fromJson(item)).toList();
    } else {
      throw Exception ('Echec lors de la récupération des réservations.');
    }
  }
}