import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a08/models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    String lastReservationText = '';
    if (restaurant.lastReservation != null) {
      lastReservationText = DateFormat("E dd/MM/yyyy", 'fr_FR').format(
          restaurant.lastReservation!);
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.restaurant, size: 40),
        title: Text(
          restaurant.restaurantName,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  restaurant.city,
                ),
                const SizedBox(width: 12),
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  restaurant.rating.toStringAsFixed(1),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Text(
                  '€' * restaurant.priceRange,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  restaurant.lastReservation != null
                    ? 'Dernière réservation: $lastReservationText'
                    : lastReservationText,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (restaurant.inPending > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.pending, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    "${restaurant.inPending} demande(s) en attente",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
