import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_a08/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a08/models/reservation.dart';

final restManResProvider =
    AsyncNotifierProvider<RestManResNotifier, List<Reservation>>(
        () => RestManResNotifier(),
    );

class RestManResNotifier extends AbstractAsyncNotifier<List<Reservation>> {
  int? _currentRestaurantId;

  @override
  Future<List<Reservation>> build() async {
    return [];
  }

  @override
  Future<void> refresh() async {
    if (_currentRestaurantId != null) {
      await getRestaurantReservations(_currentRestaurantId!);
    }
  }

  Future<void> getRestaurantReservations(int restaurantId) async {
    _currentRestaurantId = restaurantId;
    state = const AsyncValue.loading();
    try {
      final reservations = await Reservation.getRestaurantReservations(restaurantId);
      state = AsyncData(reservations);
    } catch (e) {
      state = AsyncValue.error(
        "Quelque chose a mal tourné!\nRéessayez plus tard.",
        StackTrace.current,
      );
    }
  }
}