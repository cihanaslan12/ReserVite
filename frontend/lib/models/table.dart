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
      isOccupied: json['is_occupied'] ?? false as bool,
    );
  }
}