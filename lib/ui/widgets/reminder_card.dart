import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/reminder.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/time_utils.dart';
import '../pages/reminder_details_page.dart';
import 'common.dart';

/// Colourful card used on the home screen.
class ReminderCard extends StatelessWidget {
  const ReminderCard({
    Key? key,
    required this.reminder,
    required this.onTap,
    required this.accent,
    this.highlighted = false,
  }) : super(key: key);

  final Reminder reminder;
  final VoidCallback onTap;
  final Color accent;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime next = reminder.nextDose();
    final Duration until = next.difference(DateTime.now());
    final String name = reminder.medicine.displayName;
    final String formLabel = reminder.medicine.formLabel;

    return AppCard(
      onTap: () => Get.to(() => ReminderDetailsPage(reminder: reminder)),
      padding: EdgeInsets.zero,
      borderColor: highlighted ? accent : theme.colorScheme.outlineVariant,
      elevation: highlighted ? 1 : 0,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FormBadge(form: reminder.medicine.medicineForm, size: 48),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          Pill(
                            label: formLabel,
                            color: accent,
                            icon: reminder.medicine.medicineForm.icon,
                            dense: true,
                          ),
                          Pill(
                            label: 'every ${reminder.interval}h',
                            color: brandBlue,
                            icon: Icons.repeat_rounded,
                            dense: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Icon(Icons.schedule_rounded, size: 13, color: accent),
                    const SizedBox(height: 3),
                    Text(
                      formatTimeOfDay(context, reminder.startTimeOfDay),
                      style: displayStyle(15, color: accent),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: accent.withValues(
                alpha: until.isNegative ? 0.05 : 0.10,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(21),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  until.isNegative
                      ? Icons.notifications_active_rounded
                      : Icons.timer_outlined,
                  size: 14,
                  color: accent,
                ),
                const SizedBox(width: 7),
                Text(
                  until.isNegative
                      ? 'Dose available now'
                      : 'Next dose ${formatTimeOfDay(context, TimeOfDay(hour: next.hour, minute: next.minute))} · ${countdownLabel(until)}',
                  style: TextStyle(
                    fontFamily: kBodyFont,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
                const Spacer(),
                Text(
                  '${reminder.schedule.length}× / day',
                  style: TextStyle(
                    fontFamily: kBodyFont,
                    fontSize: 11,
                    color: accent.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
