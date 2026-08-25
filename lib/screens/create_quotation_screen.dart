import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/quotation_model.dart';
import '../repositories/quotation_repository.dart';

class CreateQuotationScreen extends StatefulWidget {
  final int? quotationId; // Null for creation, non-null for edit
  final String? quotationRef;

  const CreateQuotationScreen({
    super.key,
    this.quotationId,
    this.quotationRef,
  });

  @override
  State<CreateQuotationScreen> createState() => _CreateQuotationScreenState();
}

class _QuotationItemRowState {
  int? subId;
  ActiveItem? selectedItem;
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController rateController = TextEditingController(text: '0.00');
  final TextEditingController discountController = TextEditingController(text: '0.00');
  final TextEditingController taxController = TextEditingController(text: '0.00');
  double amount = 0.0;

  void dispose() {
    sizeController.dispose();
    unitController.dispose();
    qtyController.dispose();
    rateController.dispose();
    discountController.dispose();
    taxController.dispose();
  }

  void recalculate() {
    final qty = double.tryParse(qtyController.text.trim()) ?? 0.0;
    final rate = double.tryParse(rateController.text.trim()) ?? 0.0;
    final discountPercent = double.tryParse(discountController.text.trim()) ?? 0.0;
    final taxPercent = double.tryParse(taxController.text.trim()) ?? 0.0;

    final subtotal = qty * rate;
    final afterDiscount = subtotal - (subtotal * (discountPercent / 100));
    amount = afterDiscount + (afterDiscount * (taxPercent / 100));
  }
}

class _CreateQuotationScreenState extends State<CreateQuotationScreen> {
  final QuotationRepository _quotationRepository = QuotationRepository();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _refController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _validUntilController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController(
    text: 'We hope you find our offer to be in line with your requirement.',
  );

  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedValidUntil;
  ActiveBuyer? _selectedBuyer;
  String _selectedStatus = 'Pending';

  List<ActiveBuyer> _buyers = [];
  List<ActiveItem> _items = [];
  final List<_QuotationItemRowState> _itemRows = [];

  bool _isInitialLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get isEditMode => widget.quotationId != null;

  final DateFormat _displayFormat = DateFormat('dd / MM / yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _dateController.text = _displayFormat.format(_selectedDate);
    _loadInitialData();
  }

  @override
  void dispose() {
    _refController.dispose();
    _dateController.dispose();
    _validUntilController.dispose();
    _remarksController.dispose();
    for (var row in _itemRows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      if (isEditMode) {
        // Edit Mode: Fetch Quotation Details, Active Buyers, and Active Items
        final results = await Future.wait([
          _quotationRepository.getQuotationById(widget.quotationId!),
          _quotationRepository.getActiveBuyers(),
          _quotationRepository.getActiveItems(),
        ]);

        if (!mounted) return;

        final detail = results[0] as QuotationDetail;
        final buyers = results[1] as List<ActiveBuyer>;
        final items = results[2] as List<ActiveItem>;

        _buyers = buyers;
        _items = items;
        _refController.text = detail.quotationRef;
        _selectedStatus = detail.quotationStatus;
        _remarksController.text = detail.quotationRemarks ??
            'We hope you find our offer to be in line with your requirement.';

        // Parse Dates
        if (detail.quotationDate != null) {
          try {
            _selectedDate = DateTime.parse(detail.quotationDate!);
            _dateController.text = _displayFormat.format(_selectedDate);
          } catch (_) {}
        }

        if (detail.quotationValidDate != null) {
          try {
            _selectedValidUntil = DateTime.parse(detail.quotationValidDate!);
            _validUntilController.text = _displayFormat.format(_selectedValidUntil!);
          } catch (_) {}
        }

        // Match Buyer
        if (detail.quotationBuyerId != null) {
          try {
            _selectedBuyer = buyers.firstWhere(
              (b) => b.id == detail.quotationBuyerId,
              orElse: () => buyers.first,
            );
          } catch (_) {}
        }

        // Populate Sub-Items
        if (detail.subs.isNotEmpty) {
          for (var sub in detail.subs) {
            final row = _QuotationItemRowState();
            row.subId = sub.id;
            try {
              row.selectedItem = items.firstWhere(
                (it) => it.id == sub.quotationSubItemId,
                orElse: () => ActiveItem(
                  id: sub.quotationSubItemId,
                  itemName: 'Item #${sub.quotationSubItemId}',
                  itemPrice: sub.quotationSubRate.toString(),
                  itemStatus: 'Active',
                ),
              );
            } catch (_) {}

            row.sizeController.text = sub.quotationSubSize ?? '';
            row.unitController.text = sub.quotationSubUnit ?? '';
            row.qtyController.text = sub.quotationSubQnty.toString();
            row.rateController.text = sub.quotationSubRate.toString();
            row.discountController.text = sub.quotationSubDiscount.toString();
            row.taxController.text = sub.quotationSubTax.toString();
            row.amount = sub.quotationSubAmount.toDouble();

            _setupRowListeners(row);
            _itemRows.add(row);
          }
        } else {
          _addNewItemRow();
        }
      } else {
        // Create Mode: Fetch Next Reference, Active Buyers, and Active Items
        final results = await Future.wait([
          _quotationRepository.getQuotationRef(),
          _quotationRepository.getActiveBuyers(),
          _quotationRepository.getActiveItems(),
        ]);

        if (!mounted) return;

        final ref = results[0] as String;
        final buyers = results[1] as List<ActiveBuyer>;
        final items = results[2] as List<ActiveItem>;

        _refController.text = ref;
        _buyers = buyers;
        _items = items;
        _addNewItemRow();
      }

      setState(() {
        _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isInitialLoading = false;
      });
    }
  }

