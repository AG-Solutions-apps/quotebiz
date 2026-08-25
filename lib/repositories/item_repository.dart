import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/item_model.dart';

class ItemRepository {
  final ApiClient _apiClient = ApiClient();

  /// Fetch all items without server-side pagination
  Future<List<Item>> getItems() async {
    final response = await _apiClient.get(
      ApiConstants.item, // calls /getItemList
      includeAuth: true,
    );

    if (response is Map) {
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((e) => Item.fromJson(e))
            .toList();
      } else if (response['data'] is Map && response['data']['data'] is List) {
        return (response['data']['data'] as List)
            .map((e) => Item.fromJson(e))
            .toList();
      }
    } else if (response is List) {
      return response.map((e) => Item.fromJson(e)).toList();
    }

    return [];
  }

  /// Create a new item (POST /item)
  Future<dynamic> createItem({
    required String itemName,
    String? itemType,
    String? itemDescription,
    required dynamic itemPrice,
    required dynamic itemTax,
    String? itemSize,
    String? itemUnit,
  }) async {
    final body = {
      'item_name': itemName.trim(),
      'item_type': itemType?.trim() ?? '',
      'item_description': itemDescription?.trim() ?? '',
      'item_price': itemPrice,
      'item_tax': itemTax,
      'item_size': itemSize?.trim() ?? '',
      'item_unit': itemUnit?.trim() ?? '',
    };

    final response = await _apiClient.post(
      ApiConstants.itemCrud,
      body: body,
      includeAuth: true,
    );

    return response;
  }

  /// Update an existing item (PUT /item/{id})
  Future<dynamic> updateItem({
    required int id,
    required String itemName,
    String? itemType,
    String? itemDescription,
    required dynamic itemPrice,
    required dynamic itemTax,
    String? itemSize,
    String? itemUnit,
    String itemStatus = 'Active',
  }) async {
    final body = {
      'item_name': itemName.trim(),
      'item_type': itemType?.trim() ?? '',
      'item_description': itemDescription?.trim() ?? '',
      'item_price': itemPrice,
      'item_tax': itemTax,
      'item_size': itemSize?.trim() ?? '',
      'item_unit': itemUnit?.trim() ?? '',
      'item_status': itemStatus,
    };

    final response = await _apiClient.put(
      '${ApiConstants.itemCrud}/$id',
      body: body,
      includeAuth: true,
    );

    return response;
  }
}
