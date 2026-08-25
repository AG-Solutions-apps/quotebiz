class DashboardResponse {
  final DashboardData? data;

  DashboardResponse({this.data});

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data?.toJson(),
      };
}

class DashboardData {
  final int totalQuotations;
  final int pendingQuotations;
  final int approvedQuotations;
  final String monthlyAmount;
  final List<QuotationItem> lastQuotations;
  final List<Graph1StatusItem> graph1;
  final Graph2Trend? graph2;

  DashboardData({
    required this.totalQuotations,
    required this.pendingQuotations,
    required this.approvedQuotations,
    required this.monthlyAmount,
    required this.lastQuotations,
    required this.graph1,
    this.graph2,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    var rawQuotations = json['last_quotations'] as List?;
    List<QuotationItem> quotations =
        rawQuotations?.map((e) => QuotationItem.fromJson(e)).toList() ?? [];

    var rawGraph1 = json['graph1'] as List?;
    List<Graph1StatusItem> statusList =
        rawGraph1?.map((e) => Graph1StatusItem.fromJson(e)).toList() ?? [];

    return DashboardData(
      totalQuotations: _parseInt(json['total_quotations']),
      pendingQuotations: _parseInt(json['pending_quotations']),
      approvedQuotations: _parseInt(json['approved_quotations']),
      monthlyAmount: json['monthlyAmount']?.toString() ?? '0.00',
      lastQuotations: quotations,
      graph1: statusList,
      graph2: json['graph2'] != null ? Graph2Trend.fromJson(json['graph2']) : null,
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() => {
        'total_quotations': totalQuotations,
        'pending_quotations': pendingQuotations,
        'approved_quotations': approvedQuotations,
        'monthlyAmount': monthlyAmount,
        'last_quotations': lastQuotations.map((e) => e.toJson()).toList(),
        'graph1': graph1.map((e) => e.toJson()).toList(),
        'graph2': graph2?.toJson(),
      };
}

class QuotationItem {
  final int? id;
  final String? quotationNo;
  final String? quotationRef;
  final String? quotationDate;
  final int? quotationBuyerId;
  final String? buyerName;
  final String? totalAmount;
  final String? quotationValidDate;
  final String? quotationStatus;
  final int? companyId;

  QuotationItem({
    this.id,
    this.quotationNo,
    this.quotationRef,
    this.quotationDate,
    this.quotationBuyerId,
    this.buyerName,
    this.totalAmount,
    this.quotationValidDate,
    this.quotationStatus,
    this.companyId,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      quotationNo: json['quotation_no']?.toString(),
      quotationRef: json['quotation_ref']?.toString(),
      quotationDate: json['quotation_date']?.toString(),
      quotationBuyerId: json['quotation_buyer_id'] is int
          ? json['quotation_buyer_id']
          : int.tryParse('${json['quotation_buyer_id']}'),
      buyerName: json['buyer_name']?.toString(),
      totalAmount: json['total_amount']?.toString(),
      quotationValidDate: json['quotation_valid_date']?.toString(),
      quotationStatus: json['quotation_status']?.toString(),
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

class Graph1StatusItem {
  final String quotationStatus;
  final int total;

  Graph1StatusItem({
    required this.quotationStatus,
    required this.total,
  });

  factory Graph1StatusItem.fromJson(Map<String, dynamic> json) {
    return Graph1StatusItem(
      quotationStatus: json['quotation_status']?.toString() ?? 'Pending',
      total: json['total'] is int
          ? json['total']
          : int.tryParse('${json['total']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'quotation_status': quotationStatus,
        'total': total,
      };
}

class Graph2Trend {
  final List<String> labels;
  final List<double> data;

  Graph2Trend({
    required this.labels,
    required this.data,
  });

  factory Graph2Trend.fromJson(Map<String, dynamic> json) {
    var rawLabels = json['labels'] as List?;
    var rawData = json['data'] as List?;

    List<String> parsedLabels =
        rawLabels?.map((e) => e.toString()).toList() ?? [];
    List<double> parsedData = rawData
            ?.map((e) =>
                e is num ? e.toDouble() : double.tryParse(e.toString()) ?? 0.0)
            .toList() ??
        [];

    return Graph2Trend(
      labels: parsedLabels,
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() => {
        'labels': labels,
        'data': data,
      };
}
