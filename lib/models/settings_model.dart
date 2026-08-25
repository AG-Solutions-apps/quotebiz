class UserProfile {
  final int id;
  final String name;
  final String? mobile;
  final String? email;
  final String? cpassword;

  UserProfile({
    required this.id,
    required this.name,
    this.mobile,
    this.email,
    this.cpassword,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString(),
      email: json['email']?.toString(),
      cpassword: json['cpassword']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'email': email,
        'cpassword': cpassword,
      };
}

class BranchSettings {
  final String? branchName;
  final String? branchAddress;
  final String? branchGst;
  final String? branchMobileNo;
  final String? branchEmailId;
  final String? branchCurrency;
  final String? branchTaxRate;
  final String? branchFooter;
  final String? branchLogo;
  final String? branchSign;
  final String? branchSignName;
  final String? branchTC;

  BranchSettings({
    this.branchName,
    this.branchAddress,
    this.branchGst,
    this.branchMobileNo,
    this.branchEmailId,
    this.branchCurrency,
    this.branchTaxRate,
    this.branchFooter,
    this.branchLogo,
    this.branchSign,
    this.branchSignName,
    this.branchTC,
  });

  factory BranchSettings.fromJson(Map<String, dynamic> json) {
    return BranchSettings(
      branchName: json['branch_name']?.toString(),
      branchAddress: json['branch_address']?.toString(),
      branchGst: json['branch_gst']?.toString(),
      branchMobileNo: json['branch_mobile_no']?.toString(),
      branchEmailId: json['branch_email_id']?.toString(),
      branchCurrency: json['branch_currency']?.toString() ?? 'INR',
      branchTaxRate: json['branch_tax_rate']?.toString() ?? '18',
      branchFooter: json['branch_footer']?.toString(),
      branchLogo: json['branch_logo']?.toString(),
      branchSign: json['branch_sign']?.toString(),
      branchSignName: json['branch_sign_name']?.toString(),
      branchTC: json['branch_t_c']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'branch_name': branchName,
        'branch_address': branchAddress,
        'branch_gst': branchGst,
        'branch_mobile_no': branchMobileNo,
        'branch_email_id': branchEmailId,
        'branch_currency': branchCurrency,
        'branch_tax_rate': branchTaxRate,
        'branch_footer': branchFooter,
        'branch_logo': branchLogo,
        'branch_sign': branchSign,
        'branch_sign_name': branchSignName,
        'branch_t_c': branchTC,
      };
}
