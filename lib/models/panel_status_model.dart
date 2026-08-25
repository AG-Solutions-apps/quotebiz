class PanelStatusResponse {
  final int? code;
  final String? success;
  final String? message;
  final PanelVersion? version;
  final CompanyInfo? companyDetails;

  PanelStatusResponse({
    this.code,
    this.success,
    this.message,
    this.version,
    this.companyDetails,
  });

  factory PanelStatusResponse.fromJson(Map<String, dynamic> json) {
    return PanelStatusResponse(
      code: json['code'] is int ? json['code'] : int.tryParse('${json['code']}'),
      success: json['success']?.toString(),
      message: json['message']?.toString(),
      version: json['version'] != null ? PanelVersion.fromJson(json['version']) : null,
      companyDetails: json['company_detils'] != null
          ? CompanyInfo.fromJson(json['company_detils'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'success': success,
      'message': message,
      'version': version?.toJson(),
      'company_detils': companyDetails?.toJson(),
    };
  }

  bool get isActive => companyDetails?.companyStatus?.toLowerCase() == 'active';
}

class PanelVersion {
  final String? versionPanel;

  PanelVersion({this.versionPanel});

  factory PanelVersion.fromJson(Map<String, dynamic> json) {
    return PanelVersion(
      versionPanel: json['version_panel']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'version_panel': versionPanel,
  };
}

class CompanyInfo {
  final int? id;
  final String? companyName;
  final String? companyEmail;
  final String? companyStatus;

  CompanyInfo({
    this.id,
    this.companyName,
    this.companyEmail,
    this.companyStatus,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      companyName: json['company_name']?.toString(),
      companyEmail: json['company_email']?.toString(),
      companyStatus: json['company_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'company_name': companyName,
    'company_email': companyEmail,
    'company_status': companyStatus,
  };
}
