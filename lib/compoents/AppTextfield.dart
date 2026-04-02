import 'package:flutter/material.dart';
import '../compoents/responsive_helper.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final IconData? icon;
  final IconData? icons;
  final VoidCallback? onToggleVisibility;
  final String? Function(String?)? validator;
  final bool obscureText;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.icon,
    this.icons,
    this.onToggleVisibility,
    this.validator,
    this.obscureText = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: context.sh(0.01)),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        validator: widget.validator,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: widget.label,
          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
          prefixIcon: widget.icon != null 
              ? Icon(widget.icon, color: theme.colorScheme.primary) 
              : null,
          suffixIcon: widget.icons != null
              ? IconButton(
                  onPressed: widget.onToggleVisibility,
                  icon: Icon(widget.icons, color: theme.colorScheme.primary),
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.sw(0.04),
            vertical: context.sh(0.02),
          ),
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
          border: theme.inputDecorationTheme.border,
          enabledBorder: theme.inputDecorationTheme.enabledBorder,
          focusedBorder: theme.inputDecorationTheme.focusedBorder,
        ),
      ),
    );
  }
}
