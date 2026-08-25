class ItemResponse {
  final ItemPaginationData? data;

  ItemResponse({this.data});

  factory ItemResponse.fromJson(Map<String, dynamic> json) {
    return ItemResponse(
      data: json['data'] != null ? ItemPaginationData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data?.toJson(),
      };
}

class ItemPaginationData {
  final int currentPage;
  final List<Item> data;
  final String? firstPageUrl;
  final int from;
  final int lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String? path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  ItemPaginationData({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    required this.from,
    required this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory ItemPaginationData.fromJson(Map<String, dynamic> json) {
    var rawList = json['data'] as List?;
    List<Item> items =
        rawList?.map((e) => Item.fromJson(e)).toList() ?? [];

    return ItemPaginationData(
      currentPage: _parseInt(json['current_page'], defaultValue: 1),
      data: items,
      firstPageUrl: json['first_page_url']?.toString(),
      from: _parseInt(json['from'], defaultValue: 0),
      lastPage: _parseInt(json['last_page'], defaultValue: 1),
      lastPageUrl: json['last_page_url']?.toString(),
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
        'next_page_url': nextPageUrl,
        'path': path,
        'per_page': perPage,
        'prev_page_url': prevPageUrl,
        'to': to,
        'total': total,
      };
}

class Item {
  final int id;
  final String itemName;
  final String? itemDescription;
  final String itemPrice;
  final String? itemUnit;
  final String? itemType;
  final String? itemSize;
  final String? itemTax;
  final String itemStatus;
  final int? companyId;

  Item({
    required this.id,
    required this.itemName,
    this.itemDescription,
    required this.itemPrice,
    this.itemUnit,
    this.itemType,
    this.itemSize,
    this.itemTax,
    required this.itemStatus,
    this.companyId,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      itemName: json['item_name']?.toString() ?? '',
      itemDescription: json['item_description']?.toString(),
      itemPrice: json['item_price']?.toString() ?? '0.00',
      itemUnit: json['item_unit']?.toString() ?? '',
      itemType: json['item_type']?.toString() ?? '',
      itemSize: json['item_size']?.toString() ?? '',
      itemTax: json['item_tax']?.toString() ?? '0.00',
      itemStatus: json['item_status']?.toString() ?? 'Active',
      companyId: json['company_id'] is int
          ? json['company_id']
          : int.tryParse('${json['company_id']}'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'item_name': itemName,
        'item_description': itemDescription,
        'item_price': itemPrice,
        'item_unit': itemUnit,
        'item_type': itemType,
        'item_size': itemSize,
        'item_tax': itemTax,
        'item_status': itemStatus,
        'company_id': companyId,
      };

  bool get isActive => itemStatus.toLowerCase() == 'active';
}
