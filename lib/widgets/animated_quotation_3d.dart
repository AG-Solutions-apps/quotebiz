import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AnimatedQuotation3dCard extends StatefulWidget {
  final bool isCompact;

  const AnimatedQuotation3dCard({
    super.key,
    this.isCompact = false,
  });

  @override
  State<AnimatedQuotation3dCard> createState() => _AnimatedQuotation3dCardState();
}

class _AnimatedQuotation3dCardState extends State<AnimatedQuotation3dCard>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _shimmerController;

  // Typing state
  Timer? _typingTimer;
  int _currentStep = 0;
  String _typedRef = '';
  String _typedClient = '';
  String _typedItem1 = '';
  String _typedItem2 = '';
  String _typedTotal = '';
  bool _showApproved = false;
  bool _cursorVisible = true;
  Timer? _cursorTimer;

  final String _targetRef = 'QT-2026-904';
  final String _targetClient = 'Acme Global Corp';
  final String _targetItem1 = 'Enterprise CRM (10 Users)';
  final String _targetItem2 = 'Cloud Setup & Training';
  final String _targetTotal = '₹1,25,000.00';

  @override
  void initState() {
    super.initState();

    // 3D Floating animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Shimmer effect animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Blinking cursor
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 450), (timer) {
      if (mounted) {
        setState(() {
          _cursorVisible = !_cursorVisible;
        });
      }
    });

    _startTypingSequence();
  }

  void _startTypingSequence() {
    _currentStep = 0;
    _typedRef = '';
    _typedClient = '';
    _typedItem1 = '';
    _typedItem2 = '';
    _typedTotal = '';
    _showApproved = false;

    _typeNextChar();
  }

  void _typeNextChar() {
    if (!mounted) return;

    if (_currentStep == 0) {
      // Typing Quotation Ref
      if (_typedRef.length < _targetRef.length) {
        setState(() {
          _typedRef = _targetRef.substring(0, _typedRef.length + 1);
        });
        _typingTimer = Timer(const Duration(milliseconds: 55), _typeNextChar);
      } else {
        _currentStep = 1;
        _typingTimer = Timer(const Duration(milliseconds: 180), _typeNextChar);
      }
    } else if (_currentStep == 1) {
      // Typing Client
      if (_typedClient.length < _targetClient.length) {
        setState(() {
          _typedClient = _targetClient.substring(0, _typedClient.length + 1);
        });
        _typingTimer = Timer(const Duration(milliseconds: 40), _typeNextChar);
      } else {
        _currentStep = 2;
        _typingTimer = Timer(const Duration(milliseconds: 200), _typeNextChar);
      }
    } else if (_currentStep == 2) {
      // Typing Item 1
      if (_typedItem1.length < _targetItem1.length) {
        setState(() {
          _typedItem1 = _targetItem1.substring(0, _typedItem1.length + 1);
        });
        _typingTimer = Timer(const Duration(milliseconds: 35), _typeNextChar);
      } else {
        _currentStep = 3;
        _typingTimer = Timer(const Duration(milliseconds: 180), _typeNextChar);
      }
    } else if (_currentStep == 3) {
      // Typing Item 2
      if (_typedItem2.length < _targetItem2.length) {
        setState(() {
          _typedItem2 = _targetItem2.substring(0, _typedItem2.length + 1);
        });
        _typingTimer = Timer(const Duration(milliseconds: 35), _typeNextChar);
      } else {
        _currentStep = 4;
        _typingTimer = Timer(const Duration(milliseconds: 200), _typeNextChar);
      }
    } else if (_currentStep == 4) {
      // Typing Total
      if (_typedTotal.length < _targetTotal.length) {
        setState(() {
          _typedTotal = _targetTotal.substring(0, _typedTotal.length + 1);
        });
        _typingTimer = Timer(const Duration(milliseconds: 55), _typeNextChar);
      } else {
        _currentStep = 5;
        _typingTimer = Timer(const Duration(milliseconds: 350), () {
          if (mounted) {
            setState(() {
              _showApproved = true;
            });
            _typingTimer = Timer(const Duration(seconds: 3), _startTypingSequence);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _shimmerController.dispose();
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = widget.isCompact;

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = sin(_floatController.value * 2 * pi) * (isCompact ? 3.5 : 6.0);
        final rotateX = (isCompact ? -0.03 : -0.05) + sin(_floatController.value * 2 * pi) * 0.015;
        final rotateY = (isCompact ? 0.04 : 0.06) + cos(_floatController.value * 2 * pi) * 0.015;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..setTranslationRaw(0.0, floatOffset, 0.0)
            ..rotateX(rotateX)
            ..rotateY(rotateY),
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Glow Backdrop Effect
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isCompact ? 16 : 24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: isCompact ? 0.18 : 0.25),
                        blurRadius: isCompact ? 20 : 36,
                        spreadRadius: isCompact ? 1 : 4,
                      ),
                      BoxShadow(
                        color: AppColors.blue.withValues(alpha: isCompact ? 0.22 : 0.3),
                        blurRadius: isCompact ? 24 : 48,
                        spreadRadius: isCompact ? 2 : 8,
                      ),
                    ],
                  ),
                ),
              ),

              // Main 3D Quotation Sheet
              Container(
                width: isCompact ? double.infinity : 360,
                padding: EdgeInsets.all(isCompact ? 14 : 22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E293B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
                  border: Border.all(
                    color: AppColors.cyan.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: isCompact ? 16 : 28,
                      offset: Offset(0, isCompact ? 6 : 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Bar (Window control dots + LIVE BADGE)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildDot(const Color(0xFFEF4444), isCompact),
                            const SizedBox(width: 5),
                            _buildDot(const Color(0xFFF59E0B), isCompact),
                            const SizedBox(width: 5),
                            _buildDot(const Color(0xFF10B981), isCompact),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: isCompact ? 7 : 9, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.cyan.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: AppColors.cyan,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE ESTIMATE',
                                style: TextStyle(
                                  fontSize: isCompact ? 9 : 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.cyan,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isCompact ? 10 : 16),

                    // Quotation Header Line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'QUOTATION',
                          style: TextStyle(
                            fontSize: isCompact ? 13 : 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          _typedRef.isEmpty ? ' ' : '$_typedRef${_currentStep == 0 && _cursorVisible ? '▌' : ''}',
                          style: TextStyle(
                            fontSize: isCompact ? 11 : 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cyan,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    SizedBox(height: isCompact ? 8 : 12),

                    // Client Name
                    Row(
                      children: [
                        Icon(Icons.business_rounded, size: isCompact ? 12 : 14, color: AppColors.textMuted),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Client: $_typedClient${_currentStep == 1 && _cursorVisible ? '▌' : ''}',
                            style: TextStyle(
                              fontSize: isCompact ? 11.5 : 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE2E8F0),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isCompact ? 8 : 12),

                    // Item Lines (Live typed)
                    _buildItemLine(
                      '1',
                      '$_typedItem1${_currentStep == 2 && _cursorVisible ? '▌' : ''}',
                      _typedItem1.length == _targetItem1.length ? '₹95,000' : '...',
                      isCompact,
                    ),
                    const SizedBox(height: 5),
                    _buildItemLine(
                      '2',
                      '$_typedItem2${_currentStep == 3 && _cursorVisible ? '▌' : ''}',
                      _typedItem2.length == _targetItem2.length ? '₹30,000' : '...',
                      isCompact,
                    ),
                    SizedBox(height: isCompact ? 10 : 14),

                    // Grand Total Box
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14, vertical: isCompact ? 7 : 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.blue.withValues(alpha: 0.25),
                            AppColors.cyan.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.cyan.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GRAND TOTAL',
                            style: TextStyle(
                              fontSize: isCompact ? 9.5 : 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            _typedTotal.isEmpty ? '₹0.00' : '$_typedTotal${_currentStep == 4 && _cursorVisible ? '▌' : ''}',
                            style: TextStyle(
                              fontSize: isCompact ? 14 : 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.cyan,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Animated Approved Badge stamp
                    if (_showApproved) ...[
                      SizedBox(height: isCompact ? 8 : 12),
                      Center(
                        child: AnimatedScale(
                          scale: _showApproved ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.elasticOut,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14, vertical: isCompact ? 4 : 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF047857).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF10B981),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, color: const Color(0xFF10B981), size: isCompact ? 13 : 15),
                                const SizedBox(width: 5),
                                Text(
                                  'QUOTATION ACCEPTED ✓',
                                  style: TextStyle(
                                    fontSize: isCompact ? 10 : 11,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF34D399),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Floating Badge 1: ⚡ Instant PDF (Top Right)
              Positioned(
                top: isCompact ? -8 : -14,
                right: isCompact ? -6 : -16,
                child: _buildFloatingBadge(
                  icon: Icons.bolt_rounded,
                  label: 'Instant PDF',
                  color: AppColors.cyan,
                  isCompact: isCompact,
                ),
              ),

              // Floating Badge 2: 🛡️ Auto GST (Bottom Left)
              Positioned(
                bottom: isCompact ? -8 : -12,
                left: isCompact ? -6 : -16,
                child: _buildFloatingBadge(
                  icon: Icons.verified_rounded,
                  label: 'Auto GST',
                  color: AppColors.blue,
                  isCompact: isCompact,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDot(Color color, bool isCompact) {
    return Container(
      width: isCompact ? 7 : 9,
      height: isCompact ? 7 : 9,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildItemLine(String num, String text, String price, bool isCompact) {
    return Row(
      children: [
        Container(
          width: isCompact ? 15 : 18,
          height: isCompact ? 15 : 18,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(3),
          ),
          alignment: Alignment.center,
          child: Text(
            num,
            style: TextStyle(
              fontSize: isCompact ? 8.5 : 10,
              fontWeight: FontWeight.w700,
              color: AppColors.cyan,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text.isEmpty ? ' ' : text,
            style: TextStyle(
              fontSize: isCompact ? 10.5 : 11.5,
              color: const Color(0xFFCBD5E1),
              fontFamily: 'monospace',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          price,
          style: TextStyle(
            fontSize: isCompact ? 10.5 : 11.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingBadge({
    required IconData icon,
    required String label,
    required Color color,
    required bool isCompact,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 12, vertical: isCompact ? 4 : 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 11 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isCompact ? 9.5 : 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
