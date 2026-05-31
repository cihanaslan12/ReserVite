import 'dart:convert';
import 'package:prbd_2526_a08/core/services/api_client.dart';

class Restaurant {
  final int id;
  final String restaurantName;
  final String city;
  final double rating;
  final int priceRange;
  final DateTime? lastReservation;
  final int inPending;

  Restaurant({
    required this.id,
    required this.restaurantName,
    required this.city,
    required this.rating,
    required this.priceRange,
    this.lastReservation,
    required this.inPending,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json){
    return Restaurant(
      id: json['id'] ?? 0,
      restaurantName: json['restaurant_name'] ?? 'Restaurant inconnu',
      city: json['city'] ?? 'Ville inconnue',
      rating: (json['rating'] ?? 0.0).toDouble(),
      priceRange: json['price_range'] ?? 1,
      lastReservation: json['last_reservation'] != null ? DateTime.parse(json['last_reservation']) : null,
      inPending: json['in_pending'] ?? 0,
    );
  }

  static Future<List<Restaurant>> getMyRestaurants() async {
    final response = await ApiClient.post(
      'get_my_restaurants');
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Restaurant.fromJson(item)).toList();
    } else {
      throw Exception ('Echec lors de la récupération des restaurants');
    }
  }
}