import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/reservation.dart';
import '../../providers/assign_tables_provider.dart';
import '../../providers/reservation_details_manager_provider.dart';
import '../widgets/status_chip.dart';

class ReservationDetailsManager extends ConsumerWidget {
  const ReservationDetailsManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeReservation = ModalRoute.of(context)!.settings.arguments as Reservation;
    final providerReservation = ref.watch(reservationDetailsManagerProvider).value;
    final reservation = (providerReservation != null && providerReservation.id != 0)
        ? providerReservation : routeReservation;

    final tablesNotifier = ref.read(assignTablesProvider.notifier);
    if (tablesNotifier.currentReservationId != reservation.id) {
      Future.delayed(Duration.zero, () {
        tablesNotifier.initReservation(reservation.id);
      });
    }
    final tablesAsync = ref.watch(assignTablesProvider);

    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);
    final String formattedDate = DateFormat("E dd/MM/yyyy", "fr_FR").format(reservation.datetime);
    final String formattedTime = DateFormat("HH:mm", "fr_FR").format(reservation.datetime);

    final String status = reservation.status;
    final bool isPending = status == 'pending';
    final bool showBtns = status == 'pending' || status == 'confirmed';
    final bool canComplete = !simulatedTime.isBefore(reservation.datetime);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Détails de la réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              ref.read(reservationDetailsManagerProvider.notifier).refresh();
              tablesNotifier.initReservation(reservation.id);
            },
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
                message:
                'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                      .format(simulatedTime),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations client',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 20),
                          const SizedBox(width: 8),
                          Text('Nom: ${reservation.clientName}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 20),
                          const SizedBox(width: 8),
                          Text('Email: ${reservation.clientEmail}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Téléphone: ${reservation.clientPhone}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Détails de la réservation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.restaurant, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reservation.restaurantName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Date: $formattedDate',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Text('Heure: $formattedTime'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 20),
                          const SizedBox(width: 8),
                          Text('Nombre de convives: ${reservation.numberOfGuests}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info, size: 20),
                          const SizedBox(width: 8),
                          const Text('Statut: ', style: TextStyle(fontSize: 12)),
                          StatusChip(status: reservation.status),
                        ],
                      ),
                      if (reservation.specialRequests.isNotEmpty &&
                        reservation.specialRequests != 'Aucune demande spéciale') ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Demandes spéciales',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reservation.specialRequests,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tables assignées',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (reservation.status == 'pending')
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Aucune table assignée (en attente de confirmation)',
                    ),
                  ),
                )
              else if (reservation.status == 'cancelled')
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                    'Aucune table assignée',
                  ),
                ),
              )
              else
                tablesAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, _) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Erreur lors du chargement : $err', style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                  data: (assignState) {
                    final assignedTables = assignState.tables;
                    if (assignedTables.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              'Aucune table disponible dans ce restaurant.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var table in assignedTables)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.table_restaurant, color: Colors.grey[700], size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      table.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '(${table.capacity} places)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              if (showBtns) ...[
                const SizedBox(height: 24),
                if (isPending) ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(assignTablesProvider.notifier).initReservation(reservation.id);
                      if (context.mounted) {
                        Navigator.pushNamed(
                          context,
                          '/assign_tables',
                          arguments: reservation,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    ),
                    icon: const Icon(Icons.table_bar),
                    label: const Text('Confirmer et assigner tables'),
                  ),
                  const SizedBox(height: 8),
                ],
                ElevatedButton.icon(
                  onPressed: canComplete ? () {
                    Navigator.pushNamed(
                      context,
                      '/reservation_form',
                      arguments: reservation,
                    );
                  } : null,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Marquer comme terminée'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Annuler la réservation'),
                        content : const Text('Êtes-vous sûr de vouloir annuler cette réservation?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                            ),
                            child: const Text('Non'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              final cancelled = await ref.read(reservationDetailsManagerProvider.notifier).cancelReservation();

                              if (!cancelled && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Impossible d\'annuler cette réservation'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('Oui'),
                          ),
                        ],
                      );
                    },
                  );

                },
                icon: const Icon(Icons.cancel),
                label: const Text('Annuler'),
              ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
