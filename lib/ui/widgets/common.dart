import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

/// Soft, rounded surface used across the app.
class AppCard extends StatelessWidget {
  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.borderColor,
    this.gradient,
    this.radius = 22,
    this.elevation = 0,
  }) : super(key: key);

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;
  final double radius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final BorderRadius br = BorderRadius.circular(radius);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? scheme.surface) : null,
        gradient: gradient,
        borderRadius: br,
        border: Border.all(color: borderColor ?? scheme.outlineVariant),
        boxShadow: elevation > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.16),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: br,
        child: InkWell(
          onTap: onTap,
          borderRadius: br,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Small rounded label, tinted with [color].
class Pill extends StatelessWidget {
  const Pill({
    Key? key,
    required this.label,
    this.color = brandPrimary,
    this.icon,
    this.dense = false,
  }) : super(key: key);

  final String label;
  final Color color;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: dense ? 12 : 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: kBodyFont,
              fontSize: dense ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Coloured circular icon holder used for medicine forms.
class FormBadge extends StatelessWidget {
  const FormBadge({
    Key? key,
    required this.form,
    this.size = 46,
    this.iconSize,
  }) : super(key: key);

  final MedicineForm form;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.34),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            form.color,
            Color.lerp(form.color, Colors.black, 0.18)!,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: form.color.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        form.icon,
        color: Colors.white,
        size: iconSize ?? size * 0.5,
      ),
    );
  }
}

/// Section title with a coloured accent bar.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {Key? key, this.color = brandPrimary, this.trailing})
      : super(key: key);

  final String title;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: <Widget>[
          Container(
            height: 18,
            width: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Friendly empty state.
class EmptyState extends StatelessWidget {
  const EmptyState({
    Key? key,
    required this.message,
    this.title,
    this.action,
    this.icon = Icons.medication_liquid_outlined,
    this.color = brandPrimary,
  }) : super(key: key);

  final String message;
  final String? title;
  final Widget? action;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 104,
              width: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    color.withValues(alpha: 0.22),
                    color.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Icon(icon, size: 46, color: color),
            ),
            const SizedBox(height: 22),
            if (title != null) ...<Widget>[
              Text(title!, style: text.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: text.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: 22),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A key/value tile used on the details screens.
class InfoTile extends StatelessWidget {
  const InfoTile({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.color = brandPrimary,
  }) : super(key: key);

  final String label;
  final String value;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label.toUpperCase(),
              style: text.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '—' : value,
          style: text.titleSmall,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// A paragraph block with a coloured heading, used for drug monographs.
class DetailBlock extends StatelessWidget {
  const DetailBlock({
    Key? key,
    required this.title,
    required this.body,
    required this.color,
    required this.icon,
  }) : super(key: key);

  final String title;
  final String body;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body.trim(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
