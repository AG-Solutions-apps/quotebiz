import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_exceptions.dart';
import '../core/services/session_manager.dart';
import '../models/auth_model.dart';
import '../models/dashboard_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../widgets/create_client_dialog.dart';
import '../widgets/item_form_dialog.dart';
import '../widgets/monthly_trend_chart.dart';
import '../widgets/recent_quotation_item.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_donut_chart.dart';
import 'client_list_screen.dart';
import 'create_quotation_screen.dart';
import 'item_list_screen.dart';
import 'login_screen.dart';
import 'quotation_list_screen.dart';
import 'quotation_preview_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int initialTabIndex;

  const DashboardScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardRepository _dashboardRepository = DashboardRepository();
  final AuthRepository _authRepository = AuthRepository();

  int _selectedTabIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  DashboardData? _dashboardData;
  User? _currentUser;
  CompanyDetails? _companyDetails;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _loadUserAndDashboard();
  }

  Future<void> _loadUserAndDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await SessionManager.getCurrentUser();
      final company = await SessionManager.getCompanyDetails();
      if (!mounted) return;

      setState(() {
        _currentUser = user;
        _companyDetails = company;
      });

      final data = await _dashboardRepository.getDashboardData();

      if (!mounted) return;
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } on UnauthorizedException {
      if (!mounted) return;
      await SessionManager.clearSession();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _showQuickActionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildQuickActionTile(
                  title: 'Create Quotation',
                  subtitle: 'Draft a new estimate with live calculations',
                  icon: Icons.request_quote_rounded,
                  color: AppColors.blue,
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateQuotationScreen()),
                    ).then((_) => _loadUserAndDashboard());
                  },
                ),
                const SizedBox(height: 10),
                _buildQuickActionTile(
                  title: 'Add Client',
                  subtitle: 'Register a new customer profile',
                  icon: Icons.person_add_alt_1_rounded,
                  color: AppColors.cyanDark,
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const CreateClientDialog(),
                    ).then((_) => _loadUserAndDashboard());
                  },
                ),
                const SizedBox(height: 10),
                _buildQuickActionTile(
                  title: 'Add Item / Product',
                  subtitle: 'Add new goods or services to your catalog',
                  icon: Icons.add_shopping_cart_rounded,
                  color: AppColors.purpleAccent,
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const ItemFormDialog(),
                    ).then((_) => _loadUserAndDashboard());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildTopAppBar(),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _buildDashboardTabContent(),
          const ClientListScreen(isEmbedded: true),
          const QuotationListScreen(isEmbedded: true),
          const ItemListScreen(isEmbedded: true),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_alt_rounded),
              label: 'Clients',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Quotes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded),
              label: 'Items',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton(
              onPressed: _showQuickActionsSheet,
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildTopAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.request_quote_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _companyDetails?.companyName ?? 'QuoteBiz',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.navy,
                  letterSpacing: -0.3,
                ),
              ),
              const Text(
                'QUOTEBIZ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cyanDark,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
          onPressed: _loadUserAndDashboard,
        ),
        PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.blueLight,
            child: Text(
              (_currentUser?.name?.isNotEmpty == true ? _currentUser!.name![0] : 'U').toUpperCase(),
              style: const TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          onSelected: (value) {
            if (value == 'settings') {
              setState(() {
                _selectedTabIndex = 4;
              });
            } else if (value == 'logout') {
              _handleLogout();
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentUser?.name ?? 'User',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _currentUser?.email ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Divider(),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 18, color: AppColors.textPrimary),
                  SizedBox(width: 8),
                  Text('Settings', style: TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 18, color: Color(0xFFDC2626)),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(color: Color(0xFFDC2626))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDashboardTabContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: AppColors.danger, size: 48),
              const SizedBox(height: 14),
              const Text(
                'Failed to load dashboard data',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadUserAndDashboard,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _dashboardData;
    if (data == null) return const SizedBox.shrink();

    final currentMonthYear = DateFormat('MMMM yyyy').format(DateTime.now());

    return RefreshIndicator(
      onRefresh: _loadUserAndDashboard,
      color: AppColors.blue,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 768;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Welcome Banner (Navy #0F172A to Blue #2563EB with Cyan Glow)
                _buildHeroBanner(currentMonthYear),
                const SizedBox(height: 20),

                // 2. Metric Stat Cards
                _buildStatCards(data, isWide),
                const SizedBox(height: 24),

                // 3. Charts Section
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: StatusDonutChart(statusList: data.graph1)),
                      const SizedBox(width: 20),
                      Expanded(child: MonthlyTrendChart(trend: data.graph2)),
                    ],
                  )
                else ...[
                  StatusDonutChart(statusList: data.graph1),
                  const SizedBox(height: 20),
                  MonthlyTrendChart(trend: data.graph2),
                ],

                const SizedBox(height: 24),

                // 4. Recent Quotations Section
                _buildRecentQuotationsCard(data),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner(String currentMonthYear) {
    final userName = _currentUser?.name ?? 'User';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cyan,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      currentMonthYear,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _showQuickActionsSheet,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, size: 14, color: AppColors.cyan),
                      SizedBox(width: 4),
                      Text(
                        'Quick Action',
                        style: TextStyle(
                          fontSize: 11.5,
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
          const SizedBox(height: 14),
          Text(
            'Hello, $userName 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Here is your live quotation and revenue snapshot.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(DashboardData data, bool isWideScreen) {
    final card1 = StatCard(
      title: 'Total Quotations',
      value: '${data.totalQuotations}',
      icon: Icons.description_outlined,
      iconColor: AppColors.blue,
      iconBgColor: AppColors.blueLight,
      onTap: () => setState(() => _selectedTabIndex = 2),
    );

    final card2 = StatCard(
      title: 'Pending',
      value: '${data.pendingQuotations}',
      icon: Icons.access_time_rounded,
      iconColor: AppColors.warning,
      iconBgColor: AppColors.warningBg,
      onTap: () => setState(() => _selectedTabIndex = 2),
    );

    final card3 = StatCard(
      title: 'Approved',
      value: '${data.approvedQuotations}',
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.success,
      iconBgColor: AppColors.successBg,
      onTap: () => setState(() => _selectedTabIndex = 2),
    );

    final card4 = StatCard(
      title: 'Monthly Amount',
      value: '₹${data.monthlyAmount}',
      icon: Icons.trending_up_rounded,
      iconColor: AppColors.cyanDark,
      iconBgColor: AppColors.cyanLight,
      onTap: () => setState(() => _selectedTabIndex = 2),
    );

    if (isWideScreen) {
      return Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 16),
          Expanded(child: card2),
          const SizedBox(width: 16),
          Expanded(child: card3),
          const SizedBox(width: 16),
          Expanded(child: card4),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: card1),
            const SizedBox(width: 14),
            Expanded(child: card2),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: card3),
            const SizedBox(width: 14),
            Expanded(child: card4),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentQuotationsCard(DashboardData data) {
    final items = data.lastQuotations;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.blueLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        color: AppColors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Recent Quotations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Latest quotation activities',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTabIndex = 2;
                    });
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Items List
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No recent quotation records',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (ctx, index) {
                  final item = items[index];
                  return InkWell(
                    onTap: () {
                      if (item.id != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuotationPreviewScreen(quotationId: item.id!),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: RecentQuotationItem(item: item),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
