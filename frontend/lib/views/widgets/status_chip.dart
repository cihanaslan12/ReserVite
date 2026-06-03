import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({
    super.key,
    required this.status,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'completed': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case 'confirmed': return 'Confirmée';
      case 'completed': return 'Terminéee';
      case 'cancelled': return 'Annulée';
      default: return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Chip(
      label: Text(
        _getStatusLabel(),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: statusColor,
      padding: EdgeInsets.zero,
    );
  }
}