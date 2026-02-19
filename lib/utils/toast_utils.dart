import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';

/// 프로젝트 디자인과 일치하는 SnackBar 메시지 유틸리티
class ToastUtils {
  /// 성공 메시지 표시
  static void showSuccess(BuildContext context, String message) {
    // 현재 표시 중인 SnackBar가 있으면 즉시 닫기
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    IconSnackBar.show(
      context,
      snackBarType: SnackBarType.alert,
      label: message,
      backgroundColor: Colors.green,
      iconColor: Colors.white,
    );
  }

  /// 에러 메시지 표시
  static void showError(BuildContext context, String message) {
    // 현재 표시 중인 SnackBar가 있으면 즉시 닫기
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    IconSnackBar.show(
      context,
      snackBarType: SnackBarType.fail,
      label: message,
    );
  }

  /// 일반 메시지 표시
  static void show(BuildContext context, String message) {
    // 현재 표시 중인 SnackBar가 있으면 즉시 닫기
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    IconSnackBar.show(
      context,
      snackBarType: SnackBarType.alert,
      label: message,
    );
  }

  /// 긴 메시지 표시 (alert 타입으로 표시)
  static void showLong(BuildContext context, String message) {
    // 현재 표시 중인 SnackBar가 있으면 즉시 닫기
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    IconSnackBar.show(
      context,
      snackBarType: SnackBarType.alert,
      label: message,
    );
  }
}
