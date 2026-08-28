import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_exceptions.dart';
import '../core/services/session_manager.dart';
import '../models/settings_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/settings_repository.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsRepository _settingsRepository = SettingsRepository();
  final AuthRepository _authRepository = AuthRepository();
  final ImagePicker _picker = ImagePicker();

  int _selectedTabIndex = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditingCompanyAccount = false;
  String? _errorMessage;

  // Branch Settings Controllers
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _branchGstController = TextEditingController();
  final TextEditingController _branchAddressController = TextEditingController();
  final TextEditingController _branchMobileController = TextEditingController();
  final TextEditingController _branchEmailController = TextEditingController();
  final TextEditingController _branchCurrencyController = TextEditingController();
  final TextEditingController _branchTaxRateController = TextEditingController();
  final TextEditingController _branchFooterController = TextEditingController();
  final TextEditingController _branchTCController = TextEditingController();
  String _branchDefault = 'both'; // 'both', 'logo', 'text'

  // Login Details Controllers
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userMobileController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();

  // Change Password Controllers
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Branding
  String? _existingLogoUrl;
  String? _existingSignUrl;
  XFile? _pickedLogo;
  XFile? _pickedSign;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _branchNameController.dispose();
    _branchGstController.dispose();
    _branchAddressController.dispose();
    _branchMobileController.dispose();
    _branchEmailController.dispose();
    _branchCurrencyController.dispose();
    _branchTaxRateController.dispose();
    _branchFooterController.dispose();
    _branchTCController.dispose();

    _userNameController.dispose();
    _userMobileController.dispose();
    _userEmailController.dispose();

    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _settingsRepository.fetchBranch(),
        _settingsRepository.fetchProfile(),
      ]);

      if (!mounted) return;

      final branch = results[0] as BranchSettings;
      final profile = results[1] as UserProfile;

      // Populate Branch
      _branchNameController.text = branch.branchName ?? '';
      _branchGstController.text = branch.branchGst ?? '';
      _branchAddressController.text = branch.branchAddress ?? '';
      _branchMobileController.text = branch.branchMobileNo ?? '';
      _branchEmailController.text = branch.branchEmailId ?? '';
      _branchCurrencyController.text = branch.branchCurrency ?? 'INR';
      _branchTaxRateController.text = branch.branchTaxRate ?? '18';
      _branchFooterController.text = branch.branchFooter ?? '';
      _branchTCController.text = branch.branchTC ?? '';
      _branchDefault = branch.branchDefault?.toLowerCase().trim() ?? 'both';
      if (_branchDefault.isEmpty) _branchDefault = 'both';

      _existingLogoUrl = branch.branchLogo;
      _existingSignUrl = branch.branchSign;

      // Populate Profile
      _userNameController.text = profile.name;
      _userMobileController.text = profile.mobile ?? '';
      _userEmailController.text = profile.email ?? '';

      setState(() {
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

  Future<void> _saveCompanyAndAccountSettings() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // 1. Update Branch Settings
      await _settingsRepository.updateBranch(
        branchName: _branchNameController.text,
        branchAddress: _branchAddressController.text,
        branchGst: _branchGstController.text,
        branchMobileNo: _branchMobileController.text,
        branchEmailId: _branchEmailController.text,
        branchCurrency: _branchCurrencyController.text,
        branchTaxRate: _branchTaxRateController.text,
        branchFooter: _branchFooterController.text,
        branchLogo: _existingLogoUrl,
        branchSign: _existingSignUrl,
        branchTC: _branchTCController.text,
        branchDefault: _branchDefault,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Company details saved successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      await _loadSettings();
      setState(() {
        _isEditingCompanyAccount = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _savePassword() async {
    final currentPass = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (currentPass.isEmpty) {
      setState(() => _errorMessage = 'Please enter your current password');
      return;
    }
    if (newPass.isEmpty) {
      setState(() => _errorMessage = 'Please enter a new password');
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'New password and confirm password do not match');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Simulate password update
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Password updated successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _saveBranding() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final File? logoFile = _pickedLogo != null ? File(_pickedLogo!.path) : null;
      final File? signFile = _pickedSign != null ? File(_pickedSign!.path) : null;

      await _settingsRepository.updateBranch(
        branchName: _branchNameController.text,
        branchAddress: _branchAddressController.text,
        branchGst: _branchGstController.text,
        branchMobileNo: _branchMobileController.text,
        branchEmailId: _branchEmailController.text,
        branchCurrency: _branchCurrencyController.text,
        branchTaxRate: _branchTaxRateController.text,
        branchFooter: _branchFooterController.text,
        branchLogo: _existingLogoUrl,
        branchSign: _existingSignUrl,
        branchTC: _branchTCController.text,
        branchDefault: _branchDefault,
        logoFile: logoFile,
        signFile: signFile,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Brand images updated successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      await _loadSettings();
      setState(() {
        _pickedLogo = null;
        _pickedSign = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pickImage(bool isLogo) async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          if (isLogo) {
            _pickedLogo = file;
          } else {
            _pickedSign = file;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  String _getHeaderStyleDisplay(String value) {
    switch (value.toLowerCase()) {
      case 'text':
      case 'only_text':
        return 'Header: Only Text';
      case 'logo':
      case 'only_logo':
        return 'Header: Only Logo';
      case 'both':
      default:
        return 'Header: Both Logo & Text';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error Banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFF991B1B),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
                            onPressed: () => setState(() => _errorMessage = null),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 3-Section Modern Tab Segment Selector
                  _buildSectionTabs(),
                  const SizedBox(height: 16),

                  // Tab Content
                  IndexedStack(
                    index: _selectedTabIndex,
                    children: [
                      _buildCompanyAndAccountTab(),
                      _buildChangePasswordTab(),
                      _buildThemeAndBrandingTab(),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // ================= 3-SECTION TABS HEADER =================
  Widget _buildSectionTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Account', Icons.business_center_rounded),
          _buildTabItem(1, 'Security', Icons.lock_outline_rounded),
          _buildTabItem(2, 'Brand', Icons.palette_outlined),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            _errorMessage = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.blue : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.navy : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TAB 0: COMPANY & ACCOUNT DETAILS =================
  Widget _buildCompanyAndAccountTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Edit Toggle Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Company & Account',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isEditingCompanyAccount
                          ? 'Edit details below'
                          : 'Tap edit to update profile',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!_isEditingCompanyAccount)
                InkWell(
                  onTap: () {
                    setState(() {
                      _isEditingCompanyAccount = true;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.blueLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.blue.withValues(alpha: 0.25)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded, size: 14, color: AppColors.blue),
                        SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 12,
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
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),

          // Read-Only View Mode vs Editable Form Mode
          if (!_isEditingCompanyAccount)
            _buildCompanyAccountReadOnlyView()
          else
            _buildCompanyAccountEditForm(),
        ],
      ),
    );
  }

  /// Read-Only Display Mode (Shows clean icon + value tiles)
  Widget _buildCompanyAccountReadOnlyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section A: Company Information
        const Text(
          'COMPANY DETAILS',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: AppColors.blue,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        _buildInfoTile(_branchNameController.text, Icons.domain_rounded, placeholder: 'Company / Branch Name'),
        _buildInfoTile(_getHeaderStyleDisplay(_branchDefault), Icons.view_headline_rounded, placeholder: 'Quotation Header Style'),
        if (_branchGstController.text.isNotEmpty)
          _buildInfoTile(_branchGstController.text, Icons.receipt_long_rounded, placeholder: 'GST Number'),
        _buildInfoTile(_branchAddressController.text, Icons.location_on_rounded, placeholder: 'Branch Address'),
        _buildInfoTile(_branchMobileController.text, Icons.phone_rounded, placeholder: 'Company Phone'),
        _buildInfoTile(_branchEmailController.text, Icons.email_rounded, placeholder: 'Company Email'),
        _buildInfoTile('${_branchCurrencyController.text} • ${_branchTaxRateController.text}% GST', Icons.payments_rounded),
        if (_branchFooterController.text.isNotEmpty)
          _buildInfoTile(_branchFooterController.text, Icons.notes_rounded, placeholder: 'Quotation Footer'),
        if (_branchTCController.text.isNotEmpty)
          _buildInfoTile(_branchTCController.text, Icons.gavel_rounded, placeholder: 'Terms & Conditions'),

        const SizedBox(height: 20),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 16),

        // Section B: Login / Account Information
        const Text(
          'ADMINISTRATOR PROFILE',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: AppColors.cyanDark,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        _buildInfoTile(_userNameController.text, Icons.person_rounded, placeholder: 'Administrator Name'),
        _buildInfoTile(_userMobileController.text, Icons.phone_android_rounded, placeholder: 'Login Mobile'),
        _buildInfoTile(_userEmailController.text, Icons.alternate_email_rounded, placeholder: 'Login Email'),

        const SizedBox(height: 24),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 20),

        // Section C: Account Session & Security Actions
        Row(
          children: [
            // Logout Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.navy),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  backgroundColor: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Delete Account Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleDeleteAccount,
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                label: const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3)),
                  backgroundColor: AppColors.dangerBg,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authRepository.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24),
            SizedBox(width: 8),
            Text(
              'Delete Account',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? All your quotations, client records, and branch settings will be permanently removed. This action cannot be undone.',
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authRepository.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deletion requested and session ended.'),
          backgroundColor: AppColors.navy,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildInfoTile(String value, IconData icon, {String placeholder = 'Not provided'}) {
    final hasValue = value.trim().isNotEmpty;
    final displayValue = hasValue ? value.trim() : placeholder;

    return InkWell(
      onTap: () {
        setState(() {
          _isEditingCompanyAccount = true;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, size: 17, color: AppColors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                  color: hasValue ? AppColors.navy : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  /// Editable Form Mode
  Widget _buildCompanyAccountEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Company Section
        const Text(
          'COMPANY DETAILS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.blue,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 14),

        _buildFieldLabelWithIcon('Branch Name', Icons.domain_outlined),
        TextFormField(
          controller: _branchNameController,
          decoration: const InputDecoration(hintText: 'Enter branch name'),
        ),
        const SizedBox(height: 14),

        // Quotation Header Style Selector (branch_default)
        _buildFieldLabelWithIcon('Quotation Header Format', Icons.view_headline_rounded),
        const SizedBox(height: 4),
        const Text(
          'Select how your company header appears on quotation PDFs & previews:',
          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildHeaderFormatOption('both', 'Both Logo & Text', Icons.auto_awesome_mosaic_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _buildHeaderFormatOption('logo', 'Only Logo', Icons.image_outlined)),
            const SizedBox(width: 8),
            Expanded(child: _buildHeaderFormatOption('text', 'Only Text', Icons.text_fields_rounded)),
          ],
        ),
        const SizedBox(height: 10),
        _buildLiveHeaderPreview(),
        const SizedBox(height: 16),

        _buildFieldLabelWithIcon('GST Number', Icons.receipt_long_outlined),
        TextFormField(
          controller: _branchGstController,
          decoration: const InputDecoration(hintText: 'Enter GST number'),
        ),
        const SizedBox(height: 14),

        _buildFieldLabelWithIcon('Branch Address', Icons.location_on_outlined),
        TextFormField(
          controller: _branchAddressController,
          decoration: const InputDecoration(hintText: 'Enter branch address'),
        ),
        const SizedBox(height: 14),

        _buildFieldLabelWithIcon('Company Phone', Icons.phone_outlined),
        TextFormField(
          controller: _branchMobileController,
          decoration: const InputDecoration(hintText: 'Enter mobile number'),
        ),
        const SizedBox(height: 14),

        _buildFieldLabelWithIcon('Company Email', Icons.email_outlined),
        TextFormField(
          controller: _branchEmailController,
          decoration: const InputDecoration(hintText: 'Enter email address'),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabelWithIcon('Currency', Icons.attach_money_rounded),
                  TextFormField(
                    controller: _branchCurrencyController,
                    decoration: const InputDecoration(hintText: 'INR'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabelWithIcon('Tax Rate (%)', Icons.percent_rounded),
                  TextFormField(
                    controller: _branchTaxRateController,
                    decoration: const InputDecoration(hintText: '18'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        _buildFieldLabelWithIcon('Quotation Footer Note', Icons.notes_outlined),
        TextFormField(
          controller: _branchFooterController,
          maxLines: 2,
          decoration: const InputDecoration(hintText: 'Thank you for your business...'),
        ),
        const SizedBox(height: 14),

        _buildFieldLabelWithIcon('Terms & Conditions', Icons.gavel_outlined),
        TextFormField(
          controller: _branchTCController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Warranty, Delivery, Payment Terms...'),
        ),

        const SizedBox(height: 28),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 20),

        // 2. Administrator Account Section
        const Text(
          'ADMINISTRATOR PROFILE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.cyanDark,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 14),

        _buildFieldLabelWithIcon('Name', Icons.person_outline_rounded),
        TextFormField(
          controller: _userNameController,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        const SizedBox(height: 14),

        _buildFieldLabelWithIcon('Login Mobile', Icons.phone_android_rounded),
        TextFormField(
          controller: _userMobileController,
          decoration: const InputDecoration(hintText: 'Enter login mobile'),
        ),
        const SizedBox(height: 14),

        _buildFieldLabelWithIcon('Login Email', Icons.alternate_email_rounded),
        TextFormField(
          controller: _userEmailController,
          decoration: const InputDecoration(hintText: 'Enter login email'),
        ),
        const SizedBox(height: 28),

        // Save & Cancel Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditingCompanyAccount = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveCompanyAndAccountSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderFormatOption(String value, String label, IconData icon) {
    final isSelected = _branchDefault.toLowerCase() == value.toLowerCase();

    return InkWell(
      onTap: () {
        setState(() {
          _branchDefault = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.blue : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.blue : AppColors.textMuted,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.blue : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Live Quotation Header Mini-Preview
  Widget _buildLiveHeaderPreview() {
    final companyName = _branchNameController.text.trim().isNotEmpty
        ? _branchNameController.text.trim()
        : 'QuoteBiz';
    final address = _branchAddressController.text.trim().isNotEmpty
        ? _branchAddressController.text.trim()
        : '123 Business Avenue, Suite 400';
    final phone = _branchMobileController.text.trim().isNotEmpty
        ? _branchMobileController.text.trim()
        : '+91 98765 43210';
    final gst = _branchGstController.text.trim().isNotEmpty
        ? 'GSTIN: ${_branchGstController.text.trim()}'
        : 'GSTIN: 27AABCV1234F1Z5';

    final mode = _branchDefault.toLowerCase().trim();

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_outlined, size: 14, color: AppColors.blue),
                  SizedBox(width: 5),
                  Text(
                    'HEADER LIVE PREVIEW',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.blue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getHeaderStyleDisplay(mode),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Side: Mode-dependent Header element
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo thumbnail if 'both' or 'logo'
                      if (mode == 'both' || mode == 'logo') ...[
                        _buildPreviewLogoWidget(),
                        if (mode == 'both') const SizedBox(width: 10),
                      ],

                      // Company Name if 'both' or 'text'
                      if (mode == 'both' || mode == 'text')
                        Flexible(
                          child: Text(
                            companyName,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),

                // Right Side: Branch details
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      gst,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
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

  Widget _buildPreviewLogoWidget() {
    if (_pickedLogo != null) {
      if (kIsWeb) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            _pickedLogo!.path,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            File(_pickedLogo!.path),
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
        );
      }
    }

    if (_existingLogoUrl != null && _existingLogoUrl!.isNotEmpty) {
      final fullUrl = ApiConstants.getBranchImageUrl(_existingLogoUrl!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          fullUrl,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildDefaultLogoPlaceholder(),
        ),
      );
    }

    return _buildDefaultLogoPlaceholder();
  }

  Widget _buildDefaultLogoPlaceholder() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.receipt_long_rounded,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  // ================= TAB 1: CHANGE PASSWORD =================
  Widget _buildChangePasswordTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Change Password',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ensure your account is using a strong password for security',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 20),

          _buildFieldLabelWithIcon('Current Password', Icons.lock_outline_rounded),
          TextFormField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrent,
            decoration: InputDecoration(
              hintText: 'Enter current password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
            ),
          ),
          const SizedBox(height: 16),

          _buildFieldLabelWithIcon('New Password', Icons.vpn_key_outlined),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNew,
            decoration: InputDecoration(
              hintText: 'Enter new password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
          ),
          const SizedBox(height: 16),

          _buildFieldLabelWithIcon('Confirm New Password', Icons.check_circle_outline_rounded),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              hintText: 'Confirm new password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),
          const SizedBox(height: 28),

          ElevatedButton(
            onPressed: _isSaving ? null : _savePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Update Password',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 2: THEME & BRANDING =================
  Widget _buildThemeAndBrandingTab() {
    final logoUrl = ApiConstants.getBranchImageUrl(_existingLogoUrl);
    final signUrl = ApiConstants.getBranchImageUrl(_existingSignUrl);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Brand Assets & Images',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Upload your official company logo and signature for quotations',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 20),

          // 1. Company Logo Picker
          const Text(
            'COMPANY LOGO',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.blue,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          _buildImagePickerCard(
            label: 'Company Logo',
            icon: Icons.business_outlined,
            pickedFile: _pickedLogo,
            existingUrl: logoUrl,
            onPick: () => _pickImage(true),
            onRemove: () => setState(() => _pickedLogo = null),
          ),

          const SizedBox(height: 24),

          // 2. Authorized Signature Picker
          const Text(
            'AUTHORIZED SIGNATURE',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.cyanDark,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          _buildImagePickerCard(
            label: 'Signature Image',
            icon: Icons.draw_outlined,
            pickedFile: _pickedSign,
            existingUrl: signUrl,
            onPick: () => _pickImage(false),
            onRemove: () => setState(() => _pickedSign = null),
          ),

          const SizedBox(height: 28),

          // Save Branding Images Button
          ElevatedButton(
            onPressed: _isSaving ? null : _saveBranding,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Upload & Save Brand Assets',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerCard({
    required String label,
    required IconData icon,
    required XFile? pickedFile,
    required String existingUrl,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final hasPicked = pickedFile != null;
    final hasExisting = existingUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Preview Box
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: hasPicked
                  ? Image.file(File(pickedFile.path), fit: BoxFit.contain)
                  : hasExisting
                      ? Image.network(
                          existingUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(icon, color: AppColors.textMuted, size: 28),
                        )
                      : Icon(icon, color: AppColors.textMuted, size: 28),
            ),
          ),
          const SizedBox(width: 14),

          // Details & Pick Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasPicked
                      ? 'New file: ${pickedFile.name}'
                      : hasExisting
                          ? 'Current asset loaded'
                          : 'No image uploaded yet',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: hasPicked ? AppColors.blue : AppColors.textSecondary,
                    fontWeight: hasPicked ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: onPick,
                      icon: const Icon(Icons.upload_file_rounded, size: 14),
                      label: Text(hasPicked || hasExisting ? 'Change' : 'Upload'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    if (hasPicked) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.danger),
                        tooltip: 'Cancel upload',
                        onPressed: onRemove,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabelWithIcon(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.blue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
