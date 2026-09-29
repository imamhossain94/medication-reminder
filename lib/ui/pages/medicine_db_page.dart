import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/medicine_db_controller.dart';
import '../../models/medicine.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../widgets/common.dart';
import '../widgets/medicine_tile.dart';
import 'medicine_details_page.dart';
import 'new_reminder_page.dart';

class MedicineDbPage extends StatefulWidget {
  const MedicineDbPage({Key? key}) : super(key: key);

  @override
  State<MedicineDbPage> createState() => _MedicineDbPageState();
}

class _MedicineDbPageState extends State<MedicineDbPage> {
  /// Registered here (and only here) so the controller is disposed together
  /// with the page instead of being kept alive by the service locator.
  final MedicineDbController controller = Get.put(MedicineDbController());

  @override
  void dispose() {
    Get.delete<MedicineDbController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Medicine library'),
        titleTextStyle: Theme.of(context).textTheme.titleLarge,
        actions: <Widget>[
          IconButton(
            tooltip: 'Search',
            onPressed: controller.toggleSearch,
            icon: Obx(
              () => Icon(
                controller.searching.value
                    ? Icons.close_rounded
                    : Icons.search_rounded,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'manual-entry',
        onPressed: () => Get.to(() => const NewReminderPage()),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Add manually'),
      ),
      body: Column(
        children: <Widget>[
          Obx(() {
            if (!controller.searching.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: TextField(
                controller: controller.searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search a brand or generic name…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: controller.searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.search('');
                          },
                        ),
                ),
              ),
            );
          }),
          Obx(
            () => _ResultBar(
              total: controller.total.value,
              query: controller.query.value,
              allCount: DatabaseService.instance.brandCount,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loading.value && controller.medicines.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.medicines.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No match',
                  message: controller.query.value.isEmpty
                      ? 'The medicine library is empty.'
                      : 'Nothing matched "${controller.query.value}".\n'
                          'Try a shorter word, or add the medicine manually.',
                  color: brandAccent,
                  action: FilledButton.icon(
                    onPressed: () => Get.to(() => const NewReminderPage()),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add it manually'),
                  ),
                );
              }

              return NotificationListener<ScrollEndNotification>(
                onNotification: (ScrollEndNotification n) {
                  controller.loadMore();
                  return false;
                },
                child: ListView.separated(
                  controller: controller.scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  itemCount: controller.medicines.length +
                      (controller.loadingMore.value ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= controller.medicines.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                        ),
                      );
                    }
                    final Medicine medicine = controller.medicines[index];
                    return MedicineTile(
                      key: ValueKey<String>(medicine.brandId),
                      medicine: medicine,
                      onTap: () => Get.to(
                        () => MedicineDetailsPage(medicine: medicine),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ResultBar extends StatelessWidget {
  const _ResultBar({
    required this.total,
    required this.query,
    required this.allCount,
  });

  final int total;
  final String query;
  final int allCount;

  @override
  Widget build(BuildContext context) {
    final String label = query.isEmpty
        ? '${_pretty(allCount)} brands in the library'
        : '${_pretty(total)} result${total == 1 ? '' : 's'} for "$query"';
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Text(
            medicineDbRepo,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  static String _pretty(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }}
