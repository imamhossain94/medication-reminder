import 'package:hive/hive.dart';

part 'medicine.g.dart';

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

  Medicine(
      {required this.brandId,
        required this.genericId,
        required this.companyId,
        required this.brandName,
        required this.form,
        required this.strength,
        required this.price,
        required this.packsize});

  Medicine.fromJson(Map<String, dynamic> json):
    brandId = json['brand_id']??'',
    genericId = json['generic_id']??'',
    companyId = json['company_id']??'',
    brandName = json['brand_name']??'',
    form = json['form']??'',
    strength = json['strength']??'',
    price = json['price']??'',
    packsize = json['packsize']??'';


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['brand_id'] = brandId;
    data['generic_id'] = genericId;
    data['company_id'] = companyId;
    data['brand_name'] = brandName;
    data['form'] = form;
    data['strength'] = strength;
    data['price'] = price;
    data['packsize'] = packsize;
    return data;
  }
}