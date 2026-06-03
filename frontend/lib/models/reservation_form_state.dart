import '../models/reservation_slot.dart';

class ReservationFormState {
  final DateTime selectedDate;
  final String? selectedTimeSlot;
  final int numberOfGuests;
  final String specialRequests;
  final List<ReservationSlot> availableSlots;
  final bool isLoading;
  final String? errorMessage;

  ReservationFormState({
    required this.selectedDate,
    this.selectedTimeSlot,
    required this.numberOfGuests,
    required this.specialRequests,
    required this.availableSlots,
    this.isLoading = false,
    this.errorMessage,
  });

  ReservationFormState copyWith({
    DateTime? selectedDate,
    String? selectedTimeSlot,
    int? numberOfGuests,
    String? specialRequests,
    List<ReservationSlot>? availableSlots,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReservationFormState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      specialRequests: specialRequests ?? this.specialRequests,
      availableSlots: availableSlots ?? this.availableSlots,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}