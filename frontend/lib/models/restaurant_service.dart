class RestaurantService {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  RestaurantService({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory RestaurantService.fromJson(Map<String, dynamic> json) {
    return RestaurantService(
      dayOfWeek: json['day_of_week'] ?? json['dayOfWeek'] ?? 1,
      startTime: json['start_time'] ?? json['startTime'] ?? '',
      endTime: json['end_time'] ?? json['endTime'] ?? '',
    );
  }
}