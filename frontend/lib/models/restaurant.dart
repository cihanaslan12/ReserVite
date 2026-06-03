import 'dart:convert';
import 'package:prbd_2526_a08/core/services/api_client.dart';
import 'package:prbd_2526_a08/models/restaurant_service.dart';

class Restaurant {
  final int id;
  final String restaurantName;
  final String address;
  final String city;
  final double rating;
  final int priceRange;
  final DateTime? lastReservation;
  final int inPending;
  final String? description;
  final List<RestaurantService> services;

  Restaurant({
    required this.id,
    required this.restaurantName,
    required this.address,
    required this.city,
    required this.rating,
    required this.priceRange,
    this.lastReservation,
    required this.inPending,
    this.description,
    required this.services,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json){
    var servicesList = json['services'] as List? ?? [];
    return Restaurant(
      id: json['id'] ?? 0,
      restaurantName: json['restaurant_name'] ?? 'Restaurant inconnu',
      address: json ['address'] ?? '',
      city: json['city'] ?? 'Ville inconnue',
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 0.0,
      priceRange: json['price_range'] ?? 1,
      lastReservation: json['last_reservation'] != null ? DateTime.parse(json['last_reservation']) : null,
      inPending: json['in_pending'] != null ? int.parse(json['in_pending'].toString()) : 0,
      description: json['description'] ?? '',
      services: servicesList.map((s) => RestaurantService.fromJson(s)).toList(),
    );
  }

  String getFormattedServicesHours(int dayOfWeek) {
    final dayOfService = services.where((s) => s.dayOfWeek == dayOfWeek).toList();
    if (dayOfService.isEmpty) return 'Fermé';
    return dayOfService.map((s) => '${s.startTime} - ${s.endTime}').join(', ');
  }

  static Future<List<Restaurant>> getMyRestaurants() async {
    try {
      final response = await ApiClient.get('get_my_restaurants');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        throw Exception ('Echec lors de la récupération des restaurants');
      }
    } catch (e) {
      throw "Quelque chose a mal tourné!\nRéessayez plus tard.";
    }
  }

  static Future<List<Restaurant>> getAllRestaurants() async {
    final response = await ApiClient.post(
      'get_all_restaurants');
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Restaurant.fromJson(item)).toList();
    } else {
      throw Exception ('Echec lors de la récupération des restaurants');
    }
  }
}