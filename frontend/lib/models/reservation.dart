import 'dart:convert';
import 'package:prbd_2526_a08/core/services/api_client.dart';

class Reservation {
  final int id;
  final int restaurantId;
  final String restaurantName;
  final String city;
  final DateTime datetime;
  final int numberOfGuests;
  final String status;
  final String clientName;
  final String address;
  final String specialRequests;
  final String restaurantPhone;
  final String clientPhone;
  final String clientEmail;
  final bool isVip;

  Reservation({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.city,
    required this.datetime,
    required this.numberOfGuests,
    required this.status,
    required this.clientName,
    required this.address,
    required this.specialRequests,
    required this.restaurantPhone,
    required this.clientPhone,
    required this.clientEmail,
    required this.isVip,
  });

  Reservation copyWith({
    int? id,
    int? restaurantId,
    String? restaurantName,
    String? city,
    DateTime? datetime,
    int? numberOfGuests,
    String? status,
    String? clientName,
    String? address,
    String? specialRequests,
    String? restaurantPhone,
    String? clientPhone,
    String? clientEmail,
    bool? isVip,
  }) {
    return Reservation(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      city: city ?? this.city,
      datetime: datetime ?? this.datetime,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      status: status ?? this.status,
      clientName: clientName ?? this.clientName,
      address: address ?? this.address,
      specialRequests: specialRequests ?? this.specialRequests,
      restaurantPhone: restaurantPhone ?? this.restaurantPhone,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      isVip: isVip ?? this.isVip,
    );
  }

  factory Reservation.fromJson(Map<String, dynamic> json){
    return Reservation(
      id: json['id'] ?? 0,
      restaurantId: json['restaurant_id'] ?? json['restaurant'] ?? 0,
      restaurantName: json['restaurant_name'] ?? 'Restaurant inconnu',
      city: json['city'] ?? 'Ville inconnue',
      datetime: DateTime.parse(json['datetime'] ?? DateTime.now().toIso8601String()),
      numberOfGuests: json['number_of_guests'] ?? 0,
      status: json['status'] ?? 'pending',
      clientName: json['client_name'] ?? 'Inconnu',
      address: json['address'] ?? 'Adresse inconnue',
      specialRequests: json['special_requests'] ?? 'Aucune demande spéciale',
      restaurantPhone: json['restaurant_phone'] ?? 'Non renseigné',
      clientPhone: json['client_phone'] ?? 'Non renseigné',
      clientEmail: json['client_email'] ?? json['email'] ?? 'Non renseigné',
      isVip: json['is_vip'] ?? false,
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

  static Future<void> toggleReservationVip(int reservationId) async {
    final response = await ApiClient.post(
      'toggle_reservation_vip',
      body: json.encode({
        'res_id': reservationId,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Echec du changement du mode VIP de la réservation.");
    }
  }
}