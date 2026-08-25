import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/quotation_model.dart';

class QuotationRepository {
  final ApiClient _apiClient = ApiClient();

  /// Fetch all quotations without server-side pagination
  Future<List<QuotationListItem>> getQuotations() async {
    final response = await _apiClient.get(
      ApiConstants.quotation, // calls /getQuotationList
      includeAuth: true,
    );

    if (response is Map) {
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((e) => QuotationListItem.fromJson(e))
            .toList();
      } else if (response['data'] is Map && response['data']['data'] is List) {
        return (response['data']['data'] as List)
            .map((e) => QuotationListItem.fromJson(e))
            .toList();
      }
    } else if (response is List) {
      return response.map((e) => QuotationListItem.fromJson(e)).toList();
    }

    return [];
  }

  /// Fetch single quotation by ID (GET /quotation/{id})
  Future<QuotationDetail> getQuotationById(int id) async {
    final response = await _apiClient.get(
      '${ApiConstants.quotationCrud}/$id',
      includeAuth: true,
    );

    if (response is Map && response['data'] != null) {
      return QuotationDetail.fromJson(response['data']);
    }
    throw Exception('Failed to load quotation details');
  }

  /// Fetch full quotation preview with branch details (GET /quotation/{id})
  Future<QuotationPreviewData> getQuotationPreview(int id) async {
    final response = await _apiClient.get(
      '${ApiConstants.quotationCrud}/$id',
      includeAuth: true,
    );

    if (response is Map) {
      return QuotationPreviewData.fromJson(Map<String, dynamic>.from(response));
    }
    throw Exception('Failed to load quotation preview');
  }

  /// Fetch auto-generated quotation reference number (e.g. QT-DO-25-26-4)
  Future<String> getQuotationRef() async {
    final response = await _apiClient.get(
      ApiConstants.quotationRef,
      includeAuth: true,
    );

    if (response is Map && response['data'] != null) {
      return response['data'].toString();
    }
    return '';
  }

  /// Fetch active buyers for dropdown
  Future<List<ActiveBuyer>> getActiveBuyers() async {
    final response = await _apiClient.get(
      ApiConstants.activeBuyers,
      includeAuth: true,
    );

    if (response is Map && response['data'] is List) {
      return (response['data'] as List)
          .map((e) => ActiveBuyer.fromJson(e))
          .toList();
    }
    return [];
  }

  /// Fetch active items for dropdown
  Future<List<ActiveItem>> getActiveItems() async {
    final response = await _apiClient.get(
      ApiConstants.activeItems,
      includeAuth: true,
    );

    if (response is Map && response['data'] is List) {
      return (response['data'] as List)
          .map((e) => ActiveItem.fromJson(e))
          .toList();
    }
    return [];
  }

  /// Create a new quotation (POST /quotation)
  Future<dynamic> createQuotation({
    required String quotationRef,
    required String quotationDate,
    required dynamic quotationBuyerId,
    required String quotationValidDate,
    required String quotationRemarks,
    required List<QuotationSubItem> subs,
  }) async {
    final body = {
      'quotation_ref': quotationRef.trim(),
      'quotation_date': quotationDate.trim(),
      'quotation_buyer_id': quotationBuyerId.toString(),
      'quotation_valid_date': quotationValidDate.trim(),
      'quotation_remarks': quotationRemarks.trim(),
      'subs': subs.map((e) => e.toJson()).toList(),
    };

    final response = await _apiClient.post(
      ApiConstants.quotationCrud,
      body: body,
      includeAuth: true,
    );

    return response;
  }

  /// Update an existing quotation (PUT /quotation/{id})
  Future<dynamic> updateQuotation({
    required int id,
    required String quotationDate,
    required dynamic quotationBuyerId,
    required String quotationValidDate,
    required String quotationRemarks,
    required String quotationStatus,
    required List<QuotationSubItem> subs,
  }) async {
    final body = {
      'quotation_date': quotationDate.trim(),
      'quotation_buyer_id': quotationBuyerId is int
          ? quotationBuyerId
          : int.tryParse('$quotationBuyerId') ?? quotationBuyerId,
      'quotation_valid_date': quotationValidDate.trim(),
      'quotation_remarks': quotationRemarks.trim(),
      'quotation_status': quotationStatus.trim(),
      'subs': subs.map((e) => e.toJson()).toList(),
    };

    final response = await _apiClient.put(
      '${ApiConstants.quotationCrud}/$id',
      body: body,
      includeAuth: true,
    );

    return response;
  }
}
