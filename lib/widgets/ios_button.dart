import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../constants/colors.dart';

class IOSButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFilled;
  final Color? backgroundColor;
  final Color? textColor;

  const IOSButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFilled = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isFilled
              ? null
              : Border.all(
                  color: backgroundColor ?? AppColors.primary,
                  width: 1.5,
                ),
          color: isFilled
              ? (backgroundColor ?? AppColors.primary)
              : AppColors.white,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: Platform.isIOS
                      ? CupertinoActivityIndicator(
                          color: isFilled ? AppColors.white : AppColors.primary,
                          radius: 12,
                        )
                      : CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isFilled ? AppColors.white : AppColors.primary,
                          ),
                        ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: isFilled
                        ? (textColor ?? AppColors.white)
                        : (textColor ?? AppColors.primary),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
