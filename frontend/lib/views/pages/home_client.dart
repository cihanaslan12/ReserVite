import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:prbd_2526_a08/providers/my_reservations_provider.dart';
import 'package:prbd_2526_a08/providers/security_provider.dart';
import 'package:prbd_2526_a08/views/widgets/reservation_card.dart';

class HomeClient extends ConsumerWidget {
  const HomeClient({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(securityProvider.notifier);
    final currentUser = notifier.loggedUser;

    final reservationNotifier = ref.read(myReservationsProvider.notifier);

    final reservationsAsync = ref.watch(filteredMyReservationsProvider);
    final currentFilter = ref.watch(myReservationsProvider).value?.currentFilter ?? 'pending';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/search_restaurants');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              reservationNotifier.refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion ($currentUser)',
            onPressed: () {
              ref.invalidate(myReservationsProvider);
              notifier.logout();
              Navigator.pushReplacementNamed(context, '/login');
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
                message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  'mercredi 04/12/2024 16:00',
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: 'all',
                    icon: Icon(Icons.list, size: 24),
                    tooltip: 'Toutes',
                  ),
                  ButtonSegment(
                    value: 'pending',
                    icon: Icon(Icons.pending, size: 24, color: Colors.orange),
                    tooltip: 'En attente',
                  ),
                  ButtonSegment(
                    value: 'confirmed',
                    icon: Icon(Icons.check_circle, size: 24, color: Colors.green),
                    tooltip: 'Confirmées',
                  ),
                  ButtonSegment(
                    value: 'completed',
                    icon: Icon(Icons.event_available, size: 24, color: Colors.blue),
                    tooltip: 'Terminées',
                  ),
                  ButtonSegment(
                    value: 'cancelled',
                    icon: Icon(Icons.cancel, size: 24, color: Colors.red),
                    tooltip: 'Annulées',
                  ),
                ],
                selected: {currentFilter},
                onSelectionChanged: (newSelection) {
                  ref.read(myReservationsProvider.notifier).setFilter(newSelection.first);
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: reservationsAsync.when(
                loading: () => const Column(
                  children: [
                    LinearProgressIndicator(),
                    Spacer(),
                  ],
                ),
                error: (err, stack) => Center(
                  child: Text(
                    'Erreur : $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                data: (reservationList) {
                  if (reservationList.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune réservation trouvée.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: reservationList.length,
                    itemBuilder: (context, index) {
                      return ReservationCard(reservation: reservationList[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/reservation_form');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle réservation'),
      ),
    );
  }
}
