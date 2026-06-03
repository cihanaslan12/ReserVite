import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/tools/abstract_async_notifier.dart';
import '../models/reservation.dart';

final reservationDetailsManagerProvider =
AsyncNotifierProvider<ReservationDetailsManagerNotifier, Reservation>(
      () => ReservationDetailsManagerNotifier(),
);

class  ReservationDetailsManagerNotifier extends AbstractAsyncNotifier<Reservation>{
  int? _currentReservationId;

  @override
  Future<Reservation> build() async {
    return Reservation(
      id: 0,
      restaurantId: 0,
      restaurantName: '',
      city: '',
      datetime: DateTime.now(),
      numberOfGuests: 0,
      status: 'pending',
      clientName: '',
      address: '',
      specialRequests: '',
      restaurantPhone: '',
      clientPhone: '',
      clientEmail: '',
    );
  }

  @override
  Future<void> refresh() async {
    final currentId = _currentReservationId ?? state.value?.id ?? 0;
    if (currentId == 0) return;
    state = const AsyncValue.loading();
    try {
      final refreshedReservation = await Reservation.getReservationById(currentId);
      if (!ref.mounted) return;
      state = AsyncData(refreshedReservation);
    } catch (e) {
      state = AsyncValue.error(
        "Impossible de rafraîchir les détails.",
        StackTrace.current,
      );
    }
  }

  Future<void> getReservation(Reservation reservation) async {
    _currentReservationId = reservation.id;
    state = AsyncData(reservation);
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