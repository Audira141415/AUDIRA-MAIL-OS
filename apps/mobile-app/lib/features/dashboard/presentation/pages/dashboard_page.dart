import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/industrial_theme.dart';
import '../../../../core/components/industrial_card.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../dashboard_provider.dart';
import '../../data/dashboard_models.dart';
import 'gmail_accounts_page.dart';
import 'ai_copilot_tab.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _currentIndex = 0;
  String _otpSearchQuery = '';
  String? _otpSelectedAccountId;
  String? _inboxSelectedAccountId;

  final ScrollController _inboxScrollController = ScrollController();
  final ScrollController _otpScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _inboxScrollController.addListener(_onInboxScroll);
    _otpScrollController.addListener(_onOtpScroll);
  }

  @override
  void dispose() {
    _inboxScrollController.dispose();
    _otpScrollController.dispose();
    super.dispose();
  }

  void _onInboxScroll() {
    if (_inboxScrollController.position.pixels >= _inboxScrollController.position.maxScrollExtent - 200) {
      ref.read(emailPaginationProvider(EmailFilter(searchQuery: '', accountId: _inboxSelectedAccountId)).notifier).loadMore();
    }
  }

  void _onOtpScroll() {
    if (_otpScrollController.position.pixels >= _otpScrollController.position.maxScrollExtent - 200) {
      ref.read(otpPaginationProvider(OtpFilter(searchQuery: _otpSearchQuery, accountId: _otpSelectedAccountId)).notifier).loadMore();
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboardTab(),
      _buildUnifiedInboxTab(),
      _buildOtpCenterTab(),
      _buildAiCopilotTab(),
      _buildMoreTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.chassis,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Noise Overlay (simulating plastic texture)
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.03,
                child: Image.network(
                  'https://www.transparenttextures.com/patterns/stardust.png',
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: pages[_currentIndex],
          ),
          // Industrial Floating Nav Bar
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: _buildIndustrialNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildIndustrialNavBar() {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: AppColors.chassis,
        borderRadius: BorderRadius.circular(30),
        boxShadow: IndustrialTheme.shadowFloating,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'SYS'),
          _buildNavItem(1, Icons.mail_outline, Icons.mail, 'INBX'),
          _buildNavItem(2, Icons.lock_outline, Icons.lock, 'AUTH'),
          _buildNavItem(3, Icons.auto_awesome_outlined, Icons.auto_awesome, 'AI'),
          _buildNavItem(4, Icons.more_horiz, Icons.more_horiz, 'CFG'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60,
        height: 65,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9, 
                fontWeight: FontWeight.w800, 
                letterSpacing: 1.2,
                color: isSelected ? AppColors.accent : AppColors.textMuted,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: DASHBOARD ---
  Widget _buildDashboardTab() {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final recentOtpsAsync = ref.watch(recentOtpsProvider(OtpFilter(searchQuery: '')));

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () async {
        ref.invalidate(dashboardStatsProvider);
        ref.invalidate(recentOtpsProvider(OtpFilter(searchQuery: '')));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('SYSTEM STATUS', showProfile: true),
            const SizedBox(height: 32),

            // Stats Grid - Real Data
            statsAsync.when(
              loading: () => _buildStatsPlaceholder(),
              error: (e, _) => _buildErrorCard('STATS_LOAD_ERR: $e'),
              data: (stats) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('ACCOUNTS', stats.totalAccounts.toString(), Icons.people)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('ACTIVE', stats.activeAccounts.toString(), Icons.check_circle, isAccent: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('INBOUND', stats.emailsToday.toString(), Icons.mail)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('OTP GEN', stats.otpToday.toString(), Icons.lock)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RECENT AUTH LOG', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontFamily: 'monospace')),
                TextButton(onPressed: () => _onTabTapped(2), child: const Text('VIEW_ALL', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
              ],
            ),
            const SizedBox(height: 8),

            // Recent OTPs - Real Data
            recentOtpsAsync.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppColors.accent))),
              error: (e, _) => _buildErrorCard('OTP_LOG_ERR'),
              data: (otps) => otps.isEmpty
                ? _buildEmptyState('NO_OTP_RECORDS')
                : Column(
                    children: otps.take(3).map((otp) => _buildOtpTileFromEntry(otp)).toList(),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsPlaceholder() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('ACCOUNTS', '...', Icons.people)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('ACTIVE', '...', Icons.check_circle, isAccent: true)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('INBOUND', '...', Icons.mail)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('OTP GEN', '...', Icons.lock)),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorCard(String msg) {
    return IndustrialCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Text(msg, style: const TextStyle(color: AppColors.error, fontFamily: 'monospace', fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String label) {
    return IndustrialCard(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontFamily: 'monospace', fontSize: 12, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {bool isAccent = false}) {
    return IndustrialCard(
      isInteractive: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, fontFamily: 'monospace')),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isAccent ? AppColors.accent : AppColors.textMuted.withOpacity(0.3),
                  shape: BoxShape.circle,
                  boxShadow: isAccent ? IndustrialTheme.glowShadow(AppColors.accent) : [],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildOtpTileFromEntry(OtpEntry otp) {
    return OtpTileWidget(otp: otp, isLarge: false);
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildUnifiedInboxTab() {
    final emailsAsync = ref.watch(emailPaginationProvider(EmailFilter(searchQuery: '', accountId: _inboxSelectedAccountId)));
    final accountsAsync = ref.watch(gmailAccountsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildHeader('UNIFIED INBOX'),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildFilterChip('INBX', '...', true),
              const SizedBox(width: 10),
              _buildFilterChip('STRD', '', false),
              const SizedBox(width: 10),
              _buildFilterChip('SENT', '', false),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Filter Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: accountsAsync.when(
            data: (accounts) => _buildAccountDropdown(
              accounts, 
              _inboxSelectedAccountId, 
              (val) => setState(() => _inboxSelectedAccountId = val)
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async => ref.read(emailPaginationProvider(EmailFilter(searchQuery: '', accountId: _inboxSelectedAccountId)).notifier).refresh(),
            child: emailsAsync.isLoading && emailsAsync.items.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : emailsAsync.error != null && emailsAsync.items.isEmpty
                  ? Center(child: _buildErrorCard('INBOX_ERR: ${emailsAsync.error}'))
                  : emailsAsync.items.isEmpty
                      ? Center(child: _buildEmptyState('INBOX_EMPTY'))
                      : ListView.builder(
                          controller: _inboxScrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: emailsAsync.items.length + (emailsAsync.hasMore ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i == emailsAsync.items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                              );
                            }
                            final email = emailsAsync.items[i];
                            final time = '${email.receivedAt.hour.toString().padLeft(2, '0')}:${email.receivedAt.minute.toString().padLeft(2, '0')}';
                            return _buildEmailTile(email.sender, email.subject, time, !email.isRead);
                          },
                        ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String badge, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.chassis,
        borderRadius: BorderRadius.circular(4),
        boxShadow: isSelected ? [
          BoxShadow(color: AppColors.shadowDark, offset: const Offset(2, 2), blurRadius: 4),
          BoxShadow(color: AppColors.shadowHighlight, offset: const Offset(-2, -2), blurRadius: 4),
        ] : IndustrialTheme.shadowCard,
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: isSelected ? AppColors.accent : AppColors.textMuted, fontWeight: FontWeight.w800, fontFamily: 'monospace', fontSize: 12)),
          if (badge.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2)),
              child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildEmailTile(String sender, String subject, String time, bool unread) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: IndustrialCard(
        isInteractive: true,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: unread ? AppColors.accent : AppColors.recessed,
                shape: BoxShape.circle,
                boxShadow: unread ? IndustrialTheme.glowShadow(AppColors.accent) : [],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(sender.toUpperCase(), style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 12, fontFamily: 'monospace', letterSpacing: 1)),
                      Text(time, style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subject,
                    style: TextStyle(color: unread ? AppColors.textPrimary : AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpCenterTab() {
    final otpsAsync = ref.watch(otpPaginationProvider(OtpFilter(searchQuery: _otpSearchQuery, accountId: _otpSelectedAccountId)));
    final accountsAsync = ref.watch(gmailAccountsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader('OTP MODULE'),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.chassis,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadowDark, offset: const Offset(4, 4), blurRadius: 8),
                    BoxShadow(color: AppColors.shadowHighlight, offset: const Offset(-4, -4), blurRadius: 8),
                  ]
                ),
                child: TextField(
                  style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  onChanged: (val) {
                    setState(() {
                      _otpSearchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'SEARCH_KEY...',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Filter Dropdown
              accountsAsync.when(
                data: (accounts) => _buildAccountDropdown(
                  accounts, 
                  _otpSelectedAccountId, 
                  (val) => setState(() => _otpSelectedAccountId = val)
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async => ref.read(otpPaginationProvider(OtpFilter(searchQuery: _otpSearchQuery, accountId: _otpSelectedAccountId)).notifier).refresh(),
            child: otpsAsync.isLoading && otpsAsync.items.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : otpsAsync.error != null && otpsAsync.items.isEmpty
                  ? Center(child: _buildErrorCard('OTP_ERR: ${otpsAsync.error}'))
                  : otpsAsync.items.isEmpty
                      ? Center(child: _buildEmptyState('NO_OTP_CODES_FOUND'))
                      : ListView.builder(
                          controller: _otpScrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: otpsAsync.items.length + (otpsAsync.hasMore ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i == otpsAsync.items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                              );
                            }
                            final otp = otpsAsync.items[i];
                            final time = '${otp.createdAt.hour.toString().padLeft(2, '0')}:${otp.createdAt.minute.toString().padLeft(2, '0')}';
                            final isExpired = otp.expiresAt != null ? DateTime.now().isAfter(otp.expiresAt!) : false;
                            return _buildOtpTile(otp.serviceName, otp.otpCode, time, isExpired ? Icons.warning : Icons.lock);
                          },
                        ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpTile(String name, String code, String time, IconData icon, {bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: IndustrialCard(
        isInteractive: true,
        padding: EdgeInsets.all(isLarge ? 24 : 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.toUpperCase(), style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2, fontFamily: 'monospace')),
                SizedBox(height: isLarge ? 8 : 4),
                Text(
                  code,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: isLarge ? 32 : 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    fontFamily: 'monospace',
                  )
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(time, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                SizedBox(height: isLarge ? 16 : 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.chassis,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: IndustrialTheme.shadowSharp,
                  ),
                  child: const Icon(Icons.copy, color: AppColors.textPrimary, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDropdown(List<Map<String, dynamic>> accounts, String? selectedId, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.chassis,
        borderRadius: BorderRadius.circular(8),
        boxShadow: IndustrialTheme.shadowSharp,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedId,
          isExpanded: true,
          dropdownColor: AppColors.chassis,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
          hint: const Text('ALL_ACCOUNTS', style: TextStyle(color: AppColors.textMuted, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12)),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('ALL_ACCOUNTS', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            ...accounts.map((account) {
              return DropdownMenuItem<String?>(
                value: account['id'] as String,
                child: Text(account['emailAddress'] as String, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12)),
              );
            }).toList(),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  // --- TAB 4: AI COPILOT ---
  Widget _buildAiCopilotTab() {
    return const AiCopilotTab();
  }

  // --- TAB 5: MORE ---
  Widget _buildMoreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildHeader('CONFIGURATION'),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            children: [
              _buildSettingsCard([
                _buildMoreListTile(Icons.campaign, 'CAMPAIGNS', badge: 'NEW'),
                _buildDivider(),
                _buildMoreListTile(Icons.attachment, 'ATTACHMENTS'),
                _buildDivider(),
                _buildMoreListTile(Icons.people, 'TEAM', badge: '5'),
              ]),
              const SizedBox(height: 24),
              _buildSettingsCard([
                _buildMoreListTile(
                  Icons.mail, 
                  'GMAIL_MODULES', 
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GmailAccountsPage()),
                    );
                  }
                ),
                _buildDivider(),
                _buildMoreListTile(Icons.settings, 'SYSTEM_PREFS', onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
                }),
                _buildDivider(),
                _buildMoreListTile(Icons.notifications, 'ALERTS'),
                _buildDivider(),
                _buildMoreListTile(Icons.receipt_long, 'BILLING'),
              ]),
              const SizedBox(height: 24),
              _buildSettingsCard([
                _buildMoreListTile(Icons.help_outline, 'SUPPORT_LOGS'),
                _buildDivider(),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: const Icon(Icons.power_settings_new, color: AppColors.accent),
                  title: const Text('EMERGENCY_STOP', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800, fontFamily: 'monospace', letterSpacing: 1)),
                  onTap: _handleLogout,
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return IndustrialCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: children,
      ),
    );
  }
  
  Widget _buildDivider() {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.shadowHighlight,
        border: const Border(
          top: BorderSide(color: AppColors.borderDark, width: 1),
        )
      ),
    );
  }

  Widget _buildMoreListTile(IconData icon, String title, {String? badge, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontFamily: 'monospace', letterSpacing: 1, fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.chassis,
                borderRadius: BorderRadius.circular(4),
                boxShadow: IndustrialTheme.shadowSharp,
              ),
              child: Text(badge, style: const TextStyle(color: AppColors.accent, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildHeader(String title, {bool showProfile = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontFamily: 'monospace',
          )
        ),
        if (showProfile)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.chassis,
              boxShadow: IndustrialTheme.shadowSharp,
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.chassis,
              child: Icon(Icons.person, color: AppColors.textPrimary, size: 20),
            ),
          ),
      ],
    );
  }
}

class OtpTileWidget extends StatefulWidget {
  final OtpEntry otp;
  final bool isLarge;

  const OtpTileWidget({super.key, required this.otp, required this.isLarge});

  @override
  State<OtpTileWidget> createState() => _OtpTileWidgetState();
}

class _OtpTileWidgetState extends State<OtpTileWidget> {
  Timer? _timer;
  String _countdownText = '';
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    if (!_isExpired && widget.otp.expiresAt != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    if (widget.otp.expiresAt == null) {
      setState(() => _countdownText = _formatTimeAgo(widget.otp.createdAt));
      return;
    }

    final now = DateTime.now();
    final expires = widget.otp.expiresAt!;
    final diff = expires.difference(now);

    if (diff.isNegative) {
      setState(() {
        _isExpired = true;
        _countdownText = 'EXPIRED';
      });
      _timer?.cancel();
    } else {
      final m = diff.inMinutes.toString().padLeft(2, '0');
      final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
      setState(() {
        _countdownText = '$m:$s';
      });
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.otp.otpCode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('OTP Copied to Clipboard!', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _isExpired ? AppColors.textMuted : AppColors.textPrimary;
    final badgeColor = _isExpired ? AppColors.textMuted : AppColors.accent;

    return Padding(
      padding: EdgeInsets.only(bottom: widget.isLarge ? 16 : 12),
      child: IndustrialCard(
        isInteractive: !_isExpired,
        padding: EdgeInsets.all(widget.isLarge ? 24 : 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otp.serviceName.toUpperCase(), style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2, fontFamily: 'monospace')),
                SizedBox(height: widget.isLarge ? 8 : 4),
                Text(
                  widget.otp.otpCode, 
                  style: TextStyle(
                    color: textColor, 
                    fontSize: widget.isLarge ? 32 : 20, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 4, 
                    fontFamily: 'monospace',
                    decoration: _isExpired ? TextDecoration.lineThrough : null,
                  )
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isExpired && widget.otp.expiresAt != null) 
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: badgeColor,
                          shape: BoxShape.circle,
                          boxShadow: IndustrialTheme.glowShadow(badgeColor),
                        ),
                      ),
                    Text(
                      _countdownText, 
                      style: TextStyle(
                        color: _isExpired ? AppColors.error : AppColors.textMuted, 
                        fontSize: widget.isLarge ? 12 : 11, 
                        fontFamily: 'monospace',
                        fontWeight: _isExpired ? FontWeight.bold : FontWeight.normal,
                      )
                    ),
                  ],
                ),
                SizedBox(height: widget.isLarge ? 16 : 8),
                InkWell(
                  onTap: _isExpired ? null : _handleCopy,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: EdgeInsets.all(widget.isLarge ? 8 : 6),
                    decoration: BoxDecoration(
                      color: AppColors.chassis, 
                      borderRadius: BorderRadius.circular(4), 
                      boxShadow: IndustrialTheme.shadowSharp
                    ),
                    child: Icon(Icons.copy, color: textColor, size: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

