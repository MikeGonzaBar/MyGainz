import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final IconData? icon;
  final String hintText;
  final bool obscure;
  final TextEditingController controller;
  final String? errorText;

  const CustomInputField({
    super.key,
    this.icon,
    required this.hintText,
    required this.controller,
    this.obscure = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFFFFFFF),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(),
        decoration: InputDecoration(
          errorText: errorText,
          hintText: icon != null ? hintText : null,
          labelText: icon == null ? hintText : null,
          hintStyle: const TextStyle(),
          prefixIcon: icon != null ? Icon(icon) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
