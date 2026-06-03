import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a08/models/reservation.dart';
import 'package:prbd_2526_a08/providers/reservation_details_provider.dart';

class ReservationCard extends ConsumerWidget {
  const ReservationCard({super.key, required this.reservation});

  final Reservation reservation;

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed': return Icons.check_circle;
      case 'completed': return Icons.event_available;
      case 'cancelled': return Icons.cancel;
      default: return Icons.pending;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'completed': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed': return 'Confirmée';
      case 'completed': return 'Terminéee';
      case 'cancelled': return 'Annulée';
      default: return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String formattedDate = DateFormat("E dd/MM/yyyy 'à' HH:mm", 'fr_FR')
        .format(reservation.datetime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final notifier = ref.read(reservationDetailsProvider.notifier);
          await notifier.getReservation(reservation);
          Navigator.pushNamed(
            context,
            '/reservation_details',
            arguments: reservation,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Tooltip(
                message: _getStatusLabel(reservation.status),
                child: Icon(
                    _getStatusIcon(reservation.status), size: 32, color: _getStatusColor(reservation.status),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.restaurantName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          reservation.city,
                          style: TextStyle(fontSize: 12, color: Colors
                              .grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(fontSize: 14, color: Colors
                              .grey[600]),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${reservation.numberOfGuests} convives',
                          style: TextStyle(fontSize: 14, color: Colors
                              .grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}