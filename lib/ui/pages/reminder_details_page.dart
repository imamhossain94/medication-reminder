import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../models/reminder.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/time_utils.dart';
import '../widgets/common.dart';

class ReminderDetailsPage extends StatelessWidget {
  const ReminderDetailsPage({Key? key, required this.reminder})
      : super(key: key);

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color accent = reminder.medicine.medicineForm.color;
    final DateTime next = reminder.nextDose();
    final List<TimeOfDay> schedule = reminder.schedule;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 196,
            backgroundColor: accent,
            foregroundColor: Colors.white,
            title: Text('Reminder', style: displayStyle(16, color: Colors.white)),
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      accent,
                      Color.lerp(accent, Colors.black, 0.28)!,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            FormBadge(
                              form: reminder.medicine.medicineForm,
                              size: 54,
                              iconSize: 26,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    reminder.medicine.displayName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: displayStyle(21, color: Colors.white),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    reminder.medicine.formLabel,
                                    style: const TextStyle(
                                      fontFamily: kBodyFont,
                                      fontSize: 12.5,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                AppCard(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      brandPrimary.withValues(alpha: 0.14),
                      brandSecondary.withValues(alpha: 0.10),
                    ],
                  ),
                  borderColor: Colors.transparent,
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: brandPrimary.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: brandPrimary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Next dose',
                              style: theme.textTheme.labelSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${formatTimeOfDay(context, TimeOfDay(hour: next.hour, minute: next.minute))}'
                              ' • ${countdownLabel(next.difference(DateTime.now()))}',
                              style: displayStyle(17, color: brandPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SectionTitle('Medicine', color: accent),
                AppCard(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: InfoTile(
                              label: 'Brand',
                              value: reminder.medicine.brandName,
                              icon: Icons.label_outline_rounded,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InfoTile(
                              label: 'Strength',
                              value: reminder.medicine.strength,
                              icon: Icons.science_outlined,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(color: scheme.outlineVariant),
                      const SizedBox(height: 14),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: InfoTile(
                              label: 'Form',
                              value: reminder.medicine.formLabel,
                              icon: Icons.category_outlined,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InfoTile(
                              label: 'Company',
                              value: reminder.medicine.companyName ?? '—',
                              icon: Icons.factory_outlined,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(color: scheme.outlineVariant),
                      const SizedBox(height: 14),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: InfoTile(
                              label: 'Pack size',
                              value: reminder.medicine.packsize,
                              icon: Icons.inventory_2_outlined,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InfoTile(
                              label: 'Price',
                              value: reminder.medicine.priceLabel,
                              icon: Icons.sell_outlined,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SectionTitle(
                  'Daily schedule • ${schedule.length} doses',
                  color: brandBlue,
                ),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: schedule
                            .map<Widget>((TimeOfDay t) {
                              final bool isNext = t.hour == next.hour &&
                                  t.minute == next.minute;
                              return Pill(
                                label: formatTimeOfDay(context, t),
                                color: isNext ? brandAmber : brandBlue,
                                icon: isNext
                                    ? Icons.play_arrow_rounded
                                    : Icons.schedule_rounded,
                              );
                            })
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      Divider(color: scheme.outlineVariant),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.repeat_rounded,
                            size: 15,
                            color: brandBlue,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              'Every ${reminder.interval} hours, starting at '
                              '${formatTimeOfDay(context, reminder.startTimeOfDay)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: OutlinedButton.icon(
          onPressed: () => _confirmDelete(context),
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Delete this reminder'),
          style: OutlinedButton.styleFrom(
            foregroundColor: brandAccent,
            side: BorderSide(color: brandAccent.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: Text(
          'You will stop receiving notifications for '
          '${reminder.medicine.displayName}.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: brandAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final HomeController home = Get.find<HomeController>();
    await home.deleteReminder(reminder);
    if (Get.isOverlaysOpen) Get.back<void>();
    Get.back<void>();
    Get.snackbar(
      'Reminder deleted',
      'No more notifications for ${reminder.medicine.displayName}.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      duration: const Duration(seconds: 3),
    );
  }
}
