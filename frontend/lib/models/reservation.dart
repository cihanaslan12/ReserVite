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
  final String address;
  final String phone;
  final String specialRequests;

  Reservation({
    required this.id,
    required this.restaurantName,
    required this.city,
    required this.datetime,
    required this.numberOfGuests,
    required this.status,
    required this.clientName,
    required this.address,
    required this.phone,
    required this.specialRequests,
  });

  Reservation copyWith({
    int? id,
    String? restaurantName,
    String? city,
    DateTime? datetime,
    int? numberOfGuests,
    String? status,
    String? clientName,
    String? address,
    String? phone,
    String? specialRequests,
  }) {
    return Reservation(
      id: id ?? this.id,
      restaurantName: restaurantName ?? this.restaurantName,
      city: city ?? this.city,
      datetime: datetime ?? this.datetime,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      status: status ?? this.status,
      clientName: clientName ?? this.clientName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      specialRequests: specialRequests ?? this.specialRequests,
    );
  }

  factory Reservation.fromJson(Map<String, dynamic> json){
    return Reservation(
      id: json['id'] ?? 0,
      restaurantName: json['restaurant_name'] ?? 'Restaurant inconnu',
      city: json['city'] ?? 'Ville inconnue',
      datetime: DateTime.parse(json['datetime'] ?? DateTime.now().toIso8601String()),
      numberOfGuests: json['number_of_guests'] ?? 0,
      status: json['status'] ?? 'pending',
      clientName: json['client_name'] ?? 'Nom du clien inconnu',
      address: json['address'] ?? 'Adresse inconnue',
      phone: json['phone'] ?? 'Téléphone inconnu',
      specialRequests: json['special_requests'] ?? 'Aucune demande spéciale',
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

  static Future<Reservation> getReservationById(int reservationId) async {
    final response = await ApiClient.post(
      'get_reservation_by_id',
      body: json.encode({
        'res_id': reservationId,
      })
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return Reservation.fromJson(body[0] as Map<String, dynamic>);
    } else {
      throw Exception ('Echec lors de la récupération de cette reservation');
    }
  }

  static Future<void> cancelReservation(int reservationId) async {
    final response = await ApiClient.post(
      'cancel_reservation',
      body: json.encode({
        'res_id': reservationId,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Echec de l'annulation de la réservation.");
    }
  }
}