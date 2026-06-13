import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../dashboard_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/industrial_theme.dart';
import '../../../../core/components/industrial_card.dart';
import '../../../../core/network/api_client.dart';

// Provider moved to dashboard_provider.dart

class GmailAccountsPage extends ConsumerStatefulWidget {
  const GmailAccountsPage({super.key});

  @override
  ConsumerState<GmailAccountsPage> createState() => _GmailAccountsPageState();
}

class _GmailAccountsPageState extends ConsumerState<GmailAccountsPage> {
  bool _isConnecting = false;
  String? _statusMessage;
  final Set<String> _selectedAccounts = {};

  Future<void> _connectGmail() async {
    setState(() {
      _isConnecting = true;
      _statusMessage = 'FETCHING_AUTH_URL...';
    });

    try {
      final data = await ApiClient().get('/gmail/auth/url');
      final String oauthUrl = data['url'] as String;

      setState(() => _statusMessage = 'OPENING_BROWSER...');

      final uri = Uri.parse(oauthUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        setState(() => _statusMessage = 'AWAITING_GOOGLE_AUTH...\nComplete login in browser, then return here.');
      } else {
        setState(() {
          _statusMessage = 'ERR: Cannot open browser.';
          _isConnecting = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'ERR: ${e.toString()}';
        _isConnecting = false;
      });
    }
  }

  Future<void> _syncAccount(String accountId) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.chassis,
        content: Text('SYNCING...', style: TextStyle(color: AppColors.accent, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
      ),
    );
    try {
      final result = await ApiClient().get('/gmail/sync?accountId=$accountId');
      if (!mounted) return;
      ref.invalidate(gmailAccountsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.chassis,
          content: Text(
            'SYNC_OK: ${result['synced']} emails, ${result['otpsExtracted']} OTP',
            style: const TextStyle(color: AppColors.success, fontFamily: 'monospace', fontWeight: FontWeight.bold),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.chassis,
          content: Text('SYNC_ERR: $e', style: const TextStyle(color: AppColors.error, fontFamily: 'monospace')),
        ),
      );
    }
  }

