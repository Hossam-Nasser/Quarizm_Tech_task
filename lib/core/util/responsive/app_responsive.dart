import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A utility class that provides methods for responsive sizing using flutter_screenutil
class AppResponsive {
  /// Converts width dimension to responsive width based on design size
  static double w(double width) => width.w;
  
  /// Converts height dimension to responsive height based on design size
  static double h(double height) => height.h;
  
  /// Converts radius to responsive radius based on design size
  static double r(double radius) => radius.r;
  
  /// Converts font size to responsive font size based on design size
  static double sp(double fontSize) => fontSize.sp;
  
  /// Responsive width percentage (0.5 = 50% of screen width)
  static double wp(double percentage) => percentage.sw;
  
  /// Responsive height percentage (0.5 = 50% of screen height)
  static double hp(double percentage) => percentage.sh;
  
  /// Returns the smaller of width or height adaptive value
  static double a(double size) => size.r;
  
  /// Adds responsive padding
  static EdgeInsetsGeometry padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: (left ?? horizontal ?? all ?? 0).w,
      top: (top ?? vertical ?? all ?? 0).h,
      right: (right ?? horizontal ?? all ?? 0).w,
      bottom: (bottom ?? vertical ?? all ?? 0).h,
    );
  }
  
  /// Adds responsive margin
  static EdgeInsetsGeometry margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: (left ?? horizontal ?? all ?? 0).w,
      top: (top ?? vertical ?? all ?? 0).h,
      right: (right ?? horizontal ?? all ?? 0).w,
      bottom: (bottom ?? vertical ?? all ?? 0).h,
    );
  }
  
  /// Creates a responsive sized box with width and/or height
  static Widget sizedBox({double? width, double? height}) {
    return SizedBox(
      width: width?.w,
      height: height?.h,
    );
  }
  
  /// Creates a responsive vertical space
  static Widget verticalSpace(double height) {
    return SizedBox(height: height.h);
  }
  
  /// Creates a responsive horizontal space
  static Widget horizontalSpace(double width) {
    return SizedBox(width: width.w);
  }
}
