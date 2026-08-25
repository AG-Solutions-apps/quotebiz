import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/app_colors.dart';
import '../models/quotation_model.dart';
import '../models/settings_model.dart';
import '../repositories/quotation_repository.dart';

enum HeaderDisplayMode {
  branchNameOnly,
  logoOnly,
  logoAndName,
}

class QuotationPreviewScreen extends StatefulWidget {
  final int quotationId;

  const QuotationPreviewScreen({
    super.key,
    required this.quotationId,
  });

  @override
  State<QuotationPreviewScreen> createState() => _QuotationPreviewScreenState();
}

class _QuotationPreviewScreenState extends State<QuotationPreviewScreen> {
  final QuotationRepository _quotationRepository = QuotationRepository();
  final TransformationController _transformController = TransformationController();

  QuotationPreviewData? _previewData;
  bool _isLoading = true;
  String? _errorMessage;

  HeaderDisplayMode _selectedHeaderMode = HeaderDisplayMode.branchNameOnly;
  double _currentZoom = 1.0;
  bool _hasInitialScaleSet = false;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Future<void> _loadPreview() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _quotationRepository.getQuotationPreview(widget.quotationId);
      if (!mounted) return;
      setState(() {
        _previewData = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _setZoom(double zoom) {
    setState(() {
      _currentZoom = zoom.clamp(0.25, 3.0);
      _transformController.value = Matrix4.diagonal3Values(_currentZoom, _currentZoom, 1.0);
    });
  }

  void _zoomIn() {
    _setZoom(_currentZoom + 0.15);
  }

  void _zoomOut() {
    _setZoom(_currentZoom - 0.15);
  }

  void _resetZoom() {
    _setZoom(1.0);
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

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₹0.00';
    final numVal = double.tryParse('$amount') ?? 0.0;
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return '₹${formatter.format(numVal)}';
  }

  Future<Uint8List?> _fetchImageBytes(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _downloadOrPrintPdf() async {
    if (_previewData == null) return;

    final doc = pw.Document();
    final data = _previewData!.data;
    final branch = _previewData!.branch;

    // Fetch dynamic logo & signature bytes for PDF
    final logoUrl = ApiConstants.getBranchImageUrl(branch?.branchLogo);
    final signUrl = ApiConstants.getBranchImageUrl(branch?.branchSign);

    final Uint8List? logoBytes = await _fetchImageBytes(logoUrl);
    final Uint8List? signBytes = await _fetchImageBytes(signUrl);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPdfHeaderLeft(branch, logoBytes),
                  pw.Text(
                    'Quotation',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 28),

              // 2. Meta Info Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('To,', style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        data.buyerName ?? 'Customer',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(text: 'Quotation: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                            pw.TextSpan(text: data.quotationRef, style: const pw.TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(text: 'Date: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                            pw.TextSpan(text: _formatDate(data.quotationDate), style: const pw.TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(text: 'Valid Until: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                            pw.TextSpan(text: _formatDate(data.quotationValidDate), style: const pw.TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // 3. Salutation
              pw.Text('Dear Sir/Mam,', style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 4),
              pw.Text(
                'Thank you for your valuable inquiry. We are pleased to quote as below:',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 16),

              // 4. Items Table
              pw.Table(
                columnWidths: const {
                  0: pw.FlexColumnWidth(0.8),
                  1: pw.FlexColumnWidth(4.2),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                  4: pw.FlexColumnWidth(2.5),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.grey900, width: 1.5),
                        bottom: pw.BorderSide(color: PdfColors.grey900, width: 1.5),
                      ),
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text('SL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text('DESCRIPTION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text('QTY', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text('PRICE', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text('TOTAL', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                    ],
                  ),
                  // Table Rows
                  ...List.generate(data.subs.length, (index) {
                    final sub = data.subs[index];
                    final sl = index + 1;
                    final desc = sub.itemName ?? 'Item';
                    final qtyUnit = '${sub.quotationSubQnty} ${sub.quotationSubUnit ?? ''}'.trim();
                    final price = '₹${sub.quotationSubRate}';
                    final total = '₹${sub.quotationSubAmount}';

                    return pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Text('$sl', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Text(desc, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Text(qtyUnit, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Text(price, textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Text(total, textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 14),

              // 5. Grand Total Row
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 260,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(color: PdfColors.grey900, width: 2)),
                  ),
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'GRAND TOTAL',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                      ),
                      pw.Text(
                        '₹${data.totalAmount}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 24),

              // 6. Remarks
              if (data.quotationRemarks != null && data.quotationRemarks!.isNotEmpty) ...[
                pw.Text(
                  data.quotationRemarks!,
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 20),
              ],

              // 7. Terms & Conditions
              pw.Text(
                'Terms & Conditions:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
              ),
              pw.SizedBox(height: 6),
              _buildPdfTerms(branch?.branchTC),

              pw.Spacer(),

              // 8. Authorized Signature Footer
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'For, ${branch?.branchName ?? 'Company'}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                    ),
                    pw.SizedBox(height: 8),
                    if (signBytes != null)
                      pw.Container(
                        height: 45,
                        width: 120,
                        alignment: pw.Alignment.centerRight,
                        child: pw.Image(pw.MemoryImage(signBytes), fit: pw.BoxFit.contain),
                      )
                    else if (branch?.branchSignName != null && branch!.branchSignName!.isNotEmpty) ...[
                      pw.SizedBox(height: 16),
                      pw.Text(
                        branch.branchSignName!,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                      ),
                    ] else
                      pw.SizedBox(height: 28),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'AUTHORIZED SIGNATURE',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: '${data.quotationRef}.pdf',
    );
  }

  pw.Widget _buildPdfHeaderLeft(BranchSettings? branch, Uint8List? logoBytes) {
    final branchName = branch?.branchName ?? 'QuoteBiz';

    switch (_selectedHeaderMode) {
      case HeaderDisplayMode.branchNameOnly:
        return pw.Text(
          branchName,
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
          ),
        );
      case HeaderDisplayMode.logoOnly:
        if (logoBytes != null) {
          return pw.Container(
            width: 60,
            height: 60,
            child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
          );
        }
        return pw.Text(
          branchName,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        );
      case HeaderDisplayMode.logoAndName:
        return pw.Row(
          children: [
            if (logoBytes != null) ...[
              pw.Container(
                width: 45,
                height: 45,
                child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(width: 12),
            ],
            pw.Text(
              branchName,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        );
    }
  }

  pw.Widget _buildPdfTerms(String? customTC) {
    if (customTC != null && customTC.trim().isNotEmpty) {
      return pw.Text(customTC, style: const pw.TextStyle(fontSize: 9));
    }

    final defaultTerms = [
      '1) Warranty: Against colour Fading, delamination and manufacturing defects',
      '2) Delivery : 5-7 days after advance payment',
      '3) Payment Terms : 50% advance and balance on delivery',
      '4) Transport : extra chargeable',
      '5) Installation charges not include',
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: defaultTerms.map((t) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Text(t, style: const pw.TextStyle(fontSize: 9)),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Automatically initialize best fit zoom on first render for mobile viewports
    if (!_hasInitialScaleSet && _previewData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final screenWidth = MediaQuery.of(context).size.width;
        final initialScale = (screenWidth / 830).clamp(0.45, 1.0);
        setState(() {
          _currentZoom = initialScale;
          _transformController.value = Matrix4.diagonal3Values(_currentZoom, _currentZoom, 1.0);
          _hasInitialScaleSet = true;
        });
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      appBar: AppBar(
        title: Text(
          _previewData != null ? 'Quotation #${_previewData!.data.quotationRef}' : 'Quotation Preview',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _previewData != null ? _downloadOrPrintPdf : null,
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('Download / Print PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 48),
                      const SizedBox(height: 12),
                      Text(_errorMessage!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadPreview, child: const Text('Retry')),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // 1. Top Header Selector Bar (Horizontally scrollable with zero overflow)
                    _buildHeaderSelectorCard(),

                    // 2. Interactive Unconstrained A4 Sheet Canvas
                    Expanded(
                      child: Stack(
                        children: [
                          InteractiveViewer(
                            transformationController: _transformController,
                            constrained: false, // Prevents parent screen width from squishing A4 paper
                            minScale: 0.25,
                            maxScale: 3.0,
                            boundaryMargin: const EdgeInsets.all(100),
                            panEnabled: true,
                            scaleEnabled: true,
                            onInteractionUpdate: (_) {
                              // Sync current zoom percentage badge
                              final scale = _transformController.value.getMaxScaleOnAxis();
                              if ((scale - _currentZoom).abs() > 0.02) {
                                setState(() {
                                  _currentZoom = scale;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: _buildA4QuotationPaper(),
                            ),
                          ),

                          // Floating Zoom Controls (Bottom Right)
                          Positioned(
                            bottom: 24,
                            right: 24,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_rounded, size: 20),
                                    tooltip: 'Zoom Out',
                                    onPressed: _zoomOut,
                                  ),
                                  InkWell(
                                    onTap: _resetZoom,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        '${(_currentZoom * 100).toInt()}%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_rounded, size: 20),
                                    tooltip: 'Zoom In',
                                    onPressed: _zoomIn,
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.restart_alt_rounded, size: 20),
                                    tooltip: 'Reset Zoom (100%)',
                                    onPressed: _resetZoom,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildHeaderSelectorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            const Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Header Style:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 14),
            _buildRadioOption('Only Branch Name', HeaderDisplayMode.branchNameOnly),
            const SizedBox(width: 10),
            _buildRadioOption('Only Logo', HeaderDisplayMode.logoOnly),
            const SizedBox(width: 10),
            _buildRadioOption('Logo & Branch Name', HeaderDisplayMode.logoAndName),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String label, HeaderDisplayMode mode) {
    final isSelected = _selectedHeaderMode == mode;

    return InkWell(
      onTap: () => setState(() => _selectedHeaderMode = mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// True A4 Ratio Paper (794px width with exact typography and alignments)
  Widget _buildA4QuotationPaper() {
    final data = _previewData!.data;
    final branch = _previewData!.branch;

    return Container(
      width: 794,
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 56),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header Top Row (Selected Brand Header + "Quotation" title)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPreviewHeaderLeft(branch),
              const Text(
                'Quotation',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // 2. Meta Info (To Customer & Quotation Ref / Dates)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'To,',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.buyerName ?? 'Customer',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Quotation: ',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      children: [
                        TextSpan(
                          text: data.quotationRef,
                          style: const TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: 'Date: ',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      children: [
                        TextSpan(
                          text: _formatDate(data.quotationDate),
                          style: const TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: 'Valid Until: ',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      children: [
                        TextSpan(
                          text: _formatDate(data.quotationValidDate),
                          style: const TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 3. Salutation Text
          const Text(
            'Dear Sir/Mam,',
            style: TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Thank you for your valuable inquiry. We are pleased to quote as below:',
            style: TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 24),

          // 4. Items Table
          _buildItemsTable(data.subs),
          const SizedBox(height: 16),

          // 5. Grand Total Row (With solid top border)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 320,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF0F172A), width: 2)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GRAND TOTAL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    _formatCurrency(data.totalAmount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 6. Remarks
          if (data.quotationRemarks != null && data.quotationRemarks!.isNotEmpty) ...[
            Text(
              data.quotationRemarks!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 28),
          ],

          // 7. Terms & Conditions
          const Text(
            'Terms & Conditions:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          _buildTermsAndConditions(branch?.branchTC),

          const SizedBox(height: 48),

          // 8. Authorized Signature Section (Bottom Right)
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'For, ${branch?.branchName ?? 'Company'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSignatureWidget(branch),
                const SizedBox(height: 8),
                const Text(
                  'AUTHORIZED SIGNATURE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewHeaderLeft(BranchSettings? branch) {
    final branchName = branch?.branchName ?? 'Demo';
    final logoUrl = ApiConstants.getBranchImageUrl(branch?.branchLogo);

    switch (_selectedHeaderMode) {
      case HeaderDisplayMode.branchNameOnly:
        return Text(
          branchName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        );
      case HeaderDisplayMode.logoOnly:
        return _buildLogoImage(logoUrl, 64, 64);
      case HeaderDisplayMode.logoAndName:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogoImage(logoUrl, 50, 50),
            const SizedBox(width: 14),
            Text(
              branchName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildLogoImage(String logoUrl, double width, double height) {
    if (logoUrl.isNotEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            logoUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.apartment_rounded, color: AppColors.primary, size: 28),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: const Center(
        child: Icon(Icons.apartment_rounded, color: AppColors.primary, size: 28),
      ),
    );
  }

  Widget _buildSignatureWidget(BranchSettings? branch) {
    final signUrl = ApiConstants.getBranchImageUrl(branch?.branchSign);

    if (signUrl.isNotEmpty) {
      return Container(
        height: 52,
        constraints: const BoxConstraints(maxWidth: 160),
        child: Image.network(
          signUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            if (branch?.branchSignName != null && branch!.branchSignName!.isNotEmpty) {
              return Text(
                branch.branchSignName!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              );
            }
            return const Icon(Icons.draw_rounded, size: 24, color: AppColors.primary);
          },
        ),
      );
    }

    if (branch?.branchSignName != null && branch!.branchSignName!.isNotEmpty) {
      return Text(
        branch.branchSignName!,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
      );
    }

    return const SizedBox(height: 28);
  }

  Widget _buildItemsTable(List<QuotationSubItem> subs) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF0F172A), width: 1.5),
                bottom: BorderSide(color: Color(0xFF0F172A), width: 1.5),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text('SL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ),
                Expanded(
                  flex: 5,
                  child: Text('DESCRIPTION', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ),
                Expanded(
                  flex: 2,
                  child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ),
                Expanded(
                  flex: 2,
                  child: Text('PRICE', textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ),
                Expanded(
                  flex: 2,
                  child: Text('TOTAL', textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ),
              ],
            ),
          ),

          // Table Rows
          ...List.generate(subs.length, (index) {
            final sub = subs[index];
            final sl = index + 1;
            final desc = sub.itemName ?? 'Item';
            final qtyUnit = '${sub.quotationSubQnty} ${sub.quotationSubUnit ?? ''}'.trim();

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text('$sl', style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      desc,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      qtyUnit,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatCurrency(sub.quotationSubRate),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatCurrency(sub.quotationSubAmount),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions(String? customTC) {
    if (customTC != null && customTC.trim().isNotEmpty) {
      return Text(
        customTC,
        style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.5),
      );
    }

    final defaultTerms = [
      '1) Warranty: Against colour Fading, delamination and manufacturing defects',
      '2) Delivery : 5-7 days after advance payment',
      '3) Payment Terms : 50% advance and balance on delivery',
      '4) Transport : extra chargeable',
      '5) Installation charges not include',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: defaultTerms.map((term) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            term,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.4),
          ),
        );
      }).toList(),
    );
  }
}