  Future<void> _bulkAction(String action) async {
    if (_selectedAccounts.isEmpty) return;
    
    final accountIds = _selectedAccounts.join(',');
    final endpoint = action == 'sync' ? '/gmail/bulk-sync' : '/gmail/bulk-delete';
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.chassis,
        content: Text('EXECUTING BULK ${action.toUpperCase()}...', style: const TextStyle(color: AppColors.accent, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
      ),
    );
    
    try {
      await ApiClient().get('$endpoint?accountIds=$accountIds');
      if (!mounted) return;
      ref.invalidate(gmailAccountsProvider);
      setState(() {
        _selectedAccounts.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.chassis,
          content: Text(
            'BULK ${action.toUpperCase()} COMPLETE',
            style: const TextStyle(color: AppColors.success, fontFamily: 'monospace', fontWeight: FontWeight.bold),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.chassis,
          content: Text('BULK_ERR: $e', style: const TextStyle(color: AppColors.error, fontFamily: 'monospace')),
        ),
      );
    }
  }

  Future<void> _updateTags(String accountId, String currentTags) async {
    final controller = TextEditingController(text: currentTags);
    final newTags = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.chassis,
        title: const Text('EDIT_TAGS', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace')),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace'),
          decoration: const InputDecoration(
            hintText: 'Comma separated tags (e.g. WORK, PERSONAL)',
            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textMuted)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('SAVE', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (newTags != null && newTags != currentTags) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: AppColors.chassis,
        content: Text('UPDATING_TAGS...', style: TextStyle(color: AppColors.accent, fontFamily: 'monospace')),
      ));
      
      try {
        await ApiClient().get('/gmail/update-tags?accountId=$accountId&tags=${Uri.encodeComponent(newTags)}');
        if (!mounted) return;
        ref.invalidate(gmailAccountsProvider);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.chassis,
          content: Text('UPDATE_ERR: $e', style: const TextStyle(color: AppColors.error, fontFamily: 'monospace')),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(gmailAccountsProvider);

    return Scaffold(
      backgroundColor: AppColors.chassis,
      appBar: AppBar(
        backgroundColor: AppColors.chassis,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.chassis,
              shape: BoxShape.circle,
              boxShadow: IndustrialTheme.shadowSharp,
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
          ),
        ),
        title: const Text(
          'GMAIL_ACCOUNTS',
          style: TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16),
        ),
        actions: [
          GestureDetector(
            onTap: () => ref.invalidate(gmailAccountsProvider),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.chassis,
                shape: BoxShape.circle,
                boxShadow: IndustrialTheme.shadowSharp,
              ),
              child: const Icon(Icons.refresh, color: AppColors.textPrimary, size: 20),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connect new account button
            _buildConnectButton(),

            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              _buildStatusBanner(),
            ],

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CONNECTED_MODULES',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2, fontFamily: 'monospace'),
                ),
                if (_selectedAccounts.isNotEmpty)
                  Text(
                    '${_selectedAccounts.length} SELECTED',
                    style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Accounts list
            Expanded(
              child: accountsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                error: (e, _) => Center(
                  child: IndustrialCard(
                    padding: const EdgeInsets.all(20),
                    child: Text('ERR: $e', style: const TextStyle(color: AppColors.error, fontFamily: 'monospace')),
                  ),
                ),
                data: (accounts) => accounts.isEmpty
                  ? _buildEmptyAccounts()
                  : ListView.builder(
                      itemCount: accounts.length,
                      itemBuilder: (context, i) => _buildAccountCard(accounts[i]),
                    ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedAccounts.isNotEmpty
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'bulk_sync',
                backgroundColor: AppColors.chassis,
                onPressed: () => _bulkAction('sync'),
                child: const Icon(Icons.sync, color: AppColors.accent),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: 'bulk_delete',
                backgroundColor: AppColors.error,
                onPressed: () => _bulkAction('delete'),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
            ],
          )
        : null,
    );
  }

  Widget _buildConnectButton() {
    return GestureDetector(
      onTap: _isConnecting ? null : _connectGmail,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.chassis,
          borderRadius: IndustrialTheme.radiusLg,
          boxShadow: _isConnecting ? [] : IndustrialTheme.shadowFloating,
          border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isConnecting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
              )
            else
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppColors.accent, size: 20),
              ),
            const SizedBox(width: 12),
            Text(
              _isConnecting ? 'CONNECTING...' : 'CONNECT_GMAIL_ACCOUNT',
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return IndustrialCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              boxShadow: IndustrialTheme.glowShadow(AppColors.accent),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage!,
              style: const TextStyle(color: AppColors.textMuted, fontFamily: 'monospace', fontSize: 11, height: 1.5),
            ),
          ),
          if (_isConnecting)
            TextButton(
              onPressed: () => setState(() {
                _isConnecting = false;
                _statusMessage = null;
                ref.invalidate(gmailAccountsProvider);
              }),
              child: const Text('DONE', style: TextStyle(color: AppColors.accent, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    final status = account['status'] as String? ?? 'unknown';
    final isConnected = status == 'connected';
    final email = account['emailAddress'] as String? ?? '';
    final lastSync = account['lastSync'] as String?;
    final accountId = account['id'] as String;
    final tags = account['tags'] as String? ?? '';
    final isSelected = _selectedAccounts.contains(accountId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onLongPress: () {
          setState(() {
            if (isSelected) {
              _selectedAccounts.remove(accountId);
            } else {
              _selectedAccounts.add(accountId);
            }
          });
        },
        child: IndustrialCard(
          isInteractive: true,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedAccounts.add(accountId);
                        } else {
                          _selectedAccounts.remove(accountId);
                        }
                      });
                    },
                    activeColor: AppColors.accent,
                    checkColor: AppColors.chassis,
                    side: const BorderSide(color: AppColors.textMuted),
                  ),
                  Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isConnected ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: IndustrialTheme.glowShadow(isConnected ? AppColors.success : AppColors.error),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontFamily: 'monospace', fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'STATUS: ${status.toUpperCase()}',
                            style: TextStyle(
                              color: isConnected ? AppColors.success : AppColors.error,
                              fontSize: 10,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (tags.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tags.toUpperCase(),
                                style: const TextStyle(color: AppColors.accent, fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.label_outline, color: AppColors.textMuted, size: 20),
                  onPressed: () => _updateTags(accountId, tags),
                ),
              ],
            ),
            if (lastSync != null) ...[
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: AppColors.shadowDark,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LAST_SYNC: ${_formatDate(lastSync)}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'monospace'),
                  ),
                  GestureDetector(
                    onTap: () => _syncAccount(accountId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.chassis,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: IndustrialTheme.shadowSharp,
                      ),
                      child: const Text(
                        'SYNC_NOW',
                        style: TextStyle(color: AppColors.accent, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildEmptyAccounts() {
    return Center(
      child: IndustrialCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.chassis,
                shape: BoxShape.circle,
                boxShadow: IndustrialTheme.shadowSharp,
              ),
              child: const Icon(Icons.inbox, color: AppColors.textMuted, size: 32),
            ),
            const SizedBox(height: 20),
            const Text('NO_MODULES_CONNECTED', style: TextStyle(color: AppColors.textMuted, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 8),
            const Text('Connect a Gmail account above\nto start syncing emails & OTP.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) {
      return isoDate;
    }
  }
}
