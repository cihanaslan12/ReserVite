import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_a08/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a08/models/reservation.dart';
import 'package:prbd_2526_a08/providers/security_provider.dart';

final myReservationsProvider =
    AsyncNotifierProvider<MyReservationsNotifier, List<Reservation>>(
     () => MyReservationsNotifier(),
    );

class MyReservationsNotifier extends AbstractAsyncNotifier<List<Reservation>> {
  @override
  Future<List<Reservation>> build() async {
    ref.watch(securityProvider);

    state = AsyncData([]);
    state = AsyncLoading();
    try {
      return await Reservation.getMyReservations();
    } catch (e) {
      throw "Quelque chose a mal tourné!\nRéessayez plus tard.";
    }
  }

  @override
  Future<void> refresh() async {
    await getMyReservations();
  }

  Future<void> getMyReservations() async {
    state = const AsyncValue.loading();
    try {
      final reservations = await Reservation.getMyReservations();
      state = AsyncData(reservations);
    } catch (e) {
      state = AsyncValue.error(
        "Quelque chose a mal tourné!\nRéessayez plus tard.",
        StackTrace.current,
      );
    }
  }
}