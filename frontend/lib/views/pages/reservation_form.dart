import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/restaurant.dart';
import '../../providers/my_reservations_provider.dart';
import '../../providers/reservation_details_provider.dart';
import '../../providers/reservation_form_provider.dart';

class ReservationForm extends ConsumerWidget {
  const ReservationForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arguments = ModalRoute.of(context)!.settings.arguments;

    int restaurantId = 0;
    String restaurantName = '';
    int? editReservationId;

    if (arguments is Restaurant) {
      restaurantId = arguments.id;
      restaurantName = arguments.restaurantName;
    } else if (arguments is Map) {
      restaurantId = arguments['restaurant_id'] as int;
      restaurantName = arguments['restaurant_name']?.toString() ?? '';
      editReservationId = arguments['reservation_id'] as int;
    }

    final reservationAsync = ref.watch(reservationFormProvider);
    final notifier = ref.read(reservationFormProvider.notifier);

    final state = reservationAsync.value!;

    final theme = Theme.of(context);
    final simulatedDate = DateTime(2024, 12, 4, 16, 0);
    final String formattedDate = DateFormat("E dd/MM/yyyy", "fr_FR").format(state.selectedDate);

    bool isClosed = state.availableSlots.isEmpty;
    bool alreadyReserved = state.availableSlots.isNotEmpty &&
        state.availableSlots.every((slot) => slot.alreadyReserved);

    bool isOverbooked = false;
    int maxAvailableGuests = 0;

    if (state.availableSlots.isNotEmpty) {
      maxAvailableGuests = state.availableSlots
          .map((slot) => slot.availableCapacity)
          .reduce((max, value) => value > max ? value : max);
      if(!isClosed && state.selectedTimeSlot != null) {
        final currentSlot = state.availableSlots.firstWhere(
          (slot) => slot.slotTime.substring(0, 5) == state.selectedTimeSlot,
          orElse: () => state.availableSlots.first,
        );
        isOverbooked = currentSlot.isOverbooked;
        maxAvailableGuests = currentSlot.availableCapacity;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(editReservationId == null ? 'Nouvelle réservation' : 'Modifier la réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () async {
              await ref.read(reservationFormProvider.notifier).refresh();
            }
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
                      .format(simulatedDate),
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
            if (state.isLoading)
              const LinearProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        restaurantName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  final datePicker = await showDatePicker(
                                    context: context,
                                    initialDate: state.selectedDate,
                                    firstDate: simulatedDate,
                                    lastDate: DateTime(2027),
                                  );
                                  if (datePicker != null) {
                                    notifier.changeDate(datePicker);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('Date'),
                                            Text(
                                              formattedDate,
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: state.selectedDate.isBefore(simulatedDate) ||
                                    DateUtils.isSameDay(state.selectedDate, simulatedDate)
                                ? null
                                : () async => await notifier.changeDate(state.selectedDate.subtract(const Duration(days: 1))),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async => await notifier.changeDate(state.selectedDate.add(const Duration(days: 1))),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                      const Divider(),
                      if (alreadyReserved) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.orange),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Vous avez déjà réservé tous les services de ce jour-là.',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (isClosed) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.orange),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Le restaurant est fermé ce jour-là.',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      ],
                      if (!isClosed && !alreadyReserved) ...[
                        const Text(
                          'Créneaux disponibles',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: state.availableSlots
                              .where((slot) => !slot.alreadyReserved)
                              .map((slot) {
                            final timeStr = slot.slotTime.substring(0, 5);
                            final isSelected = state.selectedTimeSlot == timeStr;

                            return InkWell(
                              onTap: () => notifier.selectTimeSlot(timeStr),
                              child: Container(
                                width: 80,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                  ),
                                decoration: BoxDecoration(
                                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,width: 1),
                                ),
                                child: Center(
                                  child: Text(
                                    timeStr,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: const Text('Nombre de convives'),
                        subtitle: Text('${state.numberOfGuests}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: state.numberOfGuests <= 1
                                ? null
                                : () => notifier.changeNumberOfGuests(state.numberOfGuests - 1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: state.numberOfGuests >= maxAvailableGuests
                                  ? null
                                  : () => notifier.changeNumberOfGuests(state.numberOfGuests + 1),
                            ),
                          ],
                        ),
                      ),
                      if (isOverbooked) ... [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.warning, color: Colors.orange),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'Surréservation (capacité)',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'La capacité du restaurant pour ce créneau pourrait être insuffisante pour le nombre de convives demandé.',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: state.specialRequests,
                        decoration: const InputDecoration(
                          labelText: 'Demandes spéciales (optionnel)',
                          border: OutlineInputBorder(),
                          hintText: 'Allergies, préférences...',
                        ),
                        maxLines: 3,
                        onChanged: (text) => notifier.updateSpecialRequests(text),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty && value.trim().length < 10) {
                            return 'Les demandes spéciales doivent contenir au moins 10 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: (isClosed ||
                                    state.selectedTimeSlot == null ||
                            (editReservationId == null && alreadyReserved))
                            ? null
                            : () async {
                                bool success = false;
                                if (editReservationId == null) {
                                  success = await notifier.addReservation();
                                } else {
                                  success = await notifier.editReservation();
                                }

                                if (success && context.mounted) {
                                  ref.invalidate(myReservationsProvider);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(editReservationId == null ? 'Réservation créée avec succès' : 'Réservation modifiée avec succès')),
                                  );
                                  if (editReservationId == null) {
                                    Navigator.of(context).pushNamedAndRemoveUntil('/home_client', (route) => false);
                                  } else {
                                    Navigator.pop(context, true);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: Icon(editReservationId == null ? Icons.add : Icons.edit),
                        label: Text(editReservationId == null ? 'Créer la réservation' : 'Modifier la réservation'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
