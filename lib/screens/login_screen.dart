import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/session_manager.dart';
import '../models/auth_model.dart';
import '../repositories/auth_repository.dart';
import '../widgets/quotation_isometric_illustration.dart';
import '../widgets/swipe_to_login_button.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;
  CompanyDetails? _companyDetails;
  final String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
  }

  Future<void> _loadCompanyInfo() async {
    final company = await SessionManager.getCompanyDetails();
    if (mounted) {
      setState(() {
        _companyDetails = company;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      await _authRepository.login(
        username: username,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyName = _companyDetails?.companyName ?? 'QuoteBiz';
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 880;

          if (isWide) {
            // ================= DESKTOP / TABLET 2-COLUMN VIEW =================
            return Stack(
              children: [
                _buildFullScreenPurpleBackground(),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1020),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                              blurRadius: 36,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Left Column: Brand Hero + Large 3D Quotation
                              Expanded(
                                flex: 5,
                                child: _buildDesktopLeftHero(companyName),
                              ),
                              // Right Column: White Form with Slider
                              Expanded(
                                flex: 5,
                                child: _buildDesktopRightForm(companyName),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // ================= MOBILE VIEW (KEYBOARD-AWARE & SINGLE-PAGE) =================
          return Stack(
            children: [
              // 1. Full Screen Ambient Purple/Lavender Background
              _buildFullScreenPurpleBackground(),

              // 2. Mobile Content: Keyboard-responsive (auto-shifts up when keyboard opens)
              SafeArea(
                bottom: true,
                child: isKeyboardOpen
                    ? SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Compact Brand Header during typing so all fields & slider remain above keyboard
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        companyName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const Text(
                                        'Smart Quotes. Better Business.',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _buildWhiteFormContainer(),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Hero Section: Expands dynamically with BIG 3D illustration
                          Expanded(
                            child: _buildMobileHeroSection(companyName, constraints.maxWidth),
                          ),
                          // Bottom White Form Container
                          _buildWhiteFormContainer(),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= MOBILE WHITE FORM CONTAINER =================
  Widget _buildWhiteFormContainer() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Welcome Back Greeting inside white container
          const Row(
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(width: 6),
              Text('👋', style: TextStyle(fontSize: 19)),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Login to manage your proposals & clients',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),

          // Form Inputs & Slider
          _buildFormContent(),
          const SizedBox(height: 10),
          _buildSignUpLink(),
          const SizedBox(height: 10),
          _buildBottomTrustBadges(),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  // ================= FULL SCREEN PURPLE & CIRCLES BACKGROUND =================
  Widget _buildFullScreenPurpleBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF1F5FD), // Soft ice blue
            Color(0xFFEDE9FE), // Soft Lavender/Purple
            Color(0xFFE0E7FF), // Soft Periwinkle
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Large ambient glowing purple circle (top right)
          Positioned(
            right: -60,
            top: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.16),
              ),
            ),
          ),

          // Medium floating circle (top left)
          Positioned(
            left: -40,
            top: 100,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF818CF8).withValues(alpha: 0.14),
              ),
            ),
          ),

          // Ambient bottom circle
          Positioned(
            right: -30,
            bottom: 120,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA5B4FC).withValues(alpha: 0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MOBILE HERO SECTION (BIGGER 3D QUOTATION) =================
  Widget _buildMobileHeroSection(String companyName, double screenWidth) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Large 3D Isometric Quotation Illustration centered / prominent in upper section
          Positioned(
            right: -10,
            top: -10,
            bottom: -15,
            child: const Center(
              child: QuotationIsometricIllustration(scale: 0.96),
            ),
          ),

          // 2. Brand Badge at top-left
          Positioned(
            left: 0,
            top: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Smart Quotes. Better Business.',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= DESKTOP LEFT HERO =================
  Widget _buildDesktopLeftHero(String companyName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 36, 24, 36),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F6FE),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          bottomLeft: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDotGrid(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Text(
                        'Smart Quotes. Better Business.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                    letterSpacing: -0.6,
                    fontFamily: 'PlusJakartaSans',
                  ),
                  children: [
                    TextSpan(text: 'Create Professional\nQuotations in '),
                    TextSpan(
                      text: 'Minutes',
                      style: TextStyle(
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Fast, simple and professional quotation management for your growing business.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
          const Center(
            child: QuotationIsometricIllustration(scale: 0.9),
          ),
        ],
      ),
    );
  }

  // ================= DESKTOP RIGHT FORM =================
  Widget _buildDesktopRightForm(String companyName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(-6, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top Language Selector Pill
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, size: 14, color: Color(0xFF475569)),
                  const SizedBox(width: 5),
                  Text(
                    _selectedLanguage,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Welcome Header
          const Row(
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(width: 8),
              Text('👋', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Login to your account and continue creating amazing quotations.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),

          // Form fields with Slider
          _buildFormContent(),

          const SizedBox(height: 20),

          // Sign Up Link
          _buildSignUpLink(),
        ],
      ),
    );
  }

  // ================= CORE FORM CONTENT =================
  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error Banner if any
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                  const SizedBox(width: 8),
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
            const SizedBox(height: 10),
          ],

          // Email / Username Input
          const Text(
            'Username',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _usernameController,
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Enter your username',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: Color(0xFF64748B)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Password Input + Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please contact your administrator to reset your password.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF64748B)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: const Color(0xFF94A3B8),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          // Remember Me Checkbox
          InkWell(
            onTap: () {
              setState(() {
                _rememberMe = !_rememberMe;
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    color: _rememberMe ? const Color(0xFF4F46E5) : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _rememberMe ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: _rememberMe
                      ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 7),
                const Text(
                  'Remember Me',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Swipe to Login Slider Button
          SwipeToLoginButton(
            onSwipeComplete: _handleLogin,
            isLoading: _isLoading,
            text: 'Slide to Sign In',
          ),
        ],
      ),
    );
  }

  // ================= SIGN UP LINK =================
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4F46E5),
            ),
          ),
        ),
      ],
    );
  }

  // ================= BOTTOM TRUST BADGES =================
  Widget _buildBottomTrustBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTrustItem(Icons.shield_outlined, 'Secure & Safe'),
        Container(height: 14, width: 1, color: const Color(0xFFCBD5E1)),
        _buildTrustItem(Icons.cloud_outlined, 'Cloud Sync'),
        Container(height: 14, width: 1, color: const Color(0xFFCBD5E1)),
        _buildTrustItem(Icons.bolt_outlined, 'Super Fast'),
      ],
    );
  }

  Widget _buildTrustItem(IconData icon, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 12, color: const Color(0xFF4F46E5)),
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildDotGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            children: List.generate(4, (colIndex) {
              return Container(
                width: 3.5,
                height: 3.5,
                margin: const EdgeInsets.only(right: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFCBD5E1),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
