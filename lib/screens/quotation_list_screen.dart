import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_exceptions.dart';
import '../core/services/session_manager.dart';
import '../models/quotation_model.dart';
import '../repositories/quotation_repository.dart';
import 'create_quotation_screen.dart';
import 'login_screen.dart';
import 'quotation_preview_screen.dart';

class QuotationListScreen extends StatefulWidget {
  final bool isEmbedded;

  const QuotationListScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<QuotationListScreen> createState() => _QuotationListScreenState();
}

class _QuotationListScreenState extends State<QuotationListScreen> {
  final QuotationRepository _quotationRepository = QuotationRepository();
  final TextEditingController _searchController = TextEditingController();

  List<QuotationListItem> _quotations = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  List<QuotationListItem> get _filteredQuotations {
    if (_searchQuery.trim().isEmpty) return _quotations;
    final q = _searchQuery.trim().toLowerCase();
    return _quotations.where((item) {
      final ref = item.quotationRef.toLowerCase();
      final buyer = (item.buyerName ?? '').toLowerCase();
      final date = (item.quotationDate ?? '').toLowerCase();
      final status = item.quotationStatus.toLowerCase();
      final amount = item.totalAmount.toLowerCase();
      return ref.contains(q) ||
          buyer.contains(q) ||
          date.contains(q) ||
          status.contains(q) ||
          amount.contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadQuotations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _quotationRepository.getQuotations();

      if (!mounted) return;
      setState(() {
        _quotations = result;
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

  void _navigateToCreateQuotation() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateQuotationScreen()),
    );

    if (result == true) {
      _loadQuotations();
    }
  }

  void _navigateToEditQuotation(QuotationListItem item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateQuotationScreen(
          quotationId: item.id,
          quotationRef: item.quotationRef,
        ),
      ),
    );

    if (result == true) {
      _loadQuotations();
    }
  }

  void _navigateToPreview(QuotationListItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuotationPreviewScreen(quotationId: item.id),
      ),
    );
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  String _formatCurrency(String rawAmount) {
    final numVal = double.tryParse(rawAmount) ?? 0.0;
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return '₹${formatter.format(numVal)}';
  }

  Color _getStatusBgColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('accepted') || lower.contains('approved')) {
      return AppColors.successBg;
    } else if (lower.contains('pending')) {
      return AppColors.warningBg;
    } else if (lower.contains('rejected')) {
      return AppColors.dangerBg;
    }
    return AppColors.surfaceMuted;
  }

  Color _getStatusTextColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('accepted') || lower.contains('approved')) {
      return const Color(0xFF047857);
    } else if (lower.contains('pending')) {
      return const Color(0xFFB45309);
    } else if (lower.contains('rejected')) {
      return const Color(0xFFB91C1C);
    }
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = RefreshIndicator(
      onRefresh: _loadQuotations,
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
                  // Title and Quick Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quotations',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Manage and generate client estimates',
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
                          '${_filteredQuotations.length} Total',
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

                  // Search Bar + Create Quotation Button
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
                              hintText: 'Search quotation ref, buyer, amount...',
                              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.blue),
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
                        onTap: _navigateToCreateQuotation,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blue.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_circle_outline_rounded, size: 18, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Create',
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
                        onPressed: _loadQuotations,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_filteredQuotations.isEmpty)
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
                      child: const Icon(Icons.receipt_long_outlined, size: 32, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'No quotations found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _searchQuery.isNotEmpty ? 'Try searching another keyword' : 'Tap Create to draft your first quotation',
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
                    final item = _filteredQuotations[index];
                    return _buildQuotationCard(item);
                  },
                  childCount: _filteredQuotations.length,
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
        title: const Text('Quotations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadQuotations,
          ),
        ],
      ),
      body: bodyContent,
    );
  }

  Widget _buildQuotationCard(QuotationListItem item) {
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
            // Top Row: Ref Badge and Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tag_rounded, size: 14, color: AppColors.blue),
                      const SizedBox(width: 4),
                      Text(
                        item.quotationRef,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusBgColor(item.quotationStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.quotationStatus,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _getStatusTextColor(item.quotationStatus),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle: Client Name & Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Client',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.business_outlined, size: 16, color: AppColors.navy),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.buyerName ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(item.totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),

            // Bottom Row: Dates & Actions (View PDF, Edit)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Dates (Protected against overflow with Expanded and Flexible)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        _formatDate(item.quotationDate),
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                      if (item.quotationValidDate != null && item.quotationValidDate!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Text('•', style: TextStyle(color: AppColors.textMuted)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Valid: ${_formatDate(item.quotationValidDate)}',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _navigateToPreview(item),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.blueLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.picture_as_pdf_outlined, color: AppColors.blue, size: 15),
                            SizedBox(width: 4),
                            Text(
                              'PDF',
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
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _navigateToEditQuotation(item),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.navy,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
