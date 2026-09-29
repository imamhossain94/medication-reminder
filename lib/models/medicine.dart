import 'package:hive/hive.dart';

import '../utils/constants.dart';
import 'medicine_details.dart';

part 'medicine.g.dart';

/// A single row of the `brand` table of the medicine database.
@HiveType(typeId: 0)
class Medicine {
  @HiveField(0)
  String brandId;
  @HiveField(1)
  String genericId;
  @HiveField(2)
  String companyId;
  @HiveField(3)
  String brandName;
  @HiveField(4)
  String form;
  @HiveField(5)
  String strength;
  @HiveField(6)
  String price;
  @HiveField(7)
  String packsize;
  /// Resolved from the `company_name` table (not persisted by Hive).
  @HiveField(8)
  String? companyName;

  Medicine({
    required this.brandId,
    required this.genericId,
    required this.companyId,
    required this.brandName,
    required this.form,
    required this.strength,
    required this.price,
    required this.packsize,
    this.companyName,
  });

  Medicine.fromJson(Map<String, dynamic> json)
      : brandId = (json['brand_id'] ?? '').toString(),
        genericId = (json['generic_id'] ?? '').toString(),
        companyId = (json['company_id'] ?? '').toString(),
        brandName = (json['brand_name'] ?? '').toString(),
        form = (json['form'] ?? '').toString(),
        strength = (json['strength'] ?? '').toString(),
        price = (json['price'] ?? '').toString(),
        packsize = (json['packsize'] ?? '').toString(),
        companyName = json['company_name']?.toString();

  /// Builds a [Medicine] from a database row.
  factory Medicine.fromRow(Map<String, Object?> row) => Medicine(
        brandId: (row['brand_id'] ?? '').toString(),
        genericId: (row['generic_id'] ?? '').toString(),
        companyId: (row['company_id'] ?? '').toString(),
        brandName: (row['brand_name'] ?? '').toString(),
        form: (row['form'] ?? '').toString(),
        strength: (row['strength'] ?? '').toString(),
        price: (row['price'] ?? '').toString(),
        packsize: (row['packsize'] ?? '').toString(),
        companyName: row['company_name']?.toString(),
      );

  /// "Napa 500 mg" — brand name + strength, with blanks handled.
  String get displayName {
    final String s = strength.trim();
    final String n = brandName.trim().isEmpty ? 'Unnamed medicine' : brandName.trim();
    return s.isEmpty ? n : '$n $s';
  }

  /// A short human readable form label, e.g. "Tablet".
  String get formLabel {
    final String resolved = resolveFormName(form);
    return resolved.isEmpty ? 'Unspecified' : resolved;
  }

  MedicineForm get medicineForm => formToMedicineForm(form);

  bool get hasPrice {
    final String p = price.trim();
    if (p.isEmpty || p == '0' || p == '0.0' || p == '0.00') return false;
    return double.tryParse(p) != null;
  }

  String get priceLabel => hasPrice ? '$price৳' : '—';

  Map<String, dynamic> toJson() => <String, dynamic>{
        'brand_id': brandId,
        'generic_id': genericId,
        'company_id': companyId,
        'brand_name': brandName,
        'form': form,
        'strength': strength,
        'price': price,
        'packsize': packsize,
        if (companyName != null) 'company_name': companyName,
      };
}
