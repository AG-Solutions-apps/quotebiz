import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/buyer_model.dart';
import '../repositories/buyer_repository.dart';

class CreateClientDialog extends StatefulWidget {
  final Buyer? buyer; // Null for create mode, non-null for edit mode

  const CreateClientDialog({
    super.key,
    this.buyer,
  });

  @override
  State<CreateClientDialog> createState() => _CreateClientDialogState();
}

class _CreateClientDialogState extends State<CreateClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final BuyerRepository _buyerRepository = BuyerRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _contactPersonController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _gstVatController;
  late final TextEditingController _addressController;
  late String _status;

  bool _isSubmitting = false;
  String? _errorMessage;
  int _addressCharCount = 0;

  bool get isEditMode => widget.buyer != null;

  @override
  void initState() {
    super.initState();
    final buyer = widget.buyer;
    _nameController = TextEditingController(text: buyer?.buyerName ?? '');
    _contactPersonController = TextEditingController(text: buyer?.buyerContactName ?? '');
    _emailController = TextEditingController(text: buyer?.buyerEmail ?? '');
    _mobileController = TextEditingController(text: buyer?.buyerMobile ?? '');
    _gstVatController = TextEditingController(text: buyer?.buyerGstVat ?? '');
    _addressController = TextEditingController(text: buyer?.buyerAddress ?? '');
    _status = buyer?.buyerStatus ?? 'Active';

    _addressCharCount = _addressController.text.length;
    _addressController.addListener(() {
      setState(() {
        _addressCharCount = _addressController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _gstVatController.dispose();
    _addressController.dispose();
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
      final contactPerson = _contactPersonController.text.trim();
      final email = _emailController.text.trim();
      final mobile = _mobileController.text.trim();
      final gstVat = _gstVatController.text.trim();
      final address = _addressController.text.trim();

      if (isEditMode) {
        await _buyerRepository.updateBuyer(
          id: widget.buyer!.id,
          buyerName: name,
          buyerContactName: contactPerson,
          buyerEmail: email,
          buyerMobile: mobile,
          buyerGstVat: gstVat,
          buyerAddress: address,
          buyerStatus: _status,
        );
      } else {
        await _buyerRepository.createBuyer(
          buyerName: name,
          buyerContactName: contactPerson,
          buyerEmail: email,
          buyerMobile: mobile,
          buyerGstVat: gstVat,
          buyerAddress: address,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true); // Return true on success to trigger refresh
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
                    child: Icon(
                      isEditMode ? Icons.edit_note_rounded : Icons.domain_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditMode ? 'Edit Client' : 'Create New Client',
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

            // 2. Form Body (Scrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Error message if any
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

                      // 1. Client Name *
                      _buildFieldLabel('Client Name', isRequired: true),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter client company name',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter client name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 2. Contact Person *
                      _buildFieldLabel('Contact Person', isRequired: true),
                      TextFormField(
                        controller: _contactPersonController,
                        decoration: const InputDecoration(
                          hintText: 'Enter contact person name',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter contact person name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 3. Email Address *
                      _buildFieldLabel('Email Address', isRequired: true),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'client@example.com',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter email address';
                          }
                          if (!val.contains('@') || !val.contains('.')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 4. Mobile Number *
                      _buildFieldLabel('Mobile Number', isRequired: true),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Enter 10-digit mobile number',
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 5. GST/VAT Number
                      _buildFieldLabel('GST/VAT Number', isRequired: false),
                      TextFormField(
                        controller: _gstVatController,
                        decoration: const InputDecoration(
                          hintText: 'Enter GST/VAT number (optional)',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 6. Address
                      _buildFieldLabel('Address', isRequired: false),
                      TextFormField(
                        controller: _addressController,
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
                          hintText: 'Enter client address (optional)',
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
                            '$_addressCharCount/500 characters',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),

                      // 7. Status * (Edit Mode)
                      if (isEditMode) ...[
                        const SizedBox(height: 16),
                        _buildFieldLabel('Status', isRequired: true),
                        DropdownButtonFormField<String>(
                          initialValue: _status,
                          items: const [
                            DropdownMenuItem(
                              value: 'Active',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_outline_rounded, color: AppColors.successGreen, size: 18),
                                  SizedBox(width: 8),
                                  Text('Active', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Inactive',
                              child: Row(
                                children: [
                                  Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 18),
                                  SizedBox(width: 8),
                                  Text('Inactive', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
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
                            isEditMode ? 'Update Client' : 'Create Client',
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
