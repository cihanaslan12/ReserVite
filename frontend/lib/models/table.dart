import 'dart:convert';

import 'package:prbd_2526_a08/core/services/api_client.dart';

class Table {
  final int id;
  final String name;
  final int capacity;
  final bool isOccupied;

  Table({
    required this.id,
    required this.name,
    required this.capacity,
    required this.isOccupied,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['table_id'] ?? json['id'] as int,
      name: json['table_name'] ?? json['name'] as String,
      capacity: json['capacity'] as int,
      isOccupied: json['is_occupied'] ?? false,
    );
  }

  static Future<List<Table>> getRestaurantTables(int reservationId) async {
    final response = await ApiClient.post(
      'get_tables_for_assign',
      body: json.encode({
        'res_id': reservationId,
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((item) => Table.fromJson(item)).toList();
    } else {
      throw Exception('Echec lors de la récupération des tables.');
      }
  }

  static Future<bool> confirmAssignment(int reservationId, List<int> assignedTables) async {
    final response = await ApiClient.post(
      'confirm_and_assign_tables',
      body: json.encode({
        'res_id': reservationId,
        'table_ids': assignedTables,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      return true;
    } else {
      throw "Quelque chose a mal tourné!\nRéessayez plus tard.";
    }
  }
}