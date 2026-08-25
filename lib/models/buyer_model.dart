class BuyerResponse {
  final BuyerPaginationData? data;

  BuyerResponse({this.data});

  factory BuyerResponse.fromJson(Map<String, dynamic> json) {
    return BuyerResponse(
      data: json['data'] != null ? BuyerPaginationData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data?.toJson(),
      };
}

class BuyerPaginationData {
  final int currentPage;
  final List<Buyer> data;
  final String? firstPageUrl;
  final int from;
  final int lastPage;
  final String? lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String? path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  BuyerPaginationData({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    required this.from,
    required this.lastPage,
    this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory BuyerPaginationData.fromJson(Map<String, dynamic> json) {
    var rawList = json['data'] as List?;
    List<Buyer> buyers =
        rawList?.map((e) => Buyer.fromJson(e)).toList() ?? [];

    var rawLinks = json['links'] as List?;
    List<PaginationLink> linksList =
        rawLinks?.map((e) => PaginationLink.fromJson(e)).toList() ?? [];

    return BuyerPaginationData(
      currentPage: _parseInt(json['current_page'], defaultValue: 1),
      data: buyers,
      firstPageUrl: json['first_page_url']?.toString(),
      from: _parseInt(json['from'], defaultValue: 0),
      lastPage: _parseInt(json['last_page'], defaultValue: 1),
      lastPageUrl: json['last_page_url']?.toString(),
      links: linksList,
      nextPageUrl: json['next_page_url']?.toString(),
      path: json['path']?.toString(),
      perPage: _parseInt(json['per_page'], defaultValue: 10),
      prevPageUrl: json['prev_page_url']?.toString(),
      to: _parseInt(json['to'], defaultValue: 0),
      total: _parseInt(json['total'], defaultValue: 0),
    );
  }

  static int _parseInt(dynamic val, {int defaultValue = 0}) {
    if (val == null) return defaultValue;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? defaultValue;
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'data': data.map((e) => e.toJson()).toList(),
        'first_page_url': firstPageUrl,
        'from': from,
        'last_page': lastPage,
        'last_page_url': lastPageUrl,
        'links': links.map((e) => e.toJson()).toList(),
        'next_page_url': nextPageUrl,
        'path': path,
        'per_page': perPage,
        'prev_page_url': prevPageUrl,
        'to': to,
        'total': total,
      };
}

class Buyer {
  final int id;
  final String buyerName;
  final String? buyerContactName;
  final String? buyerEmail;
  final String? buyerMobile;
  final String buyerStatus;
  final String? buyerGstVat;
  final String? buyerAddress;

  Buyer({
    required this.id,
    required this.buyerName,
    this.buyerContactName,
    this.buyerEmail,
    this.buyerMobile,
    required this.buyerStatus,
    this.buyerGstVat,
    this.buyerAddress,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      buyerName: json['buyer_name']?.toString() ?? '',
      buyerContactName: json['buyer_contact_name']?.toString(),
      buyerEmail: json['buyer_email']?.toString(),
      buyerMobile: json['buyer_mobile']?.toString(),
      buyerStatus: json['buyer_status']?.toString() ?? 'Active',
      buyerGstVat: json['buyer_gst_vat']?.toString(),
      buyerAddress: json['buyer_address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'buyer_name': buyerName,
        'buyer_contact_name': buyerContactName,
        'buyer_email': buyerEmail,
        'buyer_mobile': buyerMobile,
        'buyer_status': buyerStatus,
        'buyer_gst_vat': buyerGstVat,
        'buyer_address': buyerAddress,
      };

  bool get isActive => buyerStatus.toLowerCase() == 'active';
}

class PaginationLink {
  final String? url;
  final String label;
  final int? page;
  final bool active;

  PaginationLink({
    this.url,
    required this.label,
    this.page,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url']?.toString(),
      label: json['label']?.toString() ?? '',
      page: json['page'] is int
          ? json['page']
          : int.tryParse('${json['page']}'),
      active: json['active'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'label': label,
        'page': page,
        'active': active,
      };
}
