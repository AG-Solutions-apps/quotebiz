import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_exceptions.dart';
import '../core/services/session_manager.dart';
import '../models/item_model.dart';
import '../repositories/item_repository.dart';
import '../widgets/item_form_dialog.dart';
import 'login_screen.dart';

class ItemListScreen extends StatefulWidget {
  final bool isEmbedded;

  const ItemListScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final ItemRepository _itemRepository = ItemRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Item> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  List<Item> get _filteredItems {
    if (_searchQuery.trim().isEmpty) return _items;
    final q = _searchQuery.trim().toLowerCase();
    return _items.where((item) {
      final name = item.itemName.toLowerCase();
      final type = (item.itemType ?? '').toLowerCase();
      final unit = (item.itemUnit ?? '').toLowerCase();
      final size = (item.itemSize ?? '').toLowerCase();
      final desc = (item.itemDescription ?? '').toLowerCase();
      return name.contains(q) ||
          type.contains(q) ||
          unit.contains(q) ||
          size.contains(q) ||
          desc.contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _itemRepository.getItems();

      if (!mounted) return;
      setState(() {
        _items = result;
        _isLoading = false;
      });
    } on UnauthorizedException {
      if (!mounted) return;
      await SessionManager.clearSession();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _showAddItemDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const ItemFormDialog(),
    );

    if (result == true) {
      _loadItems();
    }
  }

  void _showEditItemDialog(Item item) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ItemFormDialog(item: item),
    );

    if (result == true) {
      _loadItems();
    }
  }

  String _formatPrice(String rawPrice) {
    final numVal = double.tryParse(rawPrice) ?? 0.0;
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return '₹${formatter.format(numVal)}';
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = RefreshIndicator(
      onRefresh: _loadItems,
      color: AppColors.blue,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Total Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Items',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Manage inventory, rates & units',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.blueLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '${_filteredItems.length} Items',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search + Add Item Action
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search items, types, units...',
                              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.cyanDark),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: _showAddItemDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: AppColors.cyanGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyan.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_shopping_cart_rounded, size: 18, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Content List
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                ),
              ),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, color: AppColors.danger, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadItems,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_filteredItems.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.inventory_2_outlined, size: 32, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'No items found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _searchQuery.isNotEmpty ? 'Try a different search term' : 'Tap Add to create your first item',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _filteredItems[index];
                    return _buildItemCard(item);
                  },
                  childCount: _filteredItems.length,
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadItems,
          ),
        ],
      ),
      body: bodyContent,
    );
  }

  Widget _buildItemCard(Item item) {
    final isActive = item.itemStatus.toLowerCase() == 'active';
    final initial = (item.itemName.isNotEmpty ? item.itemName[0] : 'I').toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar Initial, Name, Price, and Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.cyanGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (item.itemType != null && item.itemType!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.itemType!,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                // Right Column: Status Pill + Edit Button below it
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.successBg : AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? AppColors.success : AppColors.danger,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.itemStatus,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isActive ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Edit Button directly below Status Pill
                    InkWell(
                      onTap: () => _showEditItemDialog(item),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.blueLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_outlined, size: 13, color: AppColors.blue),
                            SizedBox(width: 4),
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),

            // Metrics & Tags: Price / Unit, Size, Tax
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price Tag
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Unit Price', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        text: _formatPrice(item.itemPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                        children: [
                          if (item.itemUnit != null && item.itemUnit!.isNotEmpty)
                            TextSpan(
                              text: ' / ${item.itemUnit}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Size & Tax Badges
                Row(
                  children: [
                    if (item.itemSize != null && item.itemSize!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Size: ${item.itemSize}',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.navy),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blueLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Tax: ${item.itemTax}%',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (item.itemDescription != null && item.itemDescription!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                item.itemDescription!,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
