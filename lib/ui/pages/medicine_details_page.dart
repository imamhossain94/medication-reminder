import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/medicine_details_controller.dart';
import '../../models/medicine.dart';
import '../../models/medicine_details.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../widgets/common.dart';
import '../widgets/medicine_tile.dart';
import 'new_reminder_page.dart';

class MedicineDetailsPage extends StatefulWidget {
  const MedicineDetailsPage({Key? key, required this.medicine})
      : super(key: key);

  final Medicine medicine;

  @override
  State<MedicineDetailsPage> createState() => _MedicineDetailsPageState();
}

class _MedicineDetailsPageState extends State<MedicineDetailsPage> {
  late final MedicineDetailsController controller =
      Get.put(MedicineDetailsController(widget.medicine));

  Medicine get medicine => widget.medicine;

  @override
  void dispose() {
    Get.delete<MedicineDetailsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final MedicineForm form = medicine.medicineForm;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 252,
            backgroundColor: form.color,
            foregroundColor: Colors.white,
            // The title only appears in the collapsed toolbar so it can never
            // overlap the content rendered in the expanded header.
            title: Text(
              medicine.brandName.isEmpty ? 'Medicine' : medicine.brandName,
              style: displayStyle(16, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
                      form.color,
                      Color.lerp(form.color, Colors.black, 0.28)!,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                form.icon,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    medicine.displayName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: displayStyle(21, color: Colors.white),
                                  ),
                                  if (medicine.companyName?.isNotEmpty ??
                                      false) ...<Widget>[
                                    const SizedBox(height: 3),
                                    Text(
                                      medicine.companyName!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: kBodyFont,
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            _GlassPill(
                              icon: Icons.category_outlined,
                              text: medicine.formLabel,
                            ),
                            if (medicine.packsize.trim().isNotEmpty)
                              _GlassPill(
                                icon: Icons.inventory_2_outlined,
                                text: medicine.packsize.trim(),
                              ),
                            _GlassPill(
                              icon: Icons.sell_outlined,
                              text: medicine.hasPrice
                                  ? '${medicine.price}৳ / pack'
                                  : 'Price unavailable',
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
                Obx(() {
                  if (controller.loading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final MedicineDetails? details = controller.details.value;
                  if (details == null) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (details.genericName.isNotEmpty) ...<Widget>[
                        AppCard(
                          color: scheme.primaryContainer,
                          borderColor: Colors.transparent,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.science_outlined,
                                size: 20,
                                color: scheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Generic name',
                                      style: theme.textTheme.labelSmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      details.genericName,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],
                      if (details.pregnancyCategory.isNotEmpty) ...<Widget>[
                        AppCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: <Widget>[
                              const Icon(
                                Icons.pregnant_woman_outlined,
                                size: 18,
                                color: brandAccent,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Pregnancy category: ${details.pregnancyCategory}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],
                      SectionTitle(
                        'About this medicine',
                        color: form.color,
                      ),
                      ...details.sections.map(
                        (MedicineDetailSection section) => DetailBlock(
                          title: section.title,
                          body: section.body,
                          color: form.color,
                          icon: _iconFor(section.title),
                        ),
                      ),
                      if (controller.alternatives.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 10),
                        SectionTitle(
                          'Same generic, other brands',
                          color: brandBlue,
                        ),
                        ...controller.alternatives.map(
                          (Medicine alt) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: MedicineTile(
                              medicine: alt,
                              onTap: () => Get.to(
                                () => MedicineDetailsPage(medicine: alt),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        'Information above is for reference only and is not a '
                        'substitute for professional medical advice.',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  );
                }),
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
        child: FilledButton.icon(
          onPressed: () => Get.to(
            () => NewReminderPage(),
            arguments: medicine,
          ),
          icon: const Icon(Icons.notifications_active_rounded),
          label: const Text('Set a reminder for this medicine'),
        ),
      ),
    );
  }

  static IconData _iconFor(String title) {
    switch (title) {
      case 'What it treats':
        return Icons.healing_outlined;
      case 'How to use':
        return Icons.schedule_outlined;
      case 'Possible side effects':
        return Icons.warning_amber_rounded;
      case 'Precautions':
        return Icons.shield_outlined;
      case 'Do not use if':
        return Icons.block_outlined;
      case 'Drug interactions':
        return Icons.sync_alt_rounded;
      case 'How it works':
        return Icons.psychology_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontFamily: kBodyFont,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
