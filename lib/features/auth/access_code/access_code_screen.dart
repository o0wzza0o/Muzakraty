import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/animated_background.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event_state.dart' as app_auth;

class AccessCodeScreen extends StatefulWidget {
  const AccessCodeScreen({super.key});

  @override
  State<AccessCodeScreen> createState() => _AccessCodeScreenState();
}

class _AccessCodeScreenState extends State<AccessCodeScreen>
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  late AnimationController _animController;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _submit() {
    // Access code verification removed - now handled directly in OTP flow
    // Navigate to onboarding or home based on auth state
    final state = context.read<AuthBloc>().state;
    if (state is app_auth.AuthenticatedNeedsOnboarding) {
      context.push('/onboarding');
    } else if (state is app_auth.Authenticated) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, app_auth.AuthState>(
      listener: (context, state) {
        if (state is app_auth.AuthenticatedNeedsOnboarding) {
          context.push('/onboarding');
        } else if (state is app_auth.Authenticated) {
          context.go('/home');
        } else if (state is app_auth.AuthError) {
          setState(() => _showError = true);
          _animController.reverse().then((_) => _animController.forward());
        }
      },
      child: Scaffold(
        body: AnimatedBackground(
          child: SafeArea(
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(_animController),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                      ),
                    ),
                    const Spacer(),
                    // Lock icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 56,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'جاري تسجيل الدخول...',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الرجاء الانتظار',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Show loading indicator
                    const CircularProgressIndicator(),
                    // Code input
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      obscureText: true,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 12,
                        color: AppColors.textPrimary,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(
                        hintText: '• • • •',
                        hintStyle: TextStyle(
                          color: AppColors.textHint.withValues(alpha: 0.3),
                          fontSize: 28,
                          letterSpacing: 12,
                        ),
                        errorText: _showError ? AppStrings.wrongAccessCode : null,
                        errorStyle: const TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                      onChanged: (_) {
                        if (_showError) setState(() => _showError = false);
                      },
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthBloc, app_auth.AuthState>(
                      builder: (context, state) {
                        return GradientButton(
                          text: AppStrings.continueText,
                          isLoading: state is app_auth.AuthLoading,
                          onPressed: _submit,
                        );
                      },
                    ),
                    const Spacer(flex: 2),
                    // Back button
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('رجوع'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
