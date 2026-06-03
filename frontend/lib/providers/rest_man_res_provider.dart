import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_a08/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a08/models/reservation.dart';

class RestManResState {
  final List<Reservation> reservations;
  final String currentFilter;

  RestManResState({
    required this.reservations,
    required this.currentFilter,
  });

  RestManResState copyWith({
    List<Reservation>? reservations,
    String? currentFilter,
  }) {
    return RestManResState(
      reservations: reservations ?? this.reservations,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

final restManResProvider =
    AsyncNotifierProvider.autoDispose<RestManResNotifier, RestManResState>(
          () => RestManResNotifier(),
    );

final filteredReservationsProvider = Provider<AsyncValue<List<Reservation>>>((ref) {
  final stateAsync = ref.watch(restManResProvider);

  return stateAsync.whenData((state) {
    if (state.currentFilter == 'all') {
      return state.reservations;
    }
    return state.reservations.where((res) => res.status == state.currentFilter).toList();
  });
});

class RestManResNotifier extends AbstractAsyncNotifier<RestManResState> {
  int? _currentRestaurantId;

  @override
  Future<RestManResState> build() async {
    return RestManResState(reservations: [], currentFilter: 'all');
  }

  void setFilter(String newFilter) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(currentFilter: newFilter));
    }
  }

  @override
  Future<void> refresh() async {
    if (_currentRestaurantId != null) {
      await getRestaurantReservations(_currentRestaurantId!);
    }
  }

  Future<void> getRestaurantReservations(int restaurantId) async {
    state = const AsyncValue.loading();
    try {
      final reservations = await Reservation.getRestaurantReservations(restaurantId);
      if (!ref.mounted) return;
      if (state.hasValue) {
        state = AsyncData(state.value!.copyWith(reservations: reservations));
      } else {
        state = AsyncData(RestManResState(reservations: reservations, currentFilter: 'all'));
      }
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }
}