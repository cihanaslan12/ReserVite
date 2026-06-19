import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a08/models/reservation.dart';
import 'package:prbd_2526_a08/providers/assign_tables_provider.dart';
import 'package:prbd_2526_a08/providers/my_restaurants_provider.dart';
import 'package:prbd_2526_a08/providers/reservation_details_manager_provider.dart';
import 'package:prbd_2526_a08/providers/rest_man_res_provider.dart';

class AssignTables extends ConsumerWidget {
  const AssignTables({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservation = ModalRoute.of(context)!.settings.arguments as Reservation;

    final state = ref.watch(assignTablesProvider);
    final notifier = ref.read(assignTablesProvider.notifier);

    if (notifier.currentReservationId != reservation.id) {
      Future.delayed(Duration.zero, () {
        notifier.initReservation(reservation.id, reservation.restaurantId);
      });
    }

    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    final tablesList = state.value?.tables ?? [];
    final selectedIds = state.value?.selectedTableIds ?? <int>{};
    final bool isScreenLoading = state.isLoading || (state.value?.isLoading ?? false);

    int totalSelectedCapacity = tablesList
        .where((t) => selectedIds.contains(t.id))
        .fold(0, (sum, t) => sum + t.capacity);

    bool isCapacitySufficient = totalSelectedCapacity >= reservation.numberOfGuests;
    bool hasSelections = selectedIds.isNotEmpty;

    final String formattedDate = DateFormat("dd/MM/yyyy", "fr_FR").format(reservation.datetime);
    final String formattedTime = DateFormat("HH:mm", "fr_FR").format(reservation.datetime);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Assigner des tables'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => notifier.refresh(),
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR').format(simulatedTime),
                  style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (isScreenLoading) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Réservation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('${reservation.numberOfGuests} convives', style: const TextStyle(fontSize: 15)),
                      Text('$formattedDate à $formattedTime', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ),
            if (hasSelections)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  color: isCapacitySufficient ? Colors.green.shade50 : Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: isCapacitySufficient ? Colors.green : Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          isCapacitySufficient ? Icons.check_circle : Icons.warning,
                          color: isCapacitySufficient ? Colors.green[700] : Colors.orange[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Capacité totale: $totalSelectedCapacity places',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isCapacitySufficient
                                    ? 'Capacité suffisante pour ${reservation.numberOfGuests} convives'
                                    : 'Capacité insuffisante: $totalSelectedCapacity places pour ${reservation.numberOfGuests} convives',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isCapacitySufficient ? Colors.green.shade700 : Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sélectionnez les tables disponibles',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: isScreenLoading && tablesList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : tablesList.isEmpty
                  ? const Center(child: Text('Aucune table n\'est configurée pour ce restaurant.'))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: tablesList.length,
                itemBuilder: (context, index) {
                  final table = tablesList[index];
                  final isSelected = selectedIds.contains(table.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: table.isOccupied ? Colors.grey.shade100 : null,
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: table.isOccupied ? null : (_) => notifier.toggleTable(table.id),
                      title: Text(
                        table.name,
                        style: TextStyle(
                          color: table.isOccupied ? Colors.grey.shade500 : null,
                          decoration: table.isOccupied ? TextDecoration.lineThrough : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        table.isOccupied ? 'Occupée pour ce service' : 'Capacité: ${table.capacity} personnes',
                        style: TextStyle(color: table.isOccupied ? Colors.red.shade300 : Colors.grey.shade600),
                      ),
                      secondary: Icon(
                        Icons.table_restaurant,
                        color: table.isOccupied ? Colors.grey.shade400 : theme.colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (!hasSelections || isScreenLoading)
                      ? null
                      : () async {
                    final success = await notifier.confirmAssignment();
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Réservation confirmée avec les tables assignées')),
                      );
                      Navigator.pop(context);

                      notifier.resetState();
                      ref.read(reservationDetailsManagerProvider.notifier).refresh();
                      //ref.read(assignTablesProvider.notifier).refresh();
                      ref.read(restManResProvider.notifier).refresh();
                      ref.invalidate(myRestaurantsProvider);
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erreur lors de la validation des tables.'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Confirmer la réservation'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}