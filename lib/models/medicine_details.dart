import '../utils/constants.dart';
import 'medicine.dart';

/// Everything the database knows about one brand, joined across tables.
class MedicineDetails {
  final Medicine medicine;
  final String genericName;
  final String indication;
  final String dose;
  final String contraIndication;
  final String sideEffect;
  final String precaution;
  final String interaction;
  final String modeOfAction;
  final String pregnancyCategory;

  const MedicineDetails({
    required this.medicine,
    this.genericName = '',
    this.indication = '',
    this.dose = '',
    this.contraIndication = '',
    this.sideEffect = '',
    this.precaution = '',
    this.interaction = '',
    this.modeOfAction = '',
    this.pregnancyCategory = '',
  });

  /// Sections shown on the details page (empty sections are skipped).
  List<MedicineDetailSection> get sections => <MedicineDetailSection>[
        if (indication.trim().isNotEmpty)
          MedicineDetailSection('What it treats', indication),
        if (dose.trim().isNotEmpty)
          MedicineDetailSection('How to use', dose),
        if (sideEffect.trim().isNotEmpty)
          MedicineDetailSection('Possible side effects', sideEffect),
        if (precaution.trim().isNotEmpty)
          MedicineDetailSection('Precautions', precaution),
        if (contraIndication.trim().isNotEmpty)
          MedicineDetailSection('Do not use if', contraIndication),
        if (interaction.trim().isNotEmpty)
          MedicineDetailSection('Drug interactions', interaction),
        if (modeOfAction.trim().isNotEmpty)
          MedicineDetailSection('How it works', modeOfAction),
      ];

  bool get hasGenericInfo => sections.isNotEmpty;
}

class MedicineDetailSection {
  final String title;
  final String body;
  const MedicineDetailSection(this.title, this.body);
}

/// Resolves the raw `form` column of the database into a canonical name.
String resolveFormName(String rawForm) {
  final String form = rawForm.toLowerCase().trim();
  if (form.isEmpty) return 'Unspecified';

  // Ordered list: most specific keywords first.
  const List<String> priority = <String>[
    'suppository',
    'inhalation',
    'inhaler',
    'suspension',
    'capsule',
    'injection',
    'vaccine',
    'saline',
    'infusion',
    'tablet',
    'drops',
    'spray',
    'cream',
    'ointment',
    'gel',
    'lotion',
    'shampoo',
    'powder',
    'sachet',
    'bandage',
    'patch',
    'syrup',
    'solution',
    'elixir',
    'emulsion',
    'liquids',
    'bar',
  ];

  for (final String keyword in priority) {
    if (form.contains(keyword)) {
      return formKeywords[keyword] ?? 'Unspecified';
    }
  }
  if (form.contains('film') || form.contains('cap')) return 'Capsule';
  if (form.contains('tablet')) return 'Tablet';
  return 'Unspecified';
}

/// Maps the raw `form` string to the [MedicineForm] used for icons/colors.
MedicineForm formToMedicineForm(String rawForm) {
  final String name = resolveFormName(rawForm);
  for (final MedicineForm f in medicineForms) {
    if (f.name == name) return f;
  }
  return defaultMedicineForm;
}
