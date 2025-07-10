import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/form_validators.dart';

/// Enhanced custom input field with improved functionality and validation
class CustomInputField extends StatelessWidget {
  final IconData? icon;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextEditingController controller;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;
  final String? suffixText;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const CustomInputField({
    super.key,
    this.icon,
    this.hintText,
    this.labelText,
    required this.controller,
    this.obscureText = false,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    this.suffixText,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onEditingComplete,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B2027), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }
}

/// Specialized input field for email
class EmailInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final bool enabled;

  const EmailInputField({
    super.key,
    required this.controller,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      controller: controller,
      labelText: 'Email',
      hintText: 'Enter your email address',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: FormValidators.validateEmail,
      errorText: errorText,
      enabled: enabled,
    );
  }
}

/// Specialized input field for password
class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool enabled;
  final bool requireValidation;

  const PasswordInputField({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.hintText = 'Enter your password',
    this.errorText,
    this.enabled = true,
    this.requireValidation = true,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      controller: widget.controller,
      labelText: widget.labelText,
      hintText: widget.hintText,
      icon: Icons.lock_outlined,
      obscureText: _obscureText,
      validator:
          widget.requireValidation ? FormValidators.validatePassword : null,
      errorText: widget.errorText,
      enabled: widget.enabled,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}

/// Specialized input field for numeric values (weight, reps, etc.)
class NumericInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? suffixText;
  final String? errorText;
  final double? min;
  final double? max;
  final bool allowDecimals;
  final bool enabled;

  const NumericInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.suffixText,
    this.errorText,
    this.min,
    this.max,
    this.allowDecimals = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      controller: controller,
      labelText: labelText,
      hintText: hintText ?? 'Enter $labelText',
      keyboardType: allowDecimals
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: allowDecimals
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : [FilteringTextInputFormatter.digitsOnly],
      validator: (value) => FormValidators.validateNumeric(
        value,
        labelText,
        min: min,
        max: max,
      ),
      suffixText: suffixText,
      errorText: errorText,
      enabled: enabled,
    );
  }
}

/// Specialized input field for required text fields
class RequiredTextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? icon;
  final String? errorText;
  final bool enabled;
  final int? maxLength;

  const RequiredTextInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.icon,
    this.errorText,
    this.enabled = true,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      controller: controller,
      labelText: labelText,
      hintText: hintText ?? 'Enter $labelText',
      icon: icon,
      validator: (value) => FormValidators.validateRequired(value, labelText),
      errorText: errorText,
      enabled: enabled,
      maxLength: maxLength,
    );
  }
}
