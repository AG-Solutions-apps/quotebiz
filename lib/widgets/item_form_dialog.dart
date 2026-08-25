import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/item_model.dart';
import '../repositories/item_repository.dart';

class ItemFormDialog extends StatefulWidget {
  final Item? item; // Null for creation, populated for editing

  const ItemFormDialog({
    super.key,
    this.item,
  });

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final ItemRepository _itemRepository = ItemRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _sizeController;
  late final TextEditingController _unitController;
  late final TextEditingController _priceController;
  late final TextEditingController _taxController;
  late String _status;

  bool _isSubmitting = false;
  String? _errorMessage;
  int _descCharCount = 0;

  bool get isEditMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.itemName ?? '');
    _typeController = TextEditingController(text: item?.itemType ?? '');
    _descriptionController = TextEditingController(text: item?.itemDescription ?? '');
    _sizeController = TextEditingController(text: item?.itemSize ?? '');
    _unitController = TextEditingController(text: item?.itemUnit ?? '');
    _priceController = TextEditingController(text: item != null ? item.itemPrice : '');
    _taxController = TextEditingController(text: item != null ? item.itemTax ?? '' : '');
    _status = item?.itemStatus ?? 'Active';

    _descCharCount = _descriptionController.text.length;
    _descriptionController.addListener(() {
      setState(() {
        _descCharCount = _descriptionController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _sizeController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      final type = _typeController.text.trim();
      final description = _descriptionController.text.trim();
      final size = _sizeController.text.trim();
      final unit = _unitController.text.trim();
      final price = num.tryParse(_priceController.text.trim()) ?? 0;
      final tax = num.tryParse(_taxController.text.trim()) ?? 0;

      if (isEditMode) {
        await _itemRepository.updateItem(
          id: widget.item!.id,
          itemName: name,
          itemType: type,
          itemDescription: description,
          itemPrice: price,
          itemTax: tax,
          itemSize: size,
          itemUnit: unit,
          itemStatus: _status,
        );
      } else {
        await _itemRepository.createItem(
          itemName: name,
          itemType: type,
          itemDescription: description,
          itemPrice: price,
          itemTax: tax,
          itemSize: size,
          itemUnit: unit,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true); // Return true to trigger refresh
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isSubmitting = false;
      });
    }
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          children: isRequired
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 520,
          maxHeight: 740,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Dialog Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditMode ? 'Edit Item' : 'Create New Item',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context, false),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // 2. Form Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Error Banner
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFDC2626),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFF991B1B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Item Name *
                      _buildFieldLabel('Item Name', isRequired: true),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter item name',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter item name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Item Type
                      _buildFieldLabel('Item Type', isRequired: false),
                      TextFormField(
                        controller: _typeController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Sheet',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _buildFieldLabel('Description', isRequired: false),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        maxLength: 500,
                        buildCounter: (
                          context, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) =>
                            null,
                        decoration: const InputDecoration(
                          hintText: 'Enter item description (optional)',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Optional field',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            '$_descCharCount/500 characters',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Size & Unit (Row)
                      Row(
                        children: [
                          // Size
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Size', isRequired: false),
                                TextFormField(
                                  controller: _sizeController,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g., 250ml, 500g',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Unit
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Unit', isRequired: false),
                                TextFormField(
                                  controller: _unitController,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g., ml, g, kg, pcs',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Price *
                      _buildFieldLabel('Price', isRequired: true),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            child: Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(minWidth: 36),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter price';
                          }
                          if (double.tryParse(val.trim()) == null) {
                            return 'Please enter a valid price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tax (%) *
                      _buildFieldLabel('Tax (%)', isRequired: true),
                      TextFormField(
                        controller: _taxController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            child: Text(
                              '%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(minWidth: 36),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter tax percentage';
                          }
                          if (double.tryParse(val.trim()) == null) {
                            return 'Please enter a valid percentage';
                          }
                          return null;
                        },
                      ),

                      // Status (in Edit mode)
                      if (isEditMode) ...[
                        const SizedBox(height: 16),
                        _buildFieldLabel('Status', isRequired: false),
                        DropdownButtonFormField<String>(
                          initialValue: _status,
                          items: const [
                            DropdownMenuItem(value: 'Active', child: Text('Active')),
                            DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _status = val;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1, color: AppColors.divider),

            // 3. Footer Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isEditMode ? 'Update Item' : 'Create Item',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
