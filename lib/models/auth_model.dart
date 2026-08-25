class LoginResponse {
  final int? code;
  final UserInfo? userInfo;
  final List<UserListItem>? userList;
  final CompanyDetails? companyDetails;
  final Map<String, dynamic>? version;

  LoginResponse({
    this.code,
    this.userInfo,
    this.userList,
    this.companyDetails,
    this.version,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    var rawList = json['userN'] as List?;
    List<UserListItem>? users =
        rawList?.map((e) => UserListItem.fromJson(e)).toList();

    return LoginResponse(
      code: json['code'] is int ? json['code'] : int.tryParse('${json['code']}'),
      userInfo:
          json['UserInfo'] != null ? UserInfo.fromJson(json['UserInfo']) : null,
      userList: users,
      companyDetails: json['company_detils'] != null
          ? CompanyDetails.fromJson(json['company_detils'])
          : null,
      version: json['version'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'UserInfo': userInfo?.toJson(),
      'userN': userList?.map((e) => e.toJson()).toList(),
      'company_detils': companyDetails?.toJson(),
      'version': version,
    };
  }
}

class UserInfo {
  final String? token;
  final String? tokenExpiresAt;
  final User? user;

  UserInfo({
    this.token,
    this.tokenExpiresAt,
    this.user,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      token: json['token']?.toString(),
      tokenExpiresAt: json['token_expires_at']?.toString(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'token_expires_at': tokenExpiresAt,
        'user': user?.toJson(),
      };
}

class User {
  final int? id;
  final int? companyId;
  final String? name;
  final String? email;
  final String? mobile;
  final int? userType;
  final String? userPosition;
  final String? lastLogin;
  final String? status;

  User({
    this.id,
    this.companyId,
    this.name,
    this.email,
    this.mobile,
    this.userType,
    this.userPosition,
    this.lastLogin,
    this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      companyId: json['company_id'] is int
          ? json['company_id']
          : int.tryParse('${json['company_id']}'),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
      userType: json['user_type'] is int
          ? json['user_type']
          : int.tryParse('${json['user_type']}'),
      userPosition: json['user_position']?.toString(),
      lastLogin: json['last_login']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'name': name,
        'email': email,
        'mobile': mobile,
        'user_type': userType,
        'user_position': userPosition,
        'last_login': lastLogin,
        'status': status,
      };
}

class UserListItem {
  final int? id;
  final String? name;
  final int? userType;
  final String? userPosition;

  UserListItem({
    this.id,
    this.name,
    this.userType,
    this.userPosition,
  });

  factory UserListItem.fromJson(Map<String, dynamic> json) {
    return UserListItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      name: json['name']?.toString(),
      userType: json['user_type'] is int
          ? json['user_type']
          : int.tryParse('${json['user_type']}'),
      userPosition: json['user_position']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'user_type': userType,
        'user_position': userPosition,
      };
}

class CompanyDetails {
  final String? companyName;
  final String? companyEmail;

  CompanyDetails({
    this.companyName,
    this.companyEmail,
  });

  factory CompanyDetails.fromJson(Map<String, dynamic> json) {
    return CompanyDetails(
      companyName: json['company_name']?.toString(),
      companyEmail: json['company_email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'company_name': companyName,
        'company_email': companyEmail,
      };
}