  void _setupRowListeners(_QuotationItemRowState row) {
    row.qtyController.addListener(() {
      setState(() {
        row.recalculate();
      });
    });
    row.rateController.addListener(() {
      setState(() {
        row.recalculate();
      });
    });
    row.discountController.addListener(() {
      setState(() {
        row.recalculate();
      });
    });
    row.taxController.addListener(() {
      setState(() {
        row.recalculate();
      });
    });
  }

  void _addNewItemRow() {
    final row = _QuotationItemRowState();
    _setupRowListeners(row);
    _itemRows.add(row);
  }

  void _removeItemRow(int index) {
    if (_itemRows.length > 1) {
      setState(() {
        final removed = _itemRows.removeAt(index);
        removed.dispose();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one item row is required.')),
      );
    }
  }

  void _onItemSelected(_QuotationItemRowState row, ActiveItem? item) {
    setState(() {
      row.selectedItem = item;
      if (item != null) {
        row.sizeController.text = item.itemSize ?? '';
        row.unitController.text = item.itemUnit ?? '';
        row.rateController.text = item.itemPrice;
        row.recalculate();
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isValidUntil) async {
    final initial = isValidUntil ? (_selectedValidUntil ?? DateTime.now().add(const Duration(days: 7))) : _selectedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        if (isValidUntil) {
          _selectedValidUntil = picked;
          _validUntilController.text = _displayFormat.format(picked);
        } else {
          _selectedDate = picked;
          _dateController.text = _displayFormat.format(picked);
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBuyer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a buyer.')),
      );
      return;
    }

    if (_selectedValidUntil == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid until date.')),
      );
      return;
    }

    for (int i = 0; i < _itemRows.length; i++) {
      if (_itemRows[i].selectedItem == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an item in row ${i + 1}.')),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final subs = _itemRows.map((row) {
        return QuotationSubItem(
          id: row.subId,
          quotationSubItemId: row.selectedItem!.id,
          quotationSubSize: row.sizeController.text.trim(),
          quotationSubUnit: row.unitController.text.trim(),
          quotationSubQnty: num.tryParse(row.qtyController.text.trim()) ?? 1,
          quotationSubRate: num.tryParse(row.rateController.text.trim()) ?? 0,
          quotationSubDiscount: num.tryParse(row.discountController.text.trim()) ?? 0,
          quotationSubTax: num.tryParse(row.taxController.text.trim()) ?? 0,
          quotationSubAmount: row.amount,
        );
      }).toList();

      if (isEditMode) {
        await _quotationRepository.updateQuotation(
          id: widget.quotationId!,
          quotationDate: _apiFormat.format(_selectedDate),
          quotationBuyerId: _selectedBuyer!.id,
          quotationValidDate: _apiFormat.format(_selectedValidUntil!),
          quotationRemarks: _remarksController.text.trim(),
          quotationStatus: _selectedStatus,
          subs: subs,
        );
      } else {
        await _quotationRepository.createQuotation(
          quotationRef: _refController.text.trim(),
          quotationDate: _apiFormat.format(_selectedDate),
          quotationBuyerId: _selectedBuyer!.id,
          quotationValidDate: _apiFormat.format(_selectedValidUntil!),
          quotationRemarks: _remarksController.text.trim(),
          subs: subs,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(isEditMode ? 'Quotation updated successfully!' : 'Quotation created successfully!'),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context, true);
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
    final title = isEditMode
        ? 'Edit Quotation #${_refController.text.isNotEmpty ? _refController.text : (widget.quotationRef ?? '')}'
        : 'Create Quotation';

    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    isEditMode ? 'Update Quotation' : 'Create Quotation',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                      const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
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

              // Card 1: Header Details
              _buildQuotationHeaderCard(),
              const SizedBox(height: 20),

              // Card 2: Items Table Card
              _buildItemsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotationHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 750;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: Quotation Ref, Date, Buyer, [Status if edit], Valid Until
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRefField()),
                    const SizedBox(width: 14),
                    Expanded(child: _buildDateField()),
                    const SizedBox(width: 14),
                    Expanded(child: _buildBuyerField()),
                    if (isEditMode) ...[
                      const SizedBox(width: 14),
                      Expanded(child: _buildStatusField()),
                    ],
                    const SizedBox(width: 14),
                    Expanded(child: _buildValidUntilField()),
                  ],
                )
              else ...[
                _buildRefField(),
                const SizedBox(height: 14),
                _buildDateField(),
                const SizedBox(height: 14),
                _buildBuyerField(),
                if (isEditMode) ...[
                  const SizedBox(height: 14),
                  _buildStatusField(),
                ],
                const SizedBox(height: 14),
                _buildValidUntilField(),
              ],
              const SizedBox(height: 18),

              // Row 2: Remarks
              _buildFieldLabel('Remarks', isRequired: false),
              TextFormField(
                controller: _remarksController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Enter remarks',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRefField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Quotation Ref', isRequired: false),
        TextFormField(
          controller: _refController,
          enabled: !isEditMode, // Disabled / read-only in edit mode matching screenshot
          decoration: const InputDecoration(
            hintText: 'QT-DO-25-26-X',
          ),
          validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Date', isRequired: true),
        InkWell(
          onTap: () => _selectDate(context, false),
          child: IgnorePointer(
            child: TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                hintText: 'dd / mm / yyyy',
                suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBuyerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Buyer', isRequired: true),
        DropdownButtonFormField<ActiveBuyer>(
          initialValue: _selectedBuyer,
          hint: const Text('Select Buyer', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          isExpanded: true,
          items: _buyers.map((buyer) {
            final isSelected = _selectedBuyer?.id == buyer.id;
            return DropdownMenuItem<ActiveBuyer>(
              value: buyer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    buyer.buyerName,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  ),
                  if (isSelected)
                    const Icon(Icons.check, size: 16, color: AppColors.primary),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedBuyer = val;
            });
          },
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Status', isRequired: false),
        DropdownButtonFormField<String>(
          initialValue: _selectedStatus,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
            DropdownMenuItem(value: 'Accepted', child: Text('Accepted')),
            DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
            DropdownMenuItem(value: 'Expired', child: Text('Expired')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedStatus = val;
              });
            }
          },
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildValidUntilField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Valid Until', isRequired: true),
        InkWell(
          onTap: () => _selectDate(context, true),
          child: IgnorePointer(
            child: TextFormField(
              controller: _validUntilController,
              decoration: const InputDecoration(
                hintText: 'dd / mm / yyyy',
                suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Items Table / Rows
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 960),
              child: Column(
                children: [
                  // Table Column Headers
                  Row(
                    children: const [
                      SizedBox(
                        width: 200,
                        child: Text('Item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: 90,
                        child: Text('Size', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: 90,
                        child: Text('Unit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: 80,
                        child: Text('Qty', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: Text('Rate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: 90,
                        child: Text('Discount %', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: 90,
                        child: Text('Tax %', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: Text('Amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: 44,
                        child: Text('Action', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // List of Rows
                  ...List.generate(_itemRows.length, (index) {
                    final row = _itemRows[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. Item Dropdown
                          SizedBox(
                            width: 200,
                            child: DropdownButtonFormField<ActiveItem>(
                              initialValue: row.selectedItem,
                              hint: const Text(
                                'Select Item',
                                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                              ),
                              isExpanded: true,
                              items: _items.map((it) {
                                final isSelected = row.selectedItem?.id == it.id;
                                return DropdownMenuItem<ActiveItem>(
                                  value: it,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        it.itemName,
                                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check, size: 14, color: AppColors.primary),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (item) => _onItemSelected(row, item),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 2. Size
                          SizedBox(
                            width: 90,
                            child: TextFormField(
                              controller: row.sizeController,
                              decoration: const InputDecoration(
                                hintText: 'Size',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 3. Unit
                          SizedBox(
                            width: 90,
                            child: TextFormField(
                              controller: row.unitController,
                              decoration: const InputDecoration(
                                hintText: 'Unit',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 4. Qty
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: row.qtyController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                hintText: 'Qty',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 5. Rate
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              controller: row.rateController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                hintText: 'Rate',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 6. Discount %
                          SizedBox(
                            width: 90,
                            child: TextFormField(
                              controller: row.discountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 7. Tax %
                          SizedBox(
                            width: 90,
                            child: TextFormField(
                              controller: row.taxController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 8. Amount (Read-only)
                          Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              row.amount.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 9. Remove Row Action (Red trash icon)
                          SizedBox(
                            width: 44,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Color(0xFFEF4444),
                                size: 20,
                              ),
                              tooltip: 'Remove Row',
                              onPressed: () => _removeItemRow(index),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // + Add Item Button (Black badge button)
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _addNewItemRow();
              });
            },
            icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.white),
            label: const Text(
              'Add Item',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
