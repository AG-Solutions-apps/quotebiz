import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/panel_status_model.dart';
import '../repositories/auth_repository.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  final PanelStatusResponse? panelStatus;

  const RegisterScreen({
    super.key,
    this.panelStatus,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController _branchShortController = TextEditingController();
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _branchAddressController = TextEditingController();
  final TextEditingController _branchGstController = TextEditingController();
  final TextEditingController _branchMobileController = TextEditingController();
  final TextEditingController _branchEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _branchShortController.dispose();
    _branchNameController.dispose();
    _branchAddressController.dispose();
    _branchGstController.dispose();
    _branchMobileController.dispose();
    _branchEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.register(
        branchShort: _branchShortController.text.trim(),
        branchName: _branchNameController.text.trim(),
        branchAddress: _branchAddressController.text.trim(),
        branchGst: _branchGstController.text.trim(),
        branchMobileNo: _branchMobileController.text.trim(),
        branchEmailId: _branchEmailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Registration successful! Welcome to QuoteBiz.'),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          duration: Duration(seconds: 3),
        ),
      );

      // Move directly to Dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo & Branding Header
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, Color(0xFF1D4ED8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.app_registration_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Register for QuoteBiz',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter your company and account details to get started',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Error message banner
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
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFF991B1B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 1. Short Code (branch_short / branch_name_short)
                      _buildFieldLabel('Short Code', isRequired: true),
                      TextFormField(
                        controller: _branchShortController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. JK, DO',
                          prefixIcon: Icon(Icons.tag_rounded, size: 18, color: AppColors.textSecondary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter short code' : null,
                      ),
                      const SizedBox(height: 16),

                      // 2. Company / Branch Name (branch_name)
                      _buildFieldLabel('Company / Branch Name', isRequired: true),
                      TextFormField(
                        controller: _branchNameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. JK Steels',
                          prefixIcon: Icon(Icons.domain_outlined, size: 18, color: AppColors.textSecondary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter company name' : null,
                      ),
                      const SizedBox(height: 16),

                      // 3. Mobile Number (branch_mobile_no)
                      _buildFieldLabel('Mobile Number', isRequired: true),
                      TextFormField(
                        controller: _branchMobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 8756321456',
                          prefixIcon: Icon(Icons.phone_outlined, size: 18, color: AppColors.textSecondary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter mobile number' : null,
                      ),
                      const SizedBox(height: 16),

                      // 4. Email Address (branch_email_id)
                      _buildFieldLabel('Email Address', isRequired: true),
                      TextFormField(
                        controller: _branchEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'admin@demo.com',
                          prefixIcon: Icon(Icons.email_outlined, size: 18, color: AppColors.textSecondary),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter email address';
                          if (!val.contains('@') || !val.contains('.')) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 5. GST Number (Optional)
                      _buildFieldLabel('GST Number (Optional)', isRequired: false),
                      TextFormField(
                        controller: _branchGstController,
                        decoration: const InputDecoration(
                          hintText: 'Enter GST/VAT number (optional)',
                          prefixIcon: Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 6. Branch Address (Optional)
                      _buildFieldLabel('Branch Address (Optional)', isRequired: false),
                      TextFormField(
                        controller: _branchAddressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Enter complete branch address (optional)',
                          prefixIcon: Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 7. Password
                      _buildFieldLabel('Password', isRequired: true),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter a password';
                          if (val.length < 4) return 'Password must be at least 4 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Register Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Back to Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
