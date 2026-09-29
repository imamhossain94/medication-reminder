import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/time_utils.dart';

/// Bottom sheet that lets the user pick an hour / minute / AM-PM.
class TimePickerSheet extends StatefulWidget {
  const TimePickerSheet({
    Key? key,
    required this.initial,
    required this.accent,
  }) : super(key: key);

  final TimeOfDay initial;
  final Color accent;

  static Future<TimeOfDay?> show(
    BuildContext context, {
    required TimeOfDay initial,
    Color accent = brandPrimary,
  }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => TimePickerSheet(
        initial: initial,
        accent: accent,
      ),
    );
  }

  @override
  State<TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<TimePickerSheet> {
  late int _hour12 = widget.initial.hour % 12;
  late int _minute = widget.initial.minute;
  late int _period = widget.initial.hour < 12 ? 0 : 1;

  late final PageController _hourController =
      PageController(initialPage: _hour12);
  late final PageController _minuteController =
      PageController(initialPage: _minute);

  TimeOfDay get _value {
    int h = _hour12 + 1; // 1 – 12
    if (_period == 0) {
      if (h == 12) h = 0;
    } else if (h != 12) {
      h += 12;
    }
    return TimeOfDay(hour: h, minute: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return _SheetShell(
      title: 'Start time',
      subtitle: 'When should the first dose of the day be?',
      accent: widget.accent,
      confirmLabel: 'Set time',
      onConfirm: () => Navigator.of(context).pop(_value),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: _Wheel(
                  controller: _hourController,
                  count: 12,
                  labels: List<String>.generate(
                    12,
                    (int i) => (i + 1).toString().padLeft(2, '0'),
                  ),
                  initial: _hour12,
                  accent: widget.accent,
                  onChanged: (int index) => setState(() => _hour12 = index),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: _Wheel(
                  controller: _minuteController,
                  count: 60,
                  labels: List<String>.generate(
                    60,
                    (int i) => i.toString().padLeft(2, '0'),
                  ),
                  initial: _minute,
                  accent: widget.accent,
                  onChanged: (int index) => setState(() => _minute = index),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _PeriodToggle(
                  value: _period,
                  accent: widget.accent,
                  onChanged: (int p) => setState(() => _period = p),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Selected: ${formatTimeOfDay(context, _value)}',
            style: text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for the "remind me every" interval.
class IntervalPickerSheet extends StatelessWidget {
  const IntervalPickerSheet({
    Key? key,
    required this.initial,
    required this.accent,
  }) : super(key: key);

  final int initial;
  final Color accent;

  static const List<int> _options = <int>[
    1, 2, 3, 4, 5, 6, 8, 10, 12, 24,
  ];

  static Future<int?> show(
    BuildContext context, {
    required int initial,
    Color accent = brandPrimary,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) =>
          IntervalPickerSheet(initial: initial, accent: accent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Repeat every',
      subtitle: 'How many hours between two doses?',
      accent: accent,
      onConfirm: () => Navigator.of(context).pop(),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _options.map((int hours) {
          final bool selected = hours == initial;
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(hours),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? accent : accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '$hours ${hours == 1 ? 'hour' : 'hours'}',
                style: TextStyle(
                  fontFamily: kBodyFont,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : accent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  final int value;
  final Color accent;
  final void Function(int period) onChanged;

  @override
  Widget build(BuildContext context) {
    final List<Widget> buttons = <Widget>[];
    for (int index = 0; index < 2; index++) {
      final bool selected = index == value;
      final String label = index == 0 ? 'AM' : 'PM';
      buttons.add(
        GestureDetector(
          onTap: () => onChanged(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 62,
            height: 52,
            margin: const EdgeInsets.symmetric(vertical: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? accent : accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: kBodyFont,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : accent,
              ),
            ),
          ),
        ),
      );
    }

    return Column(mainAxisSize: MainAxisSize.min, children: buttons);
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.controller,
    required this.count,
    required this.labels,
    required this.initial,
    required this.accent,
    required this.onChanged,
  });

  final PageController controller;
  final int count;
  final List<String> labels;
  final int initial;
  final Color accent;
  final void Function(int index) onChanged;

  @override
  Widget build(BuildContext context) {
    const double itemExtent = 44;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: itemExtent * 3,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                height: itemExtent,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              PageView.builder(
                controller: controller,
                itemCount: count,
                onPageChanged: onChanged,
                itemBuilder: (BuildContext context, int index) => Center(
                  child: Text(
                    labels[index],
                    style: displayStyle(20, color: accent),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('TAP TO CHANGE', style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.child,
    required this.onConfirm,
    this.confirmLabel = 'Done',
  });

  final String title;
  final String subtitle;
  final Color accent;
  final Widget child;
  final VoidCallback onConfirm;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                height: 5,
                width: 44,
                decoration: BoxDecoration(
                  color: scheme.outline,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            child,
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(backgroundColor: accent),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ),
    );
  }
}
