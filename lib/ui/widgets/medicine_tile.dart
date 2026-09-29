import 'package:flutter/material.dart';
import 'package:medication_reminder/models/medicine.dart';

import '../../theme/app_theme.dart';
import 'common.dart';

/// A single row in the medicine database list.
class MedicineTile extends StatelessWidget {
  const MedicineTile({Key? key, required this.medicine, required this.onTap})
      : super(key: key);

  final Medicine medicine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = medicine.medicineForm.color;
    final String name = medicine.displayName;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      child: Row(
        children: <Widget>[
          FormBadge(form: medicine.medicineForm, size: 42, iconSize: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitle(medicine),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                medicine.priceLabel,
                style: displayStyle(14, color: accent),
              ),
              const SizedBox(height: 2),
              Text(
                medicine.medicineForm.name,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _subtitle(Medicine m) {
    final List<String> parts = <String>[];
    if (m.packsize.trim().isNotEmpty) parts.add(m.packsize.trim());
    if (m.companyName != null && m.companyName!.trim().isNotEmpty) {
      parts.add(m.companyName!.trim());
    }
    return parts.isEmpty ? 'No further details' : parts.join(' • ');
  }
}
