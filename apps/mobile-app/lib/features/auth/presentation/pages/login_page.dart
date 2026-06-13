import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/industrial_theme.dart';
import '../../../../core/components/industrial_card.dart';
import '../../data/auth_repository.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@audira.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;
  
  // State for MFA
  bool _mfaRequired = false;
  String? _tempToken;
  final TextEditingController _otpController = TextEditingController();

  late AnimationController _glitchController;

  @override
  void initState() {
    super.initState();
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _glitchController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    _glitchController.forward().then((_) => _glitchController.reverse());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SYS_ERR: $message', style: const TextStyle(fontFamily: 'monospace', color: AppColors.error, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.chassis,
        shape: RoundedRectangleBorder(side: const BorderSide(color: AppColors.error), borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      _showError('CREDENTIALS_REQUIRED');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final result = await authRepo.login(email, password);
      
      if (result['mfaRequired'] == true) {
        setState(() {
          _mfaRequired = true;
          _tempToken = result['tempToken'];
        });
      } else {
        _navigateToDashboard();
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleOtpVerification() async {
    final code = _otpController.text.trim();
    if (code.length != 6 || _tempToken == null) {
      _showError('INVALID_OTP_FORMAT');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.verifyOtp(_tempToken!, code);
      _navigateToDashboard();
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const DashboardPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chassis,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Noise Overlay (simulating plastic/metal texture)
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Industrial Logo
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.chassis,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: IndustrialTheme.shadowFloating,
                          border: Border.all(color: AppColors.borderDark, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            'A\\OS',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              letterSpacing: 2,
                              shadows: IndustrialTheme.glowShadow(AppColors.accent),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Title Terminal
                    AnimatedBuilder(
                      animation: _glitchController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_glitchController.value * 10 * (_glitchController.value > 0.5 ? -1 : 1), 0),
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            _mfaRequired ? 'SYSTEM_OVERRIDE_MFA' : 'AUTHENTICATION_REQUIRED',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _mfaRequired 
                              ? 'AWAITING_6_DIGIT_AUTH_TOKEN' 
                              : 'PLEASE_INPUT_CREDENTIALS',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    if (_mfaRequired) _buildOtpForm() else _buildLoginForm(),
                    
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputLabel('IDENTIFIER [EMAIL]'),
        const SizedBox(height: 8),
        _buildIndustrialTextField(
          controller: _emailController,
          hint: 'user@host.com',
          icon: Icons.terminal,
          keyboardType: TextInputType.emailAddress,
        ),
        
        const SizedBox(height: 24),
        
        _buildInputLabel('ACCESS_KEY [PASS]'),
        const SizedBox(height: 8),
        _buildIndustrialTextField(
          controller: _passwordController,
          hint: '••••••••',
          icon: Icons.lock,
          obscureText: true,
        ),
        
        const SizedBox(height: 48),
        
        _buildIndustrialButton(
          onPressed: _isLoading ? null : _handleLogin,
          label: 'INITIATE_HANDSHAKE',
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputLabel('MFA_TOKEN'),
        const SizedBox(height: 8),
        _buildIndustrialTextField(
          controller: _otpController,
          hint: '------',
          icon: Icons.security,
          keyboardType: TextInputType.number,
          maxLength: 6,
          isCenter: true,
        ),
        
        const SizedBox(height: 48),
        
        _buildIndustrialButton(
          onPressed: _isLoading ? null : _handleOtpVerification,
          label: 'VERIFY_TOKEN',
          isLoading: _isLoading,
        ),
        
        const SizedBox(height: 24),
        
        GestureDetector(
          onTap: () {
            setState(() {
              _mfaRequired = false;
              _tempToken = null;
            });
          },
          child: const Center(
            child: Text(
              '<< ABORT_MFA',
              style: TextStyle(
                color: AppColors.textMuted,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        fontFamily: 'monospace',
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildIndustrialTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLength,
    bool isCenter = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.chassis,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowDark, offset: Offset(4, 4), blurRadius: 8),
          BoxShadow(color: AppColors.shadowHighlight, offset: Offset(-4, -4), blurRadius: 8),
        ]
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        textAlign: isCenter ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: isCenter ? 24 : 14,
          letterSpacing: isCenter ? 12 : 2,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
        ),
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          hintStyle: TextStyle(
            color: AppColors.textMuted.withOpacity(0.5),
            fontSize: isCenter ? 24 : 14,
            letterSpacing: isCenter ? 12 : 2,
          ),
          prefixIcon: isCenter ? null : Icon(icon, color: AppColors.textMuted, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
  
  Widget _buildIndustrialButton({
    required VoidCallback? onPressed,
    required String label,
    required bool isLoading,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.chassis,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isLoading ? AppColors.textMuted : AppColors.accent, width: 2),
          boxShadow: onPressed == null 
            ? [] 
            : [
                BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
              ],
        ),
        child: Center(
          child: isLoading 
            ? const SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(color: AppColors.textMuted, strokeWidth: 2)
              )
            : Text(
                label,
                style: TextStyle(
                  color: isLoading ? AppColors.textMuted : AppColors.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  fontFamily: 'monospace',
                ),
              ),
        ),
      ),
    );
  }
}
