import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

/// No navigation logic here at all.
/// GoRouter's refreshListenable handles redirect when auth changes.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isWide = width > 600;

    final hPad = isWide ? width * 0.25 : width * 0.07;
    final logoSize = isWide ? 56.0 : 48.0;
    final titleSize = isWide ? 32.0 : 26.0;
    final bodySize = isWide ? 15.0 : 13.0;
    final pillSize = isWide ? 13.0 : 11.5;
    final btnHeight = isWide ? 54.0 : 50.0;
    final btnFSize = isWide ? 15.0 : 14.0;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, s) => s is AuthError,
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5FCF8),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.07),
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'SE',
                          style: TextStyle(
                            fontSize: logoSize * 0.38,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.035),
                    Text(
                      'Split expenses\nwith ease.',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.neutral900,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: size.height * 0.012),
                    Text(
                      'Track group expenses, settle up fairly,\nand stop the mental math.',
                      style: TextStyle(
                        fontSize: bodySize,
                        color: AppTheme.neutral500,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(
                            icon: Icons.group,
                            label: 'Group Splits',
                            fontSize: pillSize),
                        _Pill(
                            icon: Icons.auto_awesome,
                            label: 'Debt Simplify',
                            fontSize: pillSize),
                        _Pill(
                            icon: Icons.receipt_long,
                            label: 'Track Expenses',
                            fontSize: pillSize),
                        _Pill(
                            icon: Icons.notifications,
                            label: 'Reminders',
                            fontSize: pillSize),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(height: size.height * 0.04),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) => _GoogleButton(
                        loading: state is AuthLoading,
                        onTap: () => context
                            .read<AuthBloc>()
                            .add(GoogleSignInRequested()),
                        height: btnHeight,
                        fontSize: btnFSize,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'By continuing, you agree to our Terms & Privacy Policy.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 11, color: AppTheme.neutral400),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
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

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final double fontSize;
  const _Pill(
      {required this.icon, required this.label, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: AppTheme.primaryBlue),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutral700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  final double height;
  final double fontSize;
  const _GoogleButton({
    required this.loading,
    required this.onTap,
    required this.height,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: loading ? AppTheme.neutral100 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.neutral200, width: 1.5),
          boxShadow: loading
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _GoogleLogo(),
                  const SizedBox(width: 10),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.neutral800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(painter: _GLogoPainter()),
      );
}

class _GLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final p = Paint()..style = PaintingStyle.fill;
    p.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -0.52, 3.14, true, p);
    p.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), 0.52, 1.57, true, p);
    p.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), 2.09, 1.57, true, p);
    p.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), 3.66, 0.87, true, p);
    p.color = Colors.white;
    canvas.drawCircle(c, r * 0.6, p);
  }

  @override
  bool shouldRepaint(_) => false;
}
