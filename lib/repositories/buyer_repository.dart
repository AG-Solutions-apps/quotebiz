import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/buyer_model.dart';

class BuyerRepository {
  final ApiClient _apiClient = ApiClient();

  /// Fetch all buyers / clients without server-side pagination
  Future<List<Buyer>> getBuyers() async {
    final response = await _apiClient.get(
      ApiConstants.buyer, // calls /getBuyerList
      includeAuth: true,
    );

    if (response is Map) {
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((e) => Buyer.fromJson(e))
            .toList();
      } else if (response['data'] is Map && response['data']['data'] is List) {
        return (response['data']['data'] as List)
            .map((e) => Buyer.fromJson(e))
            .toList();
      }
    } else if (response is List) {
      return response.map((e) => Buyer.fromJson(e)).toList();
    }

    return [];
  }

  /// Create a new client / buyer (POST /buyer)
  Future<dynamic> createBuyer({
    required String buyerName,
    required String buyerContactName,
    required String buyerEmail,
    required String buyerMobile,
    String? buyerGstVat,
    String? buyerAddress,
  }) async {
    final body = {
      'buyer_name': buyerName.trim(),
      'buyer_contact_name': buyerContactName.trim(),
      'buyer_email': buyerEmail.trim(),
      'buyer_mobile': buyerMobile.trim(),
      'buyer_gst_vat': (buyerGstVat != null && buyerGstVat.trim().isNotEmpty)
          ? buyerGstVat.trim()
          : null,
      'buyer_address': (buyerAddress != null && buyerAddress.trim().isNotEmpty)
          ? buyerAddress.trim()
          : null,
    };

    final response = await _apiClient.post(
      ApiConstants.buyerCrud,
      body: body,
      includeAuth: true,
    );

    return response;
  }

  /// Update an existing client / buyer (PUT /buyer/{id})
  Future<dynamic> updateBuyer({
    required int id,
    required String buyerName,
    required String buyerContactName,
    required String buyerEmail,
    required String buyerMobile,
    String? buyerGstVat,
    String? buyerAddress,
    String buyerStatus = 'Active',
  }) async {
    final body = {
      'buyer_name': buyerName.trim(),
      'buyer_contact_name': buyerContactName.trim(),
      'buyer_email': buyerEmail.trim(),
      'buyer_mobile': buyerMobile.trim(),
      'buyer_gst_vat': (buyerGstVat != null && buyerGstVat.trim().isNotEmpty)
          ? buyerGstVat.trim()
          : null,
      'buyer_address': (buyerAddress != null && buyerAddress.trim().isNotEmpty)
          ? buyerAddress.trim()
          : null,
      'buyer_status': buyerStatus,
    };

    final response = await _apiClient.put(
      '${ApiConstants.buyerCrud}/$id',
      body: body,
      includeAuth: true,
    );

    return response;
  }
}
