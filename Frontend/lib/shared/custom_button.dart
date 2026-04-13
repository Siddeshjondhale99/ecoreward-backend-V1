import 'package:flutter/material.dart';
import '../core/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isSecondary ? null : AppTheme.primaryGradient,
        color: isSecondary ? Colors.white.withOpacity(0.1) : null,
        boxShadow: isSecondary ? [] : [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading 
                ? const SizedBox(
                    height: 24, 
                    width: 24, 
                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)
                  ) 
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
