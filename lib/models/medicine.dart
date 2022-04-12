class Medicine {
  int? brandId;
  int? genericId;
  int? companyId;
  String? brandName;
  String? form;
  String? strength;
  String? price;
  String? packsize;

  Medicine(
      {this.brandId,
        this.genericId,
        this.companyId,
        this.brandName,
        this.form,
        this.strength,
        this.price,
        this.packsize});

  Medicine.fromJson(Map<String, dynamic> json) {
    brandId = json['brand_id'];
    genericId = json['generic_id'];
    companyId = json['company_id'];
    brandName = json['brand_name'];
    form = json['form'];
    strength = json['strength'];
    price = json['price'];
    packsize = json['packsize'];
  }

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