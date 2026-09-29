import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/reminder_form_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/time_utils.dart';
import '../sheets/pickers.dart';
import '../widgets/common.dart';

/// Create a reminder, either from a database row (`Get.arguments`) or manually.
class NewReminderPage extends StatefulWidget {
  const NewReminderPage({Key? key}) : super(key: key);

  @override
  State<NewReminderPage> createState() => _NewReminderPageState();
}

class _NewReminderPageState extends State<NewReminderPage> {
  final ReminderFormController controller = Get.put(ReminderFormController());

  @override
  void dispose() {
    Get.delete<ReminderFormController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('New reminder'),
        titleTextStyle: theme.textTheme.titleLarge,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            Obx(() {
              final bool manual = controller.sourceMedicine.value == null;
              return AppCard(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    controller.form.value.color,
                    Color.lerp(
                      controller.form.value.color,
                      Colors.black,
                      0.26,
                    )!,
                  ],
                ),
                borderColor: Colors.transparent,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(
                        controller.form.value.icon,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            manual
                                ? 'Add a medicine by hand'
                                : 'From the medicine library',
                            style: const TextStyle(
                              fontFamily: kBodyFont,
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            controller.sourceMedicine.value?.displayName ??
                                'Type the details below',
                            style: displayStyle(18, color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            const SectionTitle('Medicine details'),
            _LabeledField(
              label: 'Name',
              hint: 'e.g. Napa',
              controller: controller.nameController,
              icon: Icons.medication_outlined,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Strength',
              hint: 'e.g. 500',
              suffix: 'mg / ml',
              controller: controller.strengthController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9./\s]')),
              ],
              icon: Icons.science_outlined,
            ),
            const SizedBox(height: 24),
            const SectionTitle('Dosage form'),
            Obx(() => _FormPicker(
                  selected: controller.form.value,
                  onSelected: (MedicineForm f) =>
                      controller.form.value = f,
                )),
            const SizedBox(height: 24),
            const SectionTitle('Schedule'),
            Obx(
              () => _ScheduleRow(
                icon: Icons.schedule_rounded,
                label: 'First dose',
                value: formatTimeOfDay12(controller.startTime.value),
                onTap: () async {
                  final TimeOfDay? picked = await TimePickerSheet.show(
                    context,
                    initial: controller.startTime.value,
                    accent: controller.form.value.color,
                  );
                  if (picked != null) controller.startTime.value = picked;
                },
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => _ScheduleRow(
                icon: Icons.repeat_rounded,
                label: 'Repeat every',
                value: '${controller.interval.value} '
                    '${controller.interval.value == 1 ? 'hour' : 'hours'}',
                onTap: () async {
                  final int? picked = await IntervalPickerSheet.show(
                    context,
                    initial: controller.interval.value,
                    accent: controller.form.value.color,
                  );
                  if (picked != null) controller.interval.value = picked;
                },
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _DosePreview(
                start: controller.startTime.value,
                interval: controller.interval.value,
                accent: controller.form.value.color,
              ),
            ),
            const SizedBox(height: 26),
            Obx(
              () => FilledButton.icon(
                onPressed: controller.saving.value ? null : _submit,
                icon: controller.saving.value
                    ? const SizedBox(
                        height: 17,
                        width: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.notifications_active_rounded),
                label: Text(
                  controller.saving.value ? 'Saving…' : 'Start reminder',
                  style: const TextStyle(
                    fontFamily: kBodyFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You will be reminded every single day until you delete the '
              'reminder. All data stays on this device.',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final bool ok = await controller.submit();
    if (!mounted) return;
    if (ok) {
      Get.back<void>();
      Get.snackbar(
        'Reminder started 🎉',
        controller.summaryLine,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
        backgroundColor: const Color(0xFF1B1A2E),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final String? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: TextCapitalization.words,
          style: Theme.of(context).textTheme.titleSmall,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 19),
            suffixText: suffix,
          ),
        ),
      ],
    );
  }
}

class _FormPicker extends StatelessWidget {
  const _FormPicker({required this.selected, required this.onSelected});

  final MedicineForm selected;
  final void Function(MedicineForm form) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: medicineForms.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          final MedicineForm form = medicineForms[index];
          final bool isSelected = form.name == selected.name;
          return GestureDetector(
            onTap: () => onSelected(form),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 92,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? form.color.withValues(alpha: 0.14)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? form.color
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: isSelected ? 1.8 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(form.icon, size: 24, color: form.color),
                  const SizedBox(height: 8),
                  Text(
                    form.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: kBodyFont,
                      fontSize: 11,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? form.color
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: <Widget>[
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 19, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _DosePreview extends StatelessWidget {
  const _DosePreview({
    required this.start,
    required this.interval,
    required this.accent,
  });

  final TimeOfDay start;
  final int interval;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final List<TimeOfDay> times = buildSchedule(start, interval);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.auto_awesome_rounded, size: 14, color: accent),
              const SizedBox(width: 6),
              Text(
                '${times.length} doses per day',
                style: TextStyle(
                  fontFamily: kBodyFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: times
                .map<Widget>(
                  (TimeOfDay t) => Pill(
                    label: formatTimeOfDay12(t),
                    color: accent,
                    dense: true,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
