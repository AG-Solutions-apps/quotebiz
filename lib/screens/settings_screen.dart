import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_exceptions.dart';
import '../core/services/session_manager.dart';
import '../models/settings_model.dart';
import '../repositories/settings_repository.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsRepository _settingsRepository = SettingsRepository();
  final ImagePicker _picker = ImagePicker();

  int _selectedTabIndex = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Branch Settings Controllers (Tab 0)
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _branchGstController = TextEditingController();
  final TextEditingController _branchAddressController = TextEditingController();
  final TextEditingController _branchMobileController = TextEditingController();
  final TextEditingController _branchEmailController = TextEditingController();
  final TextEditingController _branchCurrencyController = TextEditingController();
  final TextEditingController _branchTaxRateController = TextEditingController();
  final TextEditingController _branchFooterController = TextEditingController();
  final TextEditingController _branchTCController = TextEditingController();

  // Login Details Controllers (Tab 1)
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userMobileController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();

  // Change Password Controllers (Tab 2)
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Branding (Tab 3)
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

  Future<void> _saveBranchSettings() async {
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
              Text('Settings saved successfully!'),
            ],
          ),
          backgroundColor: AppColors.successGreen,
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Widget _buildFieldLabelWithIcon(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Settings',
            onPressed: _loadSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSettings,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title & Subtitle
                    const Text(
                      'Company Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage your company information and profile settings',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Navigation Tabs Pill Container
                    _buildTabsBar(),
                    const SizedBox(height: 20),

                    // Error message banner if any
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

                    // Tab Content Card
                    _buildActiveTabContent(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTabsBar() {
    final tabs = [
      'Company Details',
      'Login Details',
      'Change Password',
      'Theme & Branding',
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _selectedTabIndex == index;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                    _errorMessage = null;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildCompanyDetailsTab();
      case 1:
        return _buildLoginDetailsTab();
      case 2:
        return _buildChangePasswordTab();
      case 3:
        return _buildThemeAndBrandingTab();
      default:
        return _buildCompanyDetailsTab();
    }
  }

  // ================= TAB 0: COMPANY DETAILS =================
  Widget _buildCompanyDetailsTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Company Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Update your company branch details and settings',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Row 1: Branch Name & GST Number
              if (isWide)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabelWithIcon('Branch Name', Icons.domain_outlined),
                          TextFormField(
                            controller: _branchNameController,
                            decoration: const InputDecoration(hintText: 'Enter branch name'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabelWithIcon('GST Number', Icons.receipt_long_outlined),
                          TextFormField(
                            controller: _branchGstController,
                            decoration: const InputDecoration(hintText: 'Enter GST number'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _buildFieldLabelWithIcon('Branch Name', Icons.domain_outlined),
                TextFormField(
                  controller: _branchNameController,
                  decoration: const InputDecoration(hintText: 'Enter branch name'),
                ),
                const SizedBox(height: 16),
                _buildFieldLabelWithIcon('GST Number', Icons.receipt_long_outlined),
                TextFormField(
                  controller: _branchGstController,
                  decoration: const InputDecoration(hintText: 'Enter GST number'),
                ),
              ],
              const SizedBox(height: 16),

              // Row 2: Branch Address
              _buildFieldLabelWithIcon('Branch Address', Icons.location_on_outlined),
              TextFormField(
                controller: _branchAddressController,
                decoration: const InputDecoration(hintText: 'Enter branch address'),
              ),
              const SizedBox(height: 16),

              // Row 3: Mobile Number & Email Address
              if (isWide)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabelWithIcon('Mobile Number', Icons.phone_outlined),
                          TextFormField(
                            controller: _branchMobileController,
                            decoration: const InputDecoration(hintText: 'Enter mobile number'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabelWithIcon('Email Address', Icons.email_outlined),
                          TextFormField(
                            controller: _branchEmailController,
                            decoration: const InputDecoration(hintText: 'Enter email address'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _buildFieldLabelWithIcon('Mobile Number', Icons.phone_outlined),
                TextFormField(
                  controller: _branchMobileController,
                  decoration: const InputDecoration(hintText: 'Enter mobile number'),
                ),
                const SizedBox(height: 16),
                _buildFieldLabelWithIcon('Email Address', Icons.email_outlined),
                TextFormField(
                  controller: _branchEmailController,
                  decoration: const InputDecoration(hintText: 'Enter email address'),
                ),
              ],
              const SizedBox(height: 16),

              // Row 4: Currency & Tax Rate (%)
              if (isWide)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabelWithIcon('Currency', Icons.language_outlined),
                          TextFormField(
                            controller: _branchCurrencyController,
                            decoration: const InputDecoration(hintText: 'INR'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabelWithIcon('Tax Rate (%)', Icons.percent_outlined),
                          TextFormField(
                            controller: _branchTaxRateController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '18'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _buildFieldLabelWithIcon('Currency', Icons.language_outlined),
                TextFormField(
                  controller: _branchCurrencyController,
                  decoration: const InputDecoration(hintText: 'INR'),
                ),
                const SizedBox(height: 16),
                _buildFieldLabelWithIcon('Tax Rate (%)', Icons.percent_outlined),
                TextFormField(
                  controller: _branchTaxRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '18'),
                ),
              ],
              const SizedBox(height: 16),

              // Row 5: Invoice Footer
              _buildFieldLabelWithIcon('Invoice Footer', Icons.edit_note_outlined),
              TextFormField(
                controller: _branchFooterController,
                maxLines: 2,
                decoration: const InputDecoration(hintText: 'Enter invoice footer text'),
              ),
              const SizedBox(height: 16),

              // Row 6: Terms & Conditions (branch_t_c)
              _buildFieldLabelWithIcon('Terms & Conditions', Icons.description_outlined),
              TextFormField(
                controller: _branchTCController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Enter terms and conditions (optional)'),
              ),
              const SizedBox(height: 24),

              // Save Changes Action Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveBranchSettings,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64748B), // Slate matching screenshot
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= TAB 1: LOGIN DETAILS =================
  Widget _buildLoginDetailsTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Login Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Update your personal login information',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Row 1: Name & Mobile Number
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabelWithIcon('Name', Icons.person_outline),
                          TextFormField(
                            controller: _userNameController,
                            enabled: false, // Disabled matching screenshot
                            decoration: const InputDecoration(
                              hintText: 'Enter name',
                              helperText: 'Name cannot be changed',
                              helperStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabelWithIcon('Mobile Number', Icons.phone_outlined),
                          TextFormField(
                            controller: _userMobileController,
                            decoration: const InputDecoration(hintText: 'Enter mobile number'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _buildFieldLabelWithIcon('Name', Icons.person_outline),
                TextFormField(
                  controller: _userNameController,
                  enabled: false,
                  decoration: const InputDecoration(
                    hintText: 'Enter name',
                    helperText: 'Name cannot be changed',
                    helperStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFieldLabelWithIcon('Mobile Number', Icons.phone_outlined),
                TextFormField(
                  controller: _userMobileController,
                  decoration: const InputDecoration(hintText: 'Enter mobile number'),
                ),
              ],
              const SizedBox(height: 16),

              // Row 2: Email Address
              _buildFieldLabelWithIcon('Email Address', Icons.email_outlined),
              TextFormField(
                controller: _userEmailController,
                decoration: const InputDecoration(hintText: 'Enter email address'),
              ),
              const SizedBox(height: 24),

              // Save Changes Action Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile information updated.'),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        },
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64748B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= TAB 2: CHANGE PASSWORD =================
  Widget _buildChangePasswordTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Update your account password for security',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Current Password
              _buildFieldLabelWithIcon('Current Password', Icons.lock_outline),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  hintText: 'Enter current password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // New Password & Confirm Password
              if (isWide)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabelWithIcon('New Password', Icons.lock_outline),
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureNew,
                            decoration: InputDecoration(
                              hintText: 'Enter new password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabelWithIcon('Confirm Password', Icons.lock_outline),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              hintText: 'Confirm new password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _buildFieldLabelWithIcon('New Password', Icons.lock_outline),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    hintText: 'Enter new password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFieldLabelWithIcon('Confirm Password', Icons.lock_outline),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Confirm new password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Change Password Button (Dark button)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_newPasswordController.text != _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('New passwords do not match.')),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully!'),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                  },
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: const Text('Change Password'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), // Dark slate / black
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= TAB 3: THEME & BRANDING =================
  Widget _buildThemeAndBrandingTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Theme & Branding',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Upload company logo and authorized signature images',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildImagePickerCard('Company Logo (branch_logo)', _pickedLogo, _existingLogoUrl, true)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildImagePickerCard('Authorized Signature (branch_sign)', _pickedSign, _existingSignUrl, false)),
                  ],
                )
              else ...[
                _buildImagePickerCard('Company Logo (branch_logo)', _pickedLogo, _existingLogoUrl, true),
                const SizedBox(height: 20),
                _buildImagePickerCard('Authorized Signature (branch_sign)', _pickedSign, _existingSignUrl, false),
              ],
              const SizedBox(height: 28),

              // Save Changes Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveBranchSettings,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64748B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImagePickerCard(String title, XFile? pickedFile, String? existingUrl, bool isLogo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Preview Area
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: pickedFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(pickedFile.path),
                      fit: BoxFit.contain,
                    ),
                  )
                : (existingUrl != null && existingUrl.isNotEmpty)
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_outlined, color: AppColors.primary, size: 36),
                            const SizedBox(height: 6),
                            Text(
                              existingUrl,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, color: Colors.grey.shade400, size: 36),
                            const SizedBox(height: 6),
                            const Text(
                              'No image selected',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
          ),
          const SizedBox(height: 12),

          // Pick Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(isLogo),
              icon: const Icon(Icons.photo_library_outlined, size: 16),
              label: Text(pickedFile != null || existingUrl != null ? 'Change Image' : 'Select Image'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
