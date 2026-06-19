import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_a08/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a08/models/table.dart';
import 'package:prbd_2526_a08/providers/reservation_details_manager_provider.dart';
import 'package:prbd_2526_a08/providers/rest_man_res_provider.dart';

class AssignTablesState {
  final List<Table> tables;
  final Set<int> selectedTableIds;
  final bool isLoading;

  AssignTablesState({
    required this.tables,
    required this.selectedTableIds,
    this.isLoading = false,
  });

  AssignTablesState copyWith({
    List<Table>? tables,
    Set<int>? selectedTableIds,
    bool? isLoading,
  }) {
    return AssignTablesState(
      tables: tables ?? this.tables,
      selectedTableIds: selectedTableIds ?? this.selectedTableIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final assignTablesProvider =
  AsyncNotifierProvider<AssignTablesNotifier, AssignTablesState>(
          () => AssignTablesNotifier(),
  );

class AssignTablesNotifier extends AbstractAsyncNotifier<AssignTablesState> {
  int? _currentReservationId;
  int? _currentRestaurantId;

  int? get currentReservationId => _currentReservationId;
  int? get currentRestaurantId => _currentRestaurantId;

  @override
  Future<AssignTablesState> build() async {
    return AssignTablesState(
      tables: [],
      selectedTableIds: {},
      isLoading: false,
    );
  }

  @override
  Future<void> refresh() async {
    if (_currentReservationId != null) {
      await getRestaurantTables(_currentReservationId!);
    } else {
      throw "Refresh impossible.";
    }
  }

  Future<void> initReservation(int reservationId, int restaurantId) async {
    if (_currentReservationId == reservationId && state.hasValue && state.value!.tables.isNotEmpty) {
      return;
    }
    _currentReservationId = reservationId;
    _currentRestaurantId = restaurantId;
    await getRestaurantTables(reservationId);
  }

  void resetState() {
    _currentReservationId = null;
    _currentRestaurantId = null;
    state = AsyncData(AssignTablesState(
      tables: [],
      selectedTableIds: {},
      isLoading: false,
    ));
  }

  Future<void> getRestaurantTables(int reservationId) async {
    state = const AsyncValue.loading();
    try {
      final restaurantTables = await Table.getRestaurantTables(reservationId);
      state = AsyncData(AssignTablesState(
          tables: restaurantTables,
          selectedTableIds: state.value?.selectedTableIds ?? {},
          isLoading: false
      ));
    } catch (e) {
      state = AsyncValue.error(
        "Quelque chose à mal tourné!\nRéessayez plus tard.",
        StackTrace.current,
      );
    }
  }

  void toggleTable(int tableId) {
    if (state.value == null) return;

    final updatedSelections = Set<int>.from(state.value!.selectedTableIds);
    if (updatedSelections.contains(tableId)) {
      updatedSelections.remove(tableId);
    } else {
      updatedSelections.add(tableId);
    }
    state = AsyncData(state.value!.copyWith(selectedTableIds: updatedSelections));
  }

  Future<bool> confirmAssignment() async {
    if (_currentReservationId == null || state.value == null || state.value!.selectedTableIds.isEmpty) {
      return false;
    }
    state = AsyncValue.data(state.value!.copyWith(isLoading: true));
    try {
      await Table.confirmAssignment(_currentReservationId!, state.value!.selectedTableIds.toList());
      state = AsyncData(state.value!.copyWith(
          isLoading: false
      ));
      return true;
    } catch (e) {
      state = AsyncValue.error(
        "Impossible de confirmer les tables pour cette réservation.",
        StackTrace.current,
      );
      state = AsyncData(state.value!.copyWith(isLoading: false));
      return false;
    }
  }
}