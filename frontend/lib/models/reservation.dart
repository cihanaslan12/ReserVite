import 'dart:convert';
import 'package:prbd_2526_a08/core/services/api_client.dart';

class Reservation {
  final int id;
  final String restaurantName;
  final String city;
  final DateTime datetime;
  final int numberOfGuests;
  final String status;
  final String clientName;

  Reservation({
    required this.id,
    required this.restaurantName,
    required this.city,
    required this.datetime,
    required this.numberOfGuests,
    required this.status,
    required this.clientName,

  });

  factory Reservation.fromJson(Map<String, dynamic> json){
    return Reservation(
      id: json['id'] ?? 0,
      restaurantName: json['restaurant_name'] ?? 'Restaurant inconnu',
      city: json['city'] ?? 'Ville inconnue',
      datetime: DateTime.parse(json['datetime'] ?? DateTime.now().toIso8601String()),
      numberOfGuests: json['number_of_guests'] ?? 0,
      status: json['status'] ?? 'pending',
      clientName: json['client_name'] ?? 'Nom du clien inconnu',
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

  static Future<List<Reservation>> getRestaurantReservations(int restaurantId) async {
    final response = await ApiClient.post(
      'get_restaurant_reservations',
      body: json.encode({
        'restaurant_id': restaurantId,
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Reservation.fromJson(item)).toList();
    } else {
      throw Exception ('Echec lors de la récupération des réservations de ce restaurant');
    }
  }
}