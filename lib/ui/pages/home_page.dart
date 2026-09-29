import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/reminder.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/time_utils.dart';
import '../widgets/common.dart';
import '../widgets/reminder_card.dart';
import 'drawer.dart';
import 'medicine_db_page.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: <Widget>[
          const SliverToBoxAdapter(child: _HomeHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            sliver: Obx(() {
              if (controller.loading.value && controller.reminders.isEmpty) {
                return const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              if (controller.reminders.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.notifications_active_outlined,
                    title: 'No reminders yet',
                    message:
                        'Pick a medicine from the library and we will remind you '
                        'every few hours — every single day.',
                    color: brandPrimary,
                    action: FilledButton.icon(
                      onPressed: () => Get.to(() => const MedicineDbPage()),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add my first reminder'),
                    ),
                  ),
                );
              }

              return SliverList.separated(
                itemCount: controller.reminders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int index) {
                  final Reminder reminder = controller.reminders[index];
                  return ReminderCard(
                    key: ValueKey<String>(reminder.id),
                    reminder: reminder,
                    accent: controller.colorFor(index),
                    highlighted: controller.highlighted.value?.id == reminder.id,
                    onTap: () => controller.highlight(reminder),
                  );
                },
              );
            }),
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.reminders.isEmpty) return const SizedBox(height: 8);
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
                child: _AddTile(
                  onTap: () => Get.to(() => const MedicineDbPage()),
                ),
              );
            }),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                24 + MediaQuery.of(context).padding.bottom,
              ),
              child: Text(
                'Medicine data: $medicineDbRepo · $medicineDbLicense',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => controller.reminders.isEmpty
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                onPressed: () => Get.to(() => const MedicineDbPage()),
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                elevation: 3,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add medicine'),
              ),
      ),
    );
  }
}

class _HomeHeader extends GetView<HomeController> {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: brandGradient,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          greetingFor(now),
                          style: const TextStyle(
                            fontFamily: kBodyFont,
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appName,
                          style: displayStyle(23, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  _RoundIconButton(
                    icon: Icons.contrast_rounded,
                    tooltip: 'Toggle theme',
                    onTap: () => Get.find<SettingsController>().toggleTheme(),
                  ),
                  const SizedBox(width: 8),
                  _RoundIconButton(
                    icon: Icons.menu_rounded,
                    tooltip: 'Menu',
                    onTap: () => Scaffold.of(context).openDrawer(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Obx(() {
                // Read the observables here so GetX can rebuild this strip.
                final int count = controller.reminders.length;
                final int doses = controller.totalDosesPerDay;
                final Duration? countdown = controller.countdown;
                return _NextDoseStrip(
                  reminderCount: count,
                  dosesPerDay: doses,
                  countdown: countdown,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextDoseStrip extends StatelessWidget {
  const _NextDoseStrip({
    required this.reminderCount,
    required this.dosesPerDay,
    required this.countdown,
  });

  final int reminderCount;
  final int dosesPerDay;
  final Duration? countdown;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatChip(
            icon: Icons.medication_rounded,
            value: '$reminderCount',
            label: reminderCount == 1 ? 'reminder' : 'reminders',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.schedule_rounded,
            value: '$dosesPerDay',
            label: 'doses / day',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.timelapse_rounded,
            value: countdown == null ? '—' : countdownLabel(countdown!),
            label: 'next dose',
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 15, color: Colors.white70),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: displayStyle(15, color: Colors.white),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: kBodyFont,
              fontSize: 10.5,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.white.withValues(alpha: 0.18),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(icon, size: 19, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      color: scheme.primary.withValues(alpha: 0.07),
      borderColor: scheme.primary.withValues(alpha: 0.25),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: <Widget>[
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_rounded, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Add another medicine',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Search 17,000+ brands',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
