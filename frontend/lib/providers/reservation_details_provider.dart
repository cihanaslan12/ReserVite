import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_a08/providers/my_reservations_provider.dart';
import '../core/tools/abstract_async_notifier.dart';
import '../models/reservation.dart';

final reservationDetailsProvider =
    AsyncNotifierProvider<ReservationDetailsNotifier, Reservation>(
        () => ReservationDetailsNotifier(),
    );

class  ReservationDetailsNotifier extends AbstractAsyncNotifier<Reservation>{
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
      restaurantPhone: '',
      clientPhone: '',
      specialRequests: '',
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

  Future<bool> cancelReservation(int reservationId) async {
    if (state.value == null) return false;
    state = const AsyncValue.loading();
    try {
      await Reservation.cancelReservation(reservationId);
      ref.invalidate(myReservationsProvider);
      state = AsyncData(state.value!.copyWith(status: 'cancelled'));
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