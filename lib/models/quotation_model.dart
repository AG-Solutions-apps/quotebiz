import 'buyer_model.dart';
import 'settings_model.dart';

class QuotationResponse {
  final QuotationPaginationData? data;

  QuotationResponse({this.data});

  factory QuotationResponse.fromJson(Map<String, dynamic> json) {
    return QuotationResponse(
      data: json['data'] != null ? QuotationPaginationData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data?.toJson(),
      };
}

class QuotationPaginationData {
  final int currentPage;
  final List<QuotationListItem> data;
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

  QuotationPaginationData({
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

  factory QuotationPaginationData.fromJson(Map<String, dynamic> json) {
    var rawList = json['data'] as List?;
    List<QuotationListItem> items =
        rawList?.map((e) => QuotationListItem.fromJson(e)).toList() ?? [];

    var rawLinks = json['links'] as List?;
    List<PaginationLink> linksList =
        rawLinks?.map((e) => PaginationLink.fromJson(e)).toList() ?? [];

    return QuotationPaginationData(
      currentPage: _parseInt(json['current_page'], defaultValue: 1),
      data: items,
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

class QuotationListItem {
  final int id;
  final String? quotationNo;
  final String quotationRef;
  final String? quotationDate;
  final int? quotationBuyerId;
  final String? buyerName;
  final String totalAmount;
  final String? quotationValidDate;
  final String quotationStatus;
  final int? companyId;

  QuotationListItem({
    required this.id,
    this.quotationNo,
    required this.quotationRef,
    this.quotationDate,
    this.quotationBuyerId,
    this.buyerName,
    required this.totalAmount,
    this.quotationValidDate,
    required this.quotationStatus,
    this.companyId,
  });

  factory QuotationListItem.fromJson(Map<String, dynamic> json) {
    return QuotationListItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      quotationNo: json['quotation_no']?.toString(),
      quotationRef: json['quotation_ref']?.toString() ?? '',
      quotationDate: json['quotation_date']?.toString(),
      quotationBuyerId: json['quotation_buyer_id'] is int
          ? json['quotation_buyer_id']
          : int.tryParse('${json['quotation_buyer_id']}'),
      buyerName: json['buyer_name']?.toString(),
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      quotationValidDate: json['quotation_valid_date']?.toString(),
      quotationStatus: json['quotation_status']?.toString() ?? 'Pending',
      companyId: json['company_id'] is int
          ? json['company_id']
          : int.tryParse('${json['company_id']}'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quotation_no': quotationNo,
        'quotation_ref': quotationRef,
        'quotation_date': quotationDate,
        'quotation_buyer_id': quotationBuyerId,
        'buyer_name': buyerName,
        'total_amount': totalAmount,
        'quotation_valid_date': quotationValidDate,
        'quotation_status': quotationStatus,
        'company_id': companyId,
      };
}

class QuotationPreviewData {
  final QuotationDetail data;
  final BranchSettings? branch;

  QuotationPreviewData({
    required this.data,
    this.branch,
  });

  factory QuotationPreviewData.fromJson(Map<String, dynamic> json) {
    return QuotationPreviewData(
      data: QuotationDetail.fromJson(json['data'] ?? {}),
      branch: json['branch'] != null ? BranchSettings.fromJson(json['branch']) : null,
    );
  }
}

class QuotationDetail {
  final int id;
  final String? quotationNo;
  final String quotationRef;
  final String? quotationDate;
  final int? quotationBuyerId;
  final String? buyerName;
  final String totalAmount;
  final String? quotationValidDate;
  final String quotationStatus;
  final String? quotationRemarks;
  final List<QuotationSubItem> subs;

  QuotationDetail({
    required this.id,
    this.quotationNo,
    required this.quotationRef,
    this.quotationDate,
    this.quotationBuyerId,
    this.buyerName,
    required this.totalAmount,
    this.quotationValidDate,
    required this.quotationStatus,
    this.quotationRemarks,
    required this.subs,
  });

  factory QuotationDetail.fromJson(Map<String, dynamic> json) {
    var rawSubs = json['subs'] as List?;
    List<QuotationSubItem> subList =
        rawSubs?.map((e) => QuotationSubItem.fromJson(e)).toList() ?? [];

    return QuotationDetail(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      quotationNo: json['quotation_no']?.toString(),
      quotationRef: json['quotation_ref']?.toString() ?? '',
      quotationDate: json['quotation_date']?.toString(),
      quotationBuyerId: json['quotation_buyer_id'] is int
          ? json['quotation_buyer_id']
          : int.tryParse('${json['quotation_buyer_id']}'),
      buyerName: json['buyer_name']?.toString(),
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      quotationValidDate: json['quotation_valid_date']?.toString(),
      quotationStatus: json['quotation_status']?.toString() ?? 'Pending',
      quotationRemarks: json['quotation_remarks']?.toString(),
      subs: subList,
    );
  }
}

class QuotationSubItem {
  int? id;
  int quotationSubItemId;
  String? itemName;
  String? itemDescription;
  String? itemType;
  String? quotationSubSize;
  String? quotationSubUnit;
  num quotationSubQnty;
  num quotationSubRate;
  num quotationSubDiscount;
  num quotationSubTax;
  num quotationSubAmount;

  QuotationSubItem({
    this.id,
    required this.quotationSubItemId,
    this.itemName,
    this.itemDescription,
    this.itemType,
    this.quotationSubSize,
    this.quotationSubUnit,
    required this.quotationSubQnty,
    required this.quotationSubRate,
    this.quotationSubDiscount = 0,
    this.quotationSubTax = 0,
    required this.quotationSubAmount,
  });

  factory QuotationSubItem.fromJson(Map<String, dynamic> json) {
    return QuotationSubItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      quotationSubItemId: json['quotation_sub_item_id'] is int
          ? json['quotation_sub_item_id']
          : int.tryParse('${json['quotation_sub_item_id']}') ?? 0,
      itemName: json['item_name']?.toString(),
      itemDescription: json['item_description']?.toString(),
      itemType: json['item_type']?.toString(),
      quotationSubSize: json['quotation_sub_size']?.toString(),
      quotationSubUnit: json['quotation_sub_unit']?.toString(),
      quotationSubQnty: num.tryParse('${json['quotation_sub_qnty']}') ?? 1,
      quotationSubRate: num.tryParse('${json['quotation_sub_rate']}') ?? 0,
      quotationSubDiscount: num.tryParse('${json['quotation_sub_discount']}') ?? 0,
      quotationSubTax: num.tryParse('${json['quotation_sub_tax']}') ?? 0,
      quotationSubAmount: num.tryParse('${json['quotation_sub_amount']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'quotation_sub_item_id': quotationSubItemId,
        if (itemName != null) 'item_name': itemName,
        if (itemDescription != null) 'item_description': itemDescription,
        if (itemType != null) 'item_type': itemType,
        'quotation_sub_size': quotationSubSize,
        'quotation_sub_unit': quotationSubUnit,
        'quotation_sub_qnty': quotationSubQnty,
        'quotation_sub_rate': quotationSubRate,
        'quotation_sub_discount': quotationSubDiscount,
        'quotation_sub_tax': quotationSubTax,
        'quotation_sub_amount': quotationSubAmount,
      };
}

class ActiveBuyer {
  final int id;
  final String buyerName;
  final String? buyerContactName;
  final String? buyerEmail;
  final String? buyerMobile;
  final String buyerStatus;

  ActiveBuyer({
    required this.id,
    required this.buyerName,
    this.buyerContactName,
    this.buyerEmail,
    this.buyerMobile,
    required this.buyerStatus,
  });

  factory ActiveBuyer.fromJson(Map<String, dynamic> json) {
    return ActiveBuyer(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      buyerName: json['buyer_name']?.toString() ?? '',
      buyerContactName: json['buyer_contact_name']?.toString(),
      buyerEmail: json['buyer_email']?.toString(),
      buyerMobile: json['buyer_mobile']?.toString(),
      buyerStatus: json['buyer_status']?.toString() ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'buyer_name': buyerName,
        'buyer_contact_name': buyerContactName,
        'buyer_email': buyerEmail,
        'buyer_mobile': buyerMobile,
        'buyer_status': buyerStatus,
      };
}

class ActiveItem {
  final int id;
  final String itemName;
  final String? itemDescription;
  final String itemPrice;
  final String? itemUnit;
  final String? itemType;
  final String? itemSize;
  final String? itemTax;
  final String itemStatus;

  ActiveItem({
    required this.id,
    required this.itemName,
    this.itemDescription,
    required this.itemPrice,
    this.itemUnit,
    this.itemType,
    this.itemSize,
    this.itemTax,
    required this.itemStatus,
  });

  factory ActiveItem.fromJson(Map<String, dynamic> json) {
    return ActiveItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      itemName: json['item_name']?.toString() ?? '',
      itemDescription: json['item_description']?.toString(),
      itemPrice: json['item_price']?.toString() ?? '0.00',
      itemUnit: json['item_unit']?.toString() ?? '',
      itemType: json['item_type']?.toString() ?? '',
      itemSize: json['item_size']?.toString() ?? '',
      itemTax: json['item_tax']?.toString() ?? '0.00',
      itemStatus: json['item_status']?.toString() ?? 'Active',
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
      };
}
