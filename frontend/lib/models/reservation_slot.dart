class ReservationSlot {
  final String slotTime;
  final bool isClosed;
  final bool alreadyReserved;
  final int availableCapacity;
  final bool isOverbooked;

  ReservationSlot({
    required this.slotTime,
    required this.isClosed,
    required this.alreadyReserved,
    required this.availableCapacity,
    required this.isOverbooked,
  });

  factory ReservationSlot.fromJson(Map<String, dynamic> json) {
    return ReservationSlot(
      slotTime: json['slot_time'] ?? '',
      isClosed: json['is_closed'] ?? false,
      alreadyReserved: json['already_reserved'] ?? false,
      availableCapacity: json['available_capacity'] ?? 0,
      isOverbooked: json['is_overbooked'] ?? false
    );
  }
}