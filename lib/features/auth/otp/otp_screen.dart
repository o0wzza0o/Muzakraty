import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/animated_background.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event_state.dart' as app_auth;

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  late AnimationController _animController;
  Timer? _timer;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _startTimer();
  }

  void _startTimer() {
    _countdown = 60;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _verify() {
    if (_otp.length == 6) {
      context.read<AuthBloc>().add(app_auth.VerifyOtpRequested(_otp));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, app_auth.AuthState>(
      listener: (context, state) {
        if (state is app_auth.AuthenticatedNeedsOnboarding) {
          // User needs to complete onboarding
          context.push('/onboarding');
        } else if (state is app_auth.Authenticated) {
          // User is fully authenticated, go to home
          context.go('/home');
        } else if (state is app_auth.AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
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
                    // Back button
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                      ),
                    ),
                    const Spacer(),
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.15),
                      ),
                      child: const Icon(
                        Icons.message_rounded,
                        size: 50,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.otpTitle,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${AppStrings.otpSubtitle}\n${widget.phoneNumber}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // OTP Fields
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (i) {
                          return SizedBox(
                            width: 48,
                            height: 56,
                            child: TextFormField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.accent,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceLight,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && i < 5) {
                                  _focusNodes[i + 1].requestFocus();
                                }
                                if (value.isEmpty && i > 0) {
                                  _focusNodes[i - 1].requestFocus();
                                }
                                if (_otp.length == 6) _verify();
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Resend timer
                    _canResend
                        ? TextButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                app_auth.SendOtpRequested(widget.phoneNumber),
                              );
                              _startTimer();
                            },
                            child: Text(
                              AppStrings.resendOtp,
                              style: TextStyle(color: AppColors.accent),
                            ),
                          )
                        : Text(
                            'إعادة الإرسال خلال $_countdown ثانية',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthBloc, app_auth.AuthState>(
                      builder: (context, state) {
                        return GradientButton(
                          text: AppStrings.verify,
                          isLoading: state is app_auth.AuthLoading,
                          onPressed: _verify,
                        );
                      },
                    ),
                    const Spacer(flex: 2),
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
