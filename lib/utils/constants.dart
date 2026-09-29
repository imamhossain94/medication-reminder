import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// App identity
// ---------------------------------------------------------------------------

const String appName = 'Medication Reminder';
const String appTagline = 'Never miss a dose again';
const String appLogo = 'assets/ic_launcher.png';

const String developerName = 'Md. Imam Hossain';
const String designerName = 'Md. Imam Hossain';

const String feedbackMail = 'mailto:imamagun94@gmail.com';
const String contactMail = 'mailto:imamagun94@gmail.com';

/// Must match `applicationId` in `android/app/build.gradle.kts` and the
/// package used in the Play Store listing.
const String appPackageId = 'com.newagedevs.medication_reminder';

/// Play Store listing for this app.
const String appLink = 'https://play.google.com/store/apps/details?id=$appPackageId';

/// The developer's other published apps.
const String storeLink =
    'https://play.google.com/store/apps/developer?id=NewAgeDevs';
const String privacyPolicyUrl =
    'https://medication-reminder-privay.blogspot.com/2022/04/medication-reminder-privacy-policy.html';

// ---------------------------------------------------------------------------
// Medicine data attribution
//
// The bundled/offline medicine database is **not** created by this app.
// It is downloaded from the open-source project below. Please keep this
// attribution visible in the app (About / Medicine database screens) and in
// the README whenever the data is redistributed.
// ---------------------------------------------------------------------------

/// Upstream repository the `medicine.db` file is pulled from at runtime.
const String medicineDbOwner = 'WSAyan';
const String medicineDbRepo = 'medicinedb';
const String medicineDbBranch = 'main';
const String medicineDbFileName = 'medicine.db';
const String medicineDbRepoUrl =
    'https://github.com/$medicineDbOwner/$medicineDbRepo';
const String medicineDbLicense = 'MIT License';
const String medicineDbAuthor = 'WSAyan';

/// Mirrors are tried in order until one of them delivers a valid database.
const List<String> medicineDbMirrors = [
  'https://raw.githubusercontent.com/$medicineDbOwner/$medicineDbRepo/$medicineDbBranch/$medicineDbFileName',
  'https://cdn.jsdelivr.net/gh/$medicineDbOwner/$medicineDbRepo@$medicineDbBranch/$medicineDbFileName',
  'https://github.com/$medicineDbOwner/$medicineDbRepo/raw/$medicineDbBranch/$medicineDbFileName',
];

// ---------------------------------------------------------------------------
// Brand palette
// ---------------------------------------------------------------------------

/// Primary – a friendly violet.
const Color brandPrimary = Color(0xFF6C4CE0);
const Color brandPrimaryDark = Color(0xFF4B31B4);
const Color brandPrimarySoft = Color(0xFFEDE7FF);

/// Secondary – fresh mint used for "taken / success" states.
const Color brandSecondary = Color(0xFF00C2A8);
const Color brandSecondarySoft = Color(0xFFDFF7F2);

/// Accent – warm coral used for warnings and the FAB.
const Color brandAccent = Color(0xFFFF6B6B);
const Color brandAccentSoft = Color(0xFFFFE6E6);

const Color brandAmber = Color(0xFFFFB020);
const Color brandBlue = Color(0xFF3E8BFF);

/// Splash gradient used on the loading screen and the home header.
const List<Color> brandGradient = [
  Color(0xFF7C4DFF),
  Color(0xFF6C4CE0),
  Color(0xFF00C2A8),
];

const scaffoldBackgroundLight = Color(0xFFF6F5FF);
const scaffoldBackgroundDark = Color(0xFF141326);
const surfaceLight = Color(0xFFFFFFFF);
const surfaceDark = Color(0xFF1F1D36);

// ---------------------------------------------------------------------------
// System bars
// ---------------------------------------------------------------------------

SystemUiOverlayStyle systemOverlay(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: isDark ? scaffoldBackgroundDark : Colors.white,
    systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  );
}

// ---------------------------------------------------------------------------
// Medicine forms
// ---------------------------------------------------------------------------

/// A medicine "form" (dosage form) with its own colour so the UI can stay
/// colourful while still being scannable.
class MedicineForm {
  final String name;
  final Color color;
  final IconData icon;

  const MedicineForm(this.name, this.color, this.icon);

  /// Background tint for chips / badges.
  Color get soft => color.withValues(alpha: 0.14);
}

/// The canonical list used by the "new reminder" form picker, in display order.
const List<MedicineForm> medicineForms = [
  MedicineForm('Tablet', Color(0xFF6C4CE0), Icons.medication_outlined),
  MedicineForm('Capsule', Color(0xFF3E8BFF), Icons.medication_liquid_outlined),
  MedicineForm('Suspension', Color(0xFF00C2A8), Icons.opacity_outlined),
  MedicineForm('Injection', Color(0xFFFF6B6B), Icons.vaccines_outlined),
  MedicineForm('Drops', Color(0xFF00B8D9), Icons.water_drop_outlined),
  MedicineForm('Inhaler/Spray', Color(0xFFFFB020), Icons.air_outlined),
  MedicineForm('Gel/Cream', Color(0xFFEC5F9E), Icons.face_outlined),
  MedicineForm('Powder', Color(0xFF8E7CFF), Icons.blur_on_outlined),
  MedicineForm('Soap', Color(0xFF34C77B), Icons.spa_outlined),
  MedicineForm('Bandage', Color(0xFFFF7849), Icons.healing_outlined),
  MedicineForm('Suppository', Color(0xFF9C6ADE), Icons.science_outlined),
  MedicineForm('Unspecified', Color(0xFF8A8AA3), Icons.help_outline),
];

/// The default form (a reminder that has not been linked to the database).
MedicineForm get defaultMedicineForm => medicineForms.last;

/// Keywords found in the `form` column of the database, ordered from the most
/// specific match to the least specific one.
const Map<String, String> formKeywords = {
  'capsule': 'Capsule',
  'cap': 'Capsule',
  'suppository': 'Suppository',
  'drops': 'Drops',
  'drop': 'Drops',
  'eye drop': 'Drops',
  'bar': 'Soap',
  'tablet': 'Tablet',
  'film': 'Tablet',
  'sachet': 'Powder',
  'powder': 'Powder',
  'patch': 'Bandage',
  'bandage': 'Bandage',
  'inhalation': 'Inhaler/Spray',
  'inhaler': 'Inhaler/Spray',
  'spray': 'Inhaler/Spray',
  'aerosol': 'Inhaler/Spray',
  'injection': 'Injection',
  'inj': 'Injection',
  'saline': 'Injection',
  'vaccine': 'Injection',
  'infusion': 'Injection',
  'im': 'Injection',
  'iv': 'Injection',
  'sc': 'Injection',
  'gel': 'Gel/Cream',
  'ointment': 'Gel/Cream',
  'cream': 'Gel/Cream',
  'paste': 'Gel/Cream',
  'shampoo': 'Gel/Cream',
  'lotion': 'Gel/Cream',
  'suspension': 'Suspension',
  'syrup': 'Suspension',
  'solution': 'Suspension',
  'emulsion': 'Suspension',
  'liquid': 'Suspension',
  'elixir': 'Suspension',
  'wash': 'Suspension',
  'rub': 'Suspension',
};
