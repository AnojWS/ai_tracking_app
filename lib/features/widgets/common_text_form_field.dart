import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonTextFormFiled extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? hintText;
  final String? suffixText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChange;
  final void Function(String)? onFieldSubmitted;
  final bool obscureText;
  final Color? inputBorderColor;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? errorFocuesedBorderColor;
  final Color? errorTextColor;
  final double borderWidth;
  final Widget? suffixIcon;
  final bool readOnly;
  final TextAlign? textAlign;
  final AutovalidateMode? autovalidateMode;
  final int? maxLength;
  final InputCounterWidgetBuilder? buildCounter;

  const CommonTextFormFiled({
    super.key,
    required this.controller,
    this.focusNode,
    required this.label,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.inputBorderColor,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.errorFocuesedBorderColor,
    this.errorBorderColor,
    this.borderWidth = 1.0,
    this.suffixIcon,
    this.onChange,
    this.onFieldSubmitted,
    this.errorTextColor,
    this.readOnly = false,
    this.textAlign,
    this.autovalidateMode,
    this.maxLength,
    this.buildCounter,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            color: Colors.black12,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChange,
          readOnly: readOnly,
          onFieldSubmitted: onFieldSubmitted,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          autovalidateMode: autovalidateMode,
          maxLength: maxLength,
          buildCounter: buildCounter,
          cursorHeight: 18.h,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 17.sp,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            filled: readOnly,
            fillColor: readOnly ? Colors.white : Colors.grey[200],
            hintText: hintText,
            counterText: "",
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 17.sp,
              color: Colors.black45,
            ),
            errorStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
              color: errorTextColor ?? Colors.red,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                width: borderWidth,
                color: inputBorderColor ?? Colors.grey[200]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                width: 1,
                color: focusedBorderColor ?? Colors.white,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                width: borderWidth,
                color: enabledBorderColor ?? Colors.white,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                width: 1.5.w,
                color: errorBorderColor ?? Colors.red,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                width: 1.5.w,
                color: errorFocuesedBorderColor ?? Colors.red,
              ),
            ),
            suffixIcon:
                suffixIcon != null ? UnconstrainedBox(child: suffixIcon) : null,
            suffixStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 17.sp,
              color: Colors.blue,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: 10.w,
            ),
          ),
          textAlign: textAlign ?? TextAlign.start,
        ),
      ],
    );
  }
}
