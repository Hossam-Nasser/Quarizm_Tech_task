import 'package:flutter/material.dart';
import '../responsive/app_responsive.dart';
import '../theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final Color? textColor;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppTheme.primaryColor;
    final buttonTextColor = textColor ?? (isOutlined ? buttonColor : Colors.white);
    
    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !isLoading) ...[
          Icon(icon, color: buttonTextColor, size: AppResponsive.r(20)),
          AppResponsive.horizontalSpace(8),
        ],
        if (isLoading)
          SizedBox(
            width: AppResponsive.w(20),
            height: AppResponsive.h(20),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
            ),
          )
        else
          Text(
            text,
            style: TextStyle(
              color: buttonTextColor,
              fontSize: AppResponsive.sp(AppTheme.bodyLarge),
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
    
    return Padding(
      padding: AppResponsive.padding(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: isOutlined
            ? OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: buttonColor),
                  padding: AppResponsive.padding(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppResponsive.r(8)),
                  ),
                ),
                child: buttonContent,
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: AppResponsive.padding(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppResponsive.r(8)),
                  ),
                ),
                child: buttonContent,
              ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final int? maxLines;
  final int? minLines;
  final EdgeInsets? contentPadding;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final bool enabled;

  const AppTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.minLines,
    this.contentPadding,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppResponsive.sp(14),
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
        ),
        AppResponsive.verticalSpace(8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          minLines: minLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            suffixIcon: suffix,
            contentPadding: contentPadding,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: AppResponsive.sp(14),
            ),
          ),
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: AppResponsive.sp(16),
          ),
        ),
        AppResponsive.verticalSpace(16),
      ],
    );
  }
}

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: AppResponsive.r(50),
          ),
          AppResponsive.verticalSpace(16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppResponsive.sp(16),
              color: AppTheme.textColor,
            ),
          ),
          if (onRetry != null) ...[
            AppResponsive.verticalSpace(24),
            AppButton(
              text: 'Try Again',
              onPressed: onRetry!,
              isOutlined: true,
            ),
          ],
        ],
      ),
    );
  }
}

class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class AppEmptyWidget extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyWidget({
    Key? key,
    required this.message,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.grey,
            size: AppResponsive.r(50),
          ),
          AppResponsive.verticalSpace(16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppResponsive.sp(16),
              color: AppTheme.subtitleColor,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            AppResponsive.verticalSpace(24),
            AppButton(
              text: actionLabel!,
              onPressed: onAction!,
            ),
          ],
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.color,
    this.elevation,
    this.onTap,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Colors.white,
      elevation: elevation ?? 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(AppResponsive.r(16)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(AppResponsive.r(16)),
        child: Padding(
          padding: padding ?? AppResponsive.padding(all: 16),
          child: child,
        ),
      ),
    );
  }
}
