import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SwipeToLoginButton extends StatefulWidget {
  final Future<void> Function() onSwipeComplete;
  final bool isLoading;
  final String text;

  const SwipeToLoginButton({
    super.key,
    required this.onSwipeComplete,
    this.isLoading = false,
    this.text = 'Slide to Sign In',
  });

  @override
  State<SwipeToLoginButton> createState() => _SwipeToLoginButtonState();
}

class _SwipeToLoginButtonState extends State<SwipeToLoginButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  late AnimationController _animationController;
  Animation<double>? _slideAnimation;
  double _maxDrag = 0.0;
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerComplete() {
    if (_hasTriggered || widget.isLoading) return;
    _hasTriggered = true;

    // Animate to end smoothly
    _slideAnimation = Tween<double>(
      begin: _dragPosition,
      end: _maxDrag,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ))..addListener(() {
        setState(() {
          _dragPosition = _slideAnimation!.value;
        });
      });

    _animationController.forward(from: 0.0).then((_) {
      widget.onSwipeComplete();
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (widget.isLoading || _hasTriggered) return;
    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, _maxDrag);
    });

    // If dragged at least 40% across, auto trigger complete
    if (_maxDrag > 0 && _dragPosition >= _maxDrag * 0.40) {
      _triggerComplete();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (widget.isLoading || _hasTriggered) return;

    if (_maxDrag > 0 && (_dragPosition >= _maxDrag * 0.35 || (details.primaryVelocity ?? 0) > 200)) {
      _triggerComplete();
    } else {
      // Snap back to 0
      _slideAnimation = Tween<double>(
        begin: _dragPosition,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ))..addListener(() {
          setState(() {
            _dragPosition = _slideAnimation!.value;
          });
        });

      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 48.0;
    const double thumbSize = 38.0;
    const double padding = 5.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        _maxDrag = (constraints.maxWidth - thumbSize - (padding * 2)).clamp(0.0, double.infinity);

        // Reset if loading finishes
        if (!widget.isLoading && _hasTriggered) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !widget.isLoading) {
              setState(() {
                _hasTriggered = false;
                _dragPosition = 0.0;
              });
            }
          });
        }

        final progress = _maxDrag > 0 ? (_dragPosition / _maxDrag).clamp(0.0, 1.0) : 0.0;

        return GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onTap: _triggerComplete, // Direct tap triggers login
          child: Container(
            height: buttonHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4F46E5), // Royal Indigo
                  Color(0xFF6366F1), // Bright Indigo
                  Color(0xFF818CF8), // Soft Periwinkle
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: widget.isLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Active filled highlight trail
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: (_dragPosition + thumbSize + padding * 2).clamp(0.0, constraints.maxWidth),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.cyan.withValues(alpha: 0.35),
                                AppColors.blue.withValues(alpha: 0.45),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),

                      // Centered Text & Arrows
                      Center(
                        child: Opacity(
                          opacity: (1.0 - (progress * 1.5)).clamp(0.0, 1.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.text,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.double_arrow_rounded,
                                size: 16,
                                color: AppColors.cyan,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Draggable Thumb
                      Positioned(
                        left: padding + _dragPosition,
                        child: Container(
                          width: thumbSize,
                          height: thumbSize,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.white,
                                Color(0xFFF1F5F9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            progress >= 0.5
                                ? Icons.lock_open_rounded
                                : Icons.arrow_forward_rounded,
                            color: const Color(0xFF4F46E5),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
