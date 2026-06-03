import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:prbd_2526_a08/views/widgets/restaurant_card.dart';
import '../../providers/search_restaurants_provider.dart';

class SearchRestaurants extends ConsumerStatefulWidget {
  const SearchRestaurants({super.key});

  @override
  ConsumerState<SearchRestaurants> createState() => _SearchRestaurantsState();
}

class _SearchRestaurantsState extends ConsumerState<SearchRestaurants> {
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(searchRestaurantsProvider.notifier).currentQuery;
    _searchController = TextEditingController(text: initialQuery);
    Future.delayed(Duration.zero, () {
      ref.read(searchRestaurantsProvider.notifier).initData();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _searchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchRestaurantsProvider.notifier).search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    final restaurantsAsync = ref.watch(searchRestaurantsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home_client');
          },
        ),
        title: const Text('Rechercher un restaurant'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              ref.read(searchRestaurantsProvider.notifier).refresh();
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher par nom, ville, description...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _searchChanged,
              ),
            ),
            Expanded(
              child: restaurantsAsync.when(
                loading: () => const Column(
                  children: [
                    LinearProgressIndicator(),
                    Spacer(),
                  ],
                ),
                error: (err, stack) => Center(
                    child: Text(
                        err.toString(),
                        style: const TextStyle(color: Colors.red),
                    ),
                ),
                data: (restaurantsList) {
                  final hasCount = restaurantsList.length > maxRestaurantsLimit;
                  final displayList = restaurantsList
                      .take(maxRestaurantsLimit)
                      .toList();
                  if (displayList.isEmpty) {
                    return const Center(child: Text('Aucun restaurant trouvé'));
                  }

                  return Column(
                    children: [
                      if (hasCount)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          color: Colors.orange.shade50,
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Colors.orange.shade800,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Trop de résultats trouvés. Veuillez affiner votre recherche pour voir plus de restaurants.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final rest = displayList[index];
                            return RestaurantCard(
                              restaurant: rest,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/restaurant_details',
                                  arguments: rest,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
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
