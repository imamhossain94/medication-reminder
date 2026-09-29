import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/bootstrap_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../services/database_service.dart';
import '../../services/prefs_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../widgets/common.dart';
import 'privacy_policy_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final SettingsController settings = Get.find<SettingsController>();
    final int brandCount = DatabaseService.instance.brandCount;
    final DateTime? updated = PrefsService.instance.dbUpdatedAt;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: brandGradient,
                ),
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        height: 42,
                        width: 42,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: brandPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              appName,
                              style: displayStyle(17, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              appTagline,
                              style: const TextStyle(
                                fontFamily: kBodyFont,
                                fontSize: 11.5,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.storage_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                brandCount > 0
                                    ? '${_group(brandCount)} medicines'
                                    : 'Library unavailable',
                                style: const TextStyle(
                                  fontFamily: kBodyFont,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              if (updated != null)
                                Text(
                                  'Updated ${_relative(updated)}',
                                  style: const TextStyle(
                                    fontFamily: kBodyFont,
                                    fontSize: 10.5,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Update database',
                          onPressed: () => _updateDatabase(context),
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                children: <Widget>[
                  _DrawerItem(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark mode',
                    trailing: Switch.adaptive(
                      value: Get.isDarkMode,
                      activeThumbColor: scheme.primary,
                      onChanged: (_) => settings.toggleTheme(),
                    ),
                    onTap: settings.toggleTheme,
                  ),
                  const _DrawerDivider(),
                  _DrawerItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About the app',
                    onTap: () => _showAbout(context),
                  ),
                  _DrawerItem(
                    icon: Icons.dataset_outlined,
                    label: 'Where the data comes from',
                    onTap: () => _showDataSource(context),
                  ),
                  _DrawerItem(
                    icon: Icons.shield_outlined,
                    label: 'Privacy policy',
                    onTap: () => Get.to(() => const PrivacyPolicyPage()),
                  ),
                  const _DrawerDivider(),
                  _DrawerItem(
                    icon: Icons.star_outline_rounded,
                    label: 'Rate the app',
                    onTap: () {
                      Get.back<void>();
                      _rate(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () {
                      Get.back<void>();
                      SharePlus.instance.share(
                        ShareParams(
                          text: 'Try $appName — never miss a dose again. $appLink',
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.alternate_email_rounded,
                    label: 'Contact',
                    onTap: () => _launch(contactMail),
                  ),
                ],
              ),
            ),
            Divider(color: scheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
              child: Row(
                children: <Widget>[
                  Text(
                    'v${PrefsService.instance.versionLabel}',
                    style: theme.textTheme.labelSmall,
                  ),
                  const Spacer(),
                  Text(
                    'Made with ❤ by $developerName',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _group(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  static String _relative(DateTime date) {
    final Duration d = DateTime.now().difference(date);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  static Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Oops', 'Could not open $url');
    }
  }

  static Future<void> _rate(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Enjoying the app?'),
        content: const Text(
          'A 5 star review on Google Play helps other people find a reliable '
          'medication reminder.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _launch(appLink);
            },
            child: const Text('Rate now'),
          ),
        ],
      ),
    );
  }

  static void _updateDatabase(BuildContext context) {
    final BootstrapController bootstrap = Get.find<BootstrapController>();
    Get.back<void>();
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Update medicine library?'),
        content: const Text(
          'The database will be downloaded again from the source repository. '
          'Your reminders are not affected.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Get.back<void>();
              final bool ok = await bootstrap.updateDatabase();
              Get.snackbar(
                ok ? 'All set' : 'Update failed',
                ok
                    ? 'The medicine library is up to date.'
                    : 'Could not reach the source repository. Please try again.',
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  static void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: appName,
      applicationVersion: 'v${PrefsService.instance.versionLabel}',
      applicationLegalese:
          'Medicine data from $medicineDbRepo ($medicineDbLicense).',
      children: <Widget>[
        const SizedBox(height: 14),
        const Text(
          '$appName helps you take your medicines on time. It works fully '
          'offline: your reminders never leave the device.',
        ),
      ],
    );
  }

  static void _showDataSource(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final ThemeData theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  height: 5,
                  width: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SectionTitle('Medicine database'),
              Text(
                'This app is a reminder app, not a pharmacy. The drug '
                'information you see in search results comes from a free, '
                'open-source SQLite database published on GitHub.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              AppCard(
                color: theme.colorScheme.primaryContainer,
                borderColor: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _kv(context, 'Source', '$medicineDbOwner/$medicineDbRepo'),
                    _kv(context, 'Repository', medicineDbRepoUrl),
                    _kv(context, 'License', medicineDbLicense),
                    _kv(context, 'Author', medicineDbAuthor),
                    _kv(
                      context,
                      'Note',
                      'Mostly Bangladeshi brands, community maintained.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _launch(medicineDbRepoUrl),
                  icon: const Icon(Icons.open_in_new, size: 17),
                  label: const Text('View on GitHub'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Always follow the advice of your doctor or pharmacist.',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 92,
            child: Text(
              k,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 18, color: scheme.primary),
      ),
      title: Text(label, style: Theme.of(context).textTheme.titleSmall),
      trailing: trailing,
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      );
}
