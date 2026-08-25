class ApiConstants {
  // Universal Base URL
  static const String baseUrl = 'https://quotebiz.in/crmapi/public/api';

  // Branch Images Base URL (mapped from home/agsho09a/public_html/quotebiz.in/crm/images/branch_images/)
  static const String branchImageBaseUrl = 'https://quotebiz.in/crm/images/branch_images';

  static String getBranchImageUrl(String? imageName) {
    if (imageName == null || imageName.trim().isEmpty) return '';
    final name = imageName.trim();
    if (name.startsWith('http://') || name.startsWith('https://')) {
      return name;
    }
    return '$branchImageBaseUrl/$name';
  }

  // Endpoints - only change endpoint paths here
  static const String panelCheckStatus = '/panel-check-status';
  static const String panelLogin = '/panel-login';
  static const String createSignup = '/createsignup';
  static const String dashboard = '/dashboard';
  static const String buyer = '/getBuyerList';
  static const String buyerCrud = '/buyer';
  static const String item = '/getItemList';
  static const String itemCrud = '/item';
  static const String quotation = '/getQuotationList';
  static const String quotationCrud = '/quotation';
  static const String quotationRef = '/quotation-ref';
  static const String activeBuyers = '/activeBuyers';
  static const String activeItems = '/activeItems';
  static const String panelFetchProfile = '/panel-fetch-profile';
  static const String panelFetchBranch = '/panel-fetch-branch';
  static const String panelUpdateBranch = '/panel-update-branch';

  // Request Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerAuthorization = 'Authorization';
  static const String jsonType = 'application/json';
}
