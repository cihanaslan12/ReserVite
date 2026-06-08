import 'dart:async';
import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/services/api_client.dart';
import '../core/tools/abstract_async_notifier.dart';
import '../models/table.dart' as model;

class AssignTablesState {
  final List<model.Table> tables;
  final Set<int> selectedTableIds;
  final bool isLoading;

  AssignTablesState({
    required this.tables,
    required this.selectedTableIds,
    this.isLoading = false,
  });

  AssignTablesState copyWith({
    List<model.Table>? tables,
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
AsyncNotifierProvider<AssignTablesNotifier, AssignTablesState>(() {
  return AssignTablesNotifier();
});

class AssignTablesNotifier extends AbstractAsyncNotifier<AssignTablesState> {
  int? _currentReservationId;

  int? get currentReservationId => _currentReservationId;

  @override
  FutureOr<AssignTablesState> build() {
    return AssignTablesState(
      tables: [],
      selectedTableIds: {},
      isLoading: false,
    );
  }

  @override
  Future<void> refresh() async {
    if (_currentReservationId != null) {
      await fetchTables();
    }
  }

  Future<void> initReservation(int reservationId) async {
    _currentReservationId = reservationId;
    state = const AsyncLoading();
    await fetchTables();
  }

  Future<void> fetchTables() async {
    if (_currentReservationId == null) {
      return;
    }

    try {
      final response = await ApiClient.post('get_tables_for_assign', body: json.encode({
        'res_id': _currentReservationId,
      }));

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        final fetchedTables = body.map((item) => model.Table.fromJson(item)).toList();

        state = AsyncData(AssignTablesState(
          tables: fetchedTables,
          selectedTableIds: {},
          isLoading: false,
        ));
      } else {
        state = AsyncError(Exception("Erreur serveur ${response.statusCode}"), StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncError(e, stack);
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

    try {
      final response = await ApiClient.post(
        'confirm_and_assign_tables',
        body: json.encode({
          'res_id': _currentReservationId,
          'table_ids': state.value!.selectedTableIds.toList(),
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (e) {
      throw "Quelque chose a mal tourné!\nRéessayez plus tard.";
    }
  }
}