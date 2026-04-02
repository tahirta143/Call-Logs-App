import 'package:flutter/material.dart';
import '../compoents/responsive_helper.dart';

class AppButton extends StatelessWidget {
  final String title;
  final Function() press;
  final double? width;
  
  const AppButton({
    super.key,
    required this.title,
    required this.press,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: press,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: context.sh(0.07), // 7% of screen height
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
