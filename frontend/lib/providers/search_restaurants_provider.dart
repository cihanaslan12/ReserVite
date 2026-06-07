import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_a08/core/tools/abstract_async_notifier.dart';

import '../models/restaurant.dart';

const int maxRestaurantsLimit = 5;

final searchRestaurantsProvider =
AsyncNotifierProvider<SearchRestaurantsNotifier, List<Restaurant>>(
      () => SearchRestaurantsNotifier(),
);

class SearchRestaurantsNotifier extends AbstractAsyncNotifier<List<Restaurant>> {
  String _currentQuery = '';
  String get currentQuery => _currentQuery;
  List<Restaurant> _allRestaurants = [];

  @override
  Future<List<Restaurant>> build() async {
    return [];
  }

  Future<void> initData() async {
    if (_allRestaurants.isNotEmpty) return;
    state = const AsyncValue.loading();
    try {
      _allRestaurants = await Restaurant.getAllRestaurants();
      state = AsyncData(_allRestaurants);
    } catch (e) {
      state = AsyncValue.error(
          "Quelque chose a mal tourné!\nRéessayez plus tard.",
          StackTrace.current
      );
    }
  }

  @override
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      _allRestaurants = await Restaurant.getAllRestaurants();
      resetSearch();
    } catch (e) {
      state = AsyncValue.error(
        "Quelque chose a mal tourné!\nRéessayez plus tard.",
        StackTrace.current,
      );
    }
  }

  void search(String query) {
    _currentQuery = query;
    if(query.trim().isEmpty) {
      state = AsyncData(_allRestaurants);
    } else {
      final search = query.toLowerCase();
      final filteredList = _allRestaurants.where((rest) {
        return rest.restaurantName.toLowerCase().contains(search) ||
            rest.city.toLowerCase().contains(search) ||
            (rest.description != null && rest.description!.toLowerCase().contains(search));
      }).toList();
      state = AsyncData(filteredList);
    }
  }

  void resetSearch() {
    _currentQuery = '';
    state = AsyncData(_allRestaurants);
  }
}
