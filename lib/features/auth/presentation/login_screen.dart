import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/features/auth/providers/auth_provider.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';
import 'package:sw1_p1/shared/widgets/animated_background.dart';
import 'package:sw1_p1/shared/widgets/custom_filled_button.dart';
import 'package:sw1_p1/shared/widgets/custom_input_field.dart';
import 'package:sw1_p1/shared/widgets/modern_toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passwordCtrl.text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final res = context.responsive;

    // Escuchar cambios de auth para navegar o mostrar error
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/home');
      } else if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        showModernToast(
          context,
          message: next.errorMessage!,
          type: ToastType.error,
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.checking;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: AnimatedBackground(
          style: BackgroundStyle.aurora,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: res.spacing(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: res.hp(8)),
                  _buildHeader(context, res),
                  SizedBox(height: res.spacing(40)),
                  _buildForm(context, res, isLoading),
                  SizedBox(height: res.hp(4)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Responsive res) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/images/workflow-ai-banner.png', width: res.wp(60))
            .animate()
            .fadeIn(delay: 100.ms, duration: 500.ms)
            .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1.0, 1.0),
              curve: Curves.elasticOut,
            ),
        SizedBox(height: res.spacing(16)),
        Text(
          'Inicia sesión para continuar',
          style: TextStyle(fontSize: res.fontSize(14), color: AppTheme.grey1),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildForm(BuildContext context, Responsive res, bool isLoading) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===== Card =====
          Container(
                padding: EdgeInsets.all(res.spacing(24)),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.08,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomInputField(
                      label: 'Correo electrónico',
                      hint: 'ejemplo@correo.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa tu correo';
                        }
                        if (!RegExp(
                          r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$',
                        ).hasMatch(v.trim())) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 400.ms, duration: 350.ms),
                    SizedBox(height: res.spacing(14)),
                    CustomInputField(
                      label: 'Contraseña',
                      hint: '••••••••',
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.grey1,
                          size: res.iconSize(18),
                        ),
                        onPressed:
                            () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresa tu contraseña';
                        }
                        if (v.length < 4) return 'Contraseña muy corta';
                        return null;
                      },
                    ).animate().fadeIn(delay: 480.ms, duration: 350.ms),
                    SizedBox(height: res.spacing(24)),
                    CustomFilledButton(
                      text: 'Iniciar sesión',
                      onPressed: isLoading ? null : _handleLogin,
                      isLoading: isLoading,
                      icon: isLoading ? null : Icons.arrow_forward_rounded,
                    ).animate().fadeIn(delay: 560.ms, duration: 350.ms),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.fastOutSlowIn),
        ],
      ),
    );
  }
}
