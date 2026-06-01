import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/tools/abstract_async_notifier.dart';
import '../models/reservation.dart';

final reservationDetailsProvider =
    AsyncNotifierProvider<ReservationDetailsNotifier, Reservation>(
        () => ReservationDetailsNotifier(),
    );

class  ReservationDetailsNotifier extends AbstractAsyncNotifier<Reservation>{
  late Reservation _currentReservation;

  @override
  Future<Reservation> build() async {
    return Reservation(
      id: 0,
      restaurantName: '',
      city: '',
      datetime: DateTime.now(),
      numberOfGuests: 0,
      status: 'pending',
      clientName: '',
      address: '',
      phone: '',
      specialRequests: '',
    );
  }

  @override
  Future<void> refresh() async {
    final currentId = state.value!.id;
    state = const AsyncValue.loading();
    try {
      final refreshedReservation = await Reservation.getReservationById(currentId);
      _currentReservation = refreshedReservation;
      state = AsyncData(refreshedReservation);
    } catch (e) {
      state = AsyncValue.error(
        "Impossible de rafraîchir les détails.",
        StackTrace.current,
      );
    }
  }

  Future<void> getReservation(Reservation reservation) async {
    state = AsyncData(reservation);
    _currentReservation = reservation;
  }

  Future<bool> cancelReservation() async {
    if (state.value == null) return false;
    final currentReservation = state.value!;
    state = const AsyncValue.loading();
    try {
      await Reservation.cancelReservation(currentReservation.id);
      state = AsyncData(currentReservation.copyWith(status: 'cancelled'));
      return true;
    } catch (e) {
      state = AsyncValue.error(
        "Impossible d'annuler la réservation.",
        StackTrace.current,
      );
      return false;
    }
  }
}