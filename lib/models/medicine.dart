class Medicine {
  String brandId;
  String genericId;
  String companyId;
  String brandName;
  String form;
  String strength;
  String price;
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