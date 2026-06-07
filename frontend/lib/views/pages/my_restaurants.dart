import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a08/providers/my_restaurants_provider.dart';
import 'package:prbd_2526_a08/providers/security_provider.dart';
import 'package:prbd_2526_a08/views/widgets/restaurant_card.dart';

class MyRestaurants extends ConsumerWidget {
  const MyRestaurants({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(securityProvider.notifier);
    final restaurantNotifier = ref.read(myRestaurantsProvider.notifier);
    final currentUser = notifier.loggedUser;
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    final restaurantsProvider = ref.watch(myRestaurantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes restaurants'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              ref.read(myRestaurantsProvider.notifier).refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion ($currentUser)',
            onPressed: () {
              ref.invalidate(myRestaurantsProvider);
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
        child: Column(
          children: [
          Expanded(
              child: restaurantsProvider.when(
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
                  data: (restaurantsList) {
                    if (restaurantsList.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Aucun restaurant n\'est géré.'
                            '\nVeuillez contacter un administrateur pour être assigné à un restaurant.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: restaurantsList.length,
                      itemBuilder: (context, index) {
                        return RestaurantCard(
                            restaurant: restaurantsList[index]
                        );
                      },
                    );
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
