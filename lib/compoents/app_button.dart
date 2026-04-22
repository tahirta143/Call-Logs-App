import 'package:flutter/material.dart';
import '../compoents/app_theme.dart';
import '../compoents/responsive_helper.dart';

class AppButton extends StatelessWidget {
  final String title;
  final String? text; // Alias for title
  final Function() press;
  final Function()? onPressed; // Alias for press
  final double? width;
  
  const AppButton({
    super.key,
    this.title = '',
    this.text,
    Function()? press,
    this.onPressed,
    this.width,
  }) : press = press ?? onPressed ?? _emptyAction;

  static void _emptyAction() {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonTitle = text ?? title;
    
    return InkWell(
      onTap: press,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: context.sh(0.07), // 7% of screen height
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            buttonTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
