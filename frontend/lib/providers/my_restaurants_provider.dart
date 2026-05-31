import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_a08/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a08/models/restaurant.dart';
import 'package:prbd_2526_a08/providers/security_provider.dart';

final myRestaurantsProvider =
  AsyncNotifierProvider<MyRestaurantsNotifier, List<Restaurant>>(
    () => MyRestaurantsNotifier(),
  );

  class MyRestaurantsNotifier extends AbstractAsyncNotifier<List<Restaurant>> {
    @override
    Future<List<Restaurant>> build() async {
      ref.watch(securityProvider);

      state = AsyncData([]);
      state = AsyncLoading();
      try {
        return await Restaurant.getMyRestaurants();
      } catch (e) {
        throw "Quelque chose a mal tourné!\nRéessayez plus tard.";
      }
  }

  @override
    Future<void> refresh() async {
      await getMyRestaurants();
  }

  Future<void> getMyRestaurants() async {
      state = const AsyncValue.loading();
      try {
        final restaurants = await Restaurant.getMyRestaurants();
        state = AsyncData(restaurants);
      } catch (e) {
        state = AsyncValue.error(
          "Quelque chose a mal tourné!\nRéessayez plus tard.",
            StackTrace.current,
        );
      }
  }
}