import 'dart:async';
import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a08/core/tools/abstract_async_notifier.dart';
import '../../core/services/api_client.dart';
import '../models/reservation_slot.dart';
import 'my_restaurants_provider.dart';

final DateTime simulatedDate = DateTime(2024, 12, 4);

class ReservationFormState {
  final DateTime selectedDate;
  final String? selectedTimeSlot;
  final int numberOfGuests;
  final String specialRequests;
  final List<ReservationSlot> availableSlots;
  final bool isLoading;

  ReservationFormState({
    required this.selectedDate,
    this.selectedTimeSlot,
    required this.numberOfGuests,
    required this.specialRequests,
    required this.availableSlots,
    this.isLoading = false,
  });

  ReservationFormState copyWith({
    DateTime? selectedDate,
    String? selectedTimeSlot,
    int? numberOfGuests,
    String? specialRequests,
    List<ReservationSlot>? availableSlots,
    bool? isLoading,
  }) {
    return ReservationFormState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      specialRequests: specialRequests ?? this.specialRequests,
      availableSlots: availableSlots ?? this.availableSlots,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final reservationFormProvider =
AsyncNotifierProvider<ReservationFormNotifier, ReservationFormState>(
      () => ReservationFormNotifier(),
);

class ReservationFormNotifier extends AbstractAsyncNotifier<ReservationFormState> {
  int? _restaurantId;

  @override
  Future<ReservationFormState> build() async {
    return ReservationFormState(
      selectedDate: simulatedDate,
      numberOfGuests: 2,
      specialRequests: '',
      availableSlots: [],
    );
  }

  @override
  Future<ReservationFormState> refresh() async {
    final initialState = await build();
    state = AsyncData(initialState);
    if(_restaurantId != null) {
      await updateSlotStatus();
    }
    return state.value!;
  }

  Future<void> initData(int restaurantId, {int? existingGuests, String? existingRequests, DateTime? existingDate, String? existingSlot}) async {
    _restaurantId = restaurantId;

    if (existingSlot != null) {
      state = AsyncData(ReservationFormState(
        selectedDate: existingDate ?? simulatedDate,
        numberOfGuests: existingGuests ?? 2,
        specialRequests: existingRequests ?? '',
        selectedTimeSlot: existingSlot,
        availableSlots: [],
        isLoading: true,
      ));
    } else {
      state = AsyncData(ReservationFormState(
        selectedDate: simulatedDate,
        numberOfGuests: 2,
        specialRequests: '',
        availableSlots: [],
      ));
    }

    await updateSlotStatus();
  }

  Future<void> changeDate(DateTime newDate) async {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(
      selectedDate: newDate,
      selectedTimeSlot: null,
    ));
    await updateSlotStatus();
  }

  Future<void> changeNumberOfGuests(int count) async {
    if (state.value == null || count < 1) return;
    state = AsyncData(state.value!.copyWith(numberOfGuests: count));
    await updateSlotStatus();
  }

  void selectTimeSlot(String timeStr) {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(selectedTimeSlot: timeStr));
  }

  void updateSpecialRequests(String text) {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(specialRequests: text));
  }

  Future<void> updateSlotStatus() async {
    if (_restaurantId == null || state.value == null) return;
    state = AsyncData(state.value!.copyWith(isLoading: true));

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(state.value!.selectedDate);

      final response = await ApiClient.post('get_reservation_slot_status',
          body:json.encode({
            'rest_id': _restaurantId,
            'date': formattedDate,
            'nb_of_guests': state.value!.numberOfGuests,
          }));
      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        final slots = body.map((item) => ReservationSlot.fromJson(item)).toList();

        state = AsyncData(state.value!.copyWith(
          availableSlots: slots,
          isLoading: false,
        ));
      } else {
        state = AsyncData(state.value!.copyWith(isLoading: false));
      }
    } catch (e) {
      state = AsyncData(state.value!.copyWith(isLoading: false));
    }
  }

  Future<bool> submitReservation({int? editReservationId}) async {
    if (_restaurantId == null || state.value == null || state.value!.selectedTimeSlot == null) {
      return false;
    }

    state = AsyncData(state.value!.copyWith(isLoading: true));

    final timeParts = state.value!.selectedTimeSlot!.split(':');
    final finalDateTime = DateTime(
      state.value!.selectedDate.year,
      state.value!.selectedDate.month,
      state.value!.selectedDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    try {
      if (editReservationId == null) {
        final response = await ApiClient.post('add_reservation',
            body: json.encode({
              'rest_id': _restaurantId,
              'res_time': finalDateTime.toIso8601String(),
              'nb_of_guests': state.value!.numberOfGuests,
              'spec_requ': state.value!.specialRequests.trim().isEmpty ? null : state.value!.specialRequests,
            }));
        state = AsyncData(state.value!.copyWith(isLoading: false));
        return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
      } else {
        final response = await ApiClient.post('edit_reservation',
            body: json.encode({
              'res_id': editReservationId,
              'res_time': finalDateTime.toIso8601String(),
              'nb_of_guests': state.value!.numberOfGuests,
              'new_status': 'pending',
              'spec_requ': state.value!.specialRequests.trim().isEmpty ? null : state.value!.specialRequests,
            }));

        state = AsyncData(state.value!.copyWith(isLoading: false));

        ref.invalidate(myRestaurantsProvider);

        return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
      }
    } catch (e) {
      state = AsyncData(state.value!.copyWith(isLoading: false));
      return false;
    }
  }
}