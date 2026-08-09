import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_error.dart';
import '../providers/auth_provider.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String email;

  const OtpVerificationPage({super.key, required this.email});

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage>
    with TickerProviderStateMixin {
  static const int _otpLength = 6;
  static const int _resendCooldown = 60; // seconds
  static const int _otpExpiry = 10 * 60; // 10 min in seconds

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _successController;
  late Animation<double> _successScale;

  Timer? _resendTimer;
  Timer? _expiryTimer;
  int _resendSeconds = _resendCooldown;
  int _expirySeconds = _otpExpiry;
  bool _canResend = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _startResendTimer();
    _startExpiryTimer();
  }

  void _startResendTimer() {
    _resendSeconds = _resendCooldown;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  void _startExpiryTimer() {
    _expirySeconds = _otpExpiry;
    _expiryTimer?.cancel();
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _expirySeconds--;
        if (_expirySeconds <= 0) {
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _shakeController.dispose();
    _successController.dispose();
    _resendTimer?.cancel();
    _expiryTimer?.cancel();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < _otpLength) return;

    setState(() {
      _hasError = false;
      _errorMessage = '';
    });

    await ref.read(authProvider.notifier).verifyOtp(
          email: widget.email,
          otp: _otp,
        );

    if (!mounted) return;

    final state = ref.read(authProvider);
    state.whenOrNull(
      data: (user) {
        if (user != null) {
          _successController.forward();
          Future.delayed(const Duration(milliseconds: 700), () {
            if (mounted) context.go('/home');
          });
        }
      },
      error: (e, _) {
        _shakeController.forward(from: 0);
        setState(() {
          _hasError = true;
          _errorMessage = AppError.parse(e);
          // Clear boxes on error
          for (final c in _controllers) {
            c.clear();
          }
          _focusNodes.first.requestFocus();
        });
      },
    );
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    await ref.read(authProvider.notifier).resendOtp(email: widget.email);
    if (!mounted) return;
    _startResendTimer();
    _startExpiryTimer();
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('New OTP sent to your email!'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }


  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _onDigitInput(String value, int index) {
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verify();
      }
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final isExpired = _expirySeconds <= 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1d4ed8), Color(0xFF7c3aed)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Icon
                        AnimatedBuilder(
                          animation: _successScale,
                          builder: (_, child) => Transform.scale(
                            scale: authState.hasValue &&
                                    authState.value != null
                                ? _successScale.value
                                : 1.0,
                            child: child,
                          ),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.30),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              authState.hasValue && authState.value != null
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.mark_email_unread_outlined,
                              size: 46,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Verify your email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'We sent a 6-digit code to',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          widget.email,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // White card
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // OTP boxes with shake animation
                              AnimatedBuilder(
                                animation: _shakeAnimation,
                                builder: (_, child) {
                                  final offset = _hasError
                                      ? 10 *
                                          (0.5 -
                                              (_shakeAnimation.value - 0.5)
                                                  .abs())
                                      : 0.0;
                                  return Transform.translate(
                                    offset: Offset(offset, 0),
                                    child: child,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    _otpLength,
                                    (i) => _OtpBox(
                                      controller: _controllers[i],
                                      focusNode: _focusNodes[i],
                                      hasError: _hasError,
                                      onChanged: (v) => _onDigitInput(v, i),
                                      onBackspace: () => _onBackspace(i),
                                    ),
                                  ),
                                ),
                              ),

                              // Error message
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                child: _hasError
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 14),
                                        child: Row(
                                          children: [
                                            Icon(Icons.error_outline,
                                                color: Colors.red.shade400,
                                                size: 16),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                _errorMessage,
                                                style: TextStyle(
                                                  color: Colors.red.shade400,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),

                              const SizedBox(height: 24),

                              // Verify button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading || isExpired
                                      ? null
                                      : _verify,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1d4ed8),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        Colors.grey.shade200,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Verify & Continue',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Expiry timer
                              if (!isExpired)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.timer_outlined,
                                        size: 15,
                                        color: _expirySeconds < 60
                                            ? Colors.red.shade400
                                            : Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Code expires in ${_formatTime(_expirySeconds)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _expirySeconds < 60
                                            ? Colors.red.shade400
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  'Code has expired',
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                              const SizedBox(height: 14),

                              // Resend button
                              GestureDetector(
                                onTap: _canResend ? _resend : null,
                                child: RichText(
                                  text: TextSpan(
                                    text: "Didn't receive the code? ",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _canResend
                                            ? 'Resend'
                                            : 'Resend in ${_resendSeconds}s',
                                        style: TextStyle(
                                          color: _canResend
                                              ? const Color(0xFF1d4ed8)
                                              : Colors.grey.shade400,
                                          fontWeight: FontWeight.w700,
                                          decoration: _canResend
                                              ? TextDecoration.underline
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Individual OTP digit box ──────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: hasError
              ? Colors.red.withValues(alpha: 0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasError
                ? Colors.red.shade300
                : focusNode.hasFocus
                    ? const Color(0xFF1d4ed8)
                    : Colors.grey.shade300,
            width: focusNode.hasFocus ? 2 : 1.5,
          ),
        ),
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              onBackspace();
            }
          },
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1e293b),
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
