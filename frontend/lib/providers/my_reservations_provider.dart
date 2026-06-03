import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_a08/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a08/models/reservation.dart';
import 'package:prbd_2526_a08/providers/security_provider.dart';

class MyReservationsState {
  final List<Reservation> reservations;
  final String currentFilter;

  MyReservationsState({
    required this.reservations,
    required this.currentFilter,
  });

  MyReservationsState copyWith({
    List<Reservation>? reservations,
    String? currentFilter,
  }) {
    return MyReservationsState(
      reservations: reservations ?? this.reservations,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

final myReservationsProvider =
    AsyncNotifierProvider.autoDispose<MyReservationsNotifier, MyReservationsState>(
     () => MyReservationsNotifier(),
    );

final filteredMyReservationsProvider = Provider<AsyncValue<List<Reservation>>>((ref) {
  final stateAsync = ref.watch(myReservationsProvider);

  return stateAsync.whenData((state) {
    if (state.currentFilter == 'all') {
      return state.reservations;
    }
    return state.reservations.where((res) => res.status == state.currentFilter).toList();
  });
});

class MyReservationsNotifier extends AbstractAsyncNotifier<MyReservationsState> {
  @override
  Future<MyReservationsState> build() async {
    try {
      final reservations = await Reservation.getMyReservations();
      return MyReservationsState(reservations: reservations, currentFilter: 'pending');
    } catch (e) {
      throw "Quelque chose a mal tourné!\nRéessayez plus tard.";
    }
  }

  void setFilter(String newFilter) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(currentFilter: newFilter));
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
      final activeFilter = state.value?.currentFilter ?? 'all';
      state = AsyncData(MyReservationsState(reservations: reservations, currentFilter: activeFilter));
    } catch (e) {
      state = AsyncValue.error(
        "Quelque chose a mal tourné!\nRéessayez plus tard.",
        StackTrace.current,
      );
    }
  }
}