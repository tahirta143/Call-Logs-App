import 'package:flutter/material.dart';
import '../compoents/responsive_helper.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final IconData? icon;
  final IconData? prefixIcon; // Alias for icon
  final IconData? icons;
  final VoidCallback? onToggleVisibility;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Function(String)? onChanged;
  final bool readOnly;
  final bool filled;
  final int? maxLines;
  final VoidCallback? onTap;

  final bool isRequired;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.icon,
    this.prefixIcon,
    this.icons,
    this.onToggleVisibility,
    this.validator,
    this.obscureText = false,
    this.onChanged,
    this.readOnly = false,
    this.filled = true,
    this.maxLines = 1,
    this.isRequired = false,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIcon = widget.prefixIcon ?? widget.icon;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: context.sh(0.01)),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        validator: widget.validator,
        onChanged: widget.onChanged,
        readOnly: widget.readOnly,
        maxLines: widget.maxLines,
        onTap: widget.onTap,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          label: widget.isRequired 
            ? RichText(
                text: TextSpan(
                  text: widget.label,
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
                  children: const [
                    TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            : Text(widget.label, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 14)),
          hintText: widget.label,
          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          prefixIcon: effectiveIcon != null 
              ? Icon(effectiveIcon, color: theme.colorScheme.primary) 
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
          filled: widget.filled,
          fillColor: theme.inputDecorationTheme.fillColor,
          border: theme.inputDecorationTheme.border,
          enabledBorder: theme.inputDecorationTheme.enabledBorder,
          focusedBorder: theme.inputDecorationTheme.focusedBorder,
        ),
      ),
    );
  }
}
