import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/http_service.dart';

/// 앱 전역 에러 핸들러
class AppErrorHandler {
  static final AppErrorHandler _instance = AppErrorHandler._internal();
  factory AppErrorHandler() => _instance;
  AppErrorHandler._internal();

  /// 에러 타입별 처리
  static AppError analyzeError(dynamic error) {
    if (error is NetworkException) {
      return AppError.network(error.message);
    } else if (error is TimeoutException) {
      return AppError.timeout();
    } else if (error.toString().contains('permission')) {
      return AppError.permission();
    } else if (error.toString().contains('location')) {
      return AppError.location();
    } else if (error.toString().contains('API')) {
      return AppError.api();
    } else {
      return AppError.unknown(error.toString());
    }
  }

  /// 사용자에게 에러 표시
  static void showError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final appError = analyzeError(error);
    
    // 에러 로깅
    _logError(error, appError);

    // 사용자에게 표시
    if (customMessage != null) {
      _showSnackBar(context, customMessage, appError.type, onRetry);
    } else {
      _showSnackBar(context, appError.userMessage, appError.type, onRetry);
    }
  }

  /// 전역 에러 다이얼로그 표시
  static void showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    VoidCallback? onRetry,
  }) {
    final appError = analyzeError(error);
    _logError(error, appError);

    showDialog(
      context: context,
      builder: (context) => AppErrorDialog(
        error: appError,
        title: title,
        onRetry: onRetry,
      ),
    );
  }

  /// 스낵바로 에러 표시
  static void _showSnackBar(
    BuildContext context,
    String message,
    ErrorType type,
    VoidCallback? onRetry,
  ) {
    final color = _getErrorColor(type);
    final icon = _getErrorIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry();
                },
                child: const Text(
                  '재시도',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: onRetry != null ? 6 : 4),
        action: onRetry == null ? null : SnackBarAction(
          label: '재시도',
          textColor: Colors.white,
          onPressed: onRetry,
        ),
      ),
    );
  }

  /// 에러 로깅
  static void _logError(dynamic error, AppError appError) {
    if (kDebugMode) {
      print('🚨 [ERROR] ${appError.type.name}: ${appError.userMessage}');
      print('📝 [DETAIL] $error');
      print('⏰ [TIME] ${DateTime.now().toIso8601String()}');
      print('━' * 50);
    }
    
    // TODO: 실제 배포에서는 Firebase Crashlytics 등으로 전송
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  /// 에러 타입별 색상
  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange.shade600;
      case ErrorType.permission:
        return Colors.amber.shade600;
      case ErrorType.timeout:
        return Colors.blue.shade600;
      case ErrorType.api:
        return Colors.red.shade600;
      case ErrorType.location:
        return Colors.purple.shade600;
      case ErrorType.unknown:
        return Colors.grey.shade600;
    }
  }

  /// 에러 타입별 아이콘
  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.permission:
        return Icons.security;
      case ErrorType.timeout:
        return Icons.timer_off;
      case ErrorType.api:
        return Icons.cloud_off;
      case ErrorType.location:
        return Icons.location_off;
      case ErrorType.unknown:
        return Icons.error_outline;
    }
  }
}

/// 앱 에러 모델
class AppError {
  final ErrorType type;
  final String userMessage;
  final String? technicalMessage;
  final bool isRetryable;

  const AppError._({
    required this.type,
    required this.userMessage,
    this.technicalMessage,
    this.isRetryable = true,
  });

  // 네트워크 에러
  factory AppError.network([String? detail]) => AppError._(
    type: ErrorType.network,
    userMessage: '인터넷 연결을 확인해주세요',
    technicalMessage: detail,
    isRetryable: true,
  );

  // 타임아웃 에러
  factory AppError.timeout() => const AppError._(
    type: ErrorType.timeout,
    userMessage: '요청 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요',
    isRetryable: true,
  );

  // 권한 에러
  factory AppError.permission() => const AppError._(
    type: ErrorType.permission,
    userMessage: '앱 권한이 필요합니다.\n설정에서 권한을 허용해주세요',
    isRetryable: false,
  );

  // 위치 에러
  factory AppError.location() => const AppError._(
    type: ErrorType.location,
    userMessage: '위치 서비스를 사용할 수 없습니다.\n위치 설정을 확인해주세요',
    isRetryable: true,
  );

  // API 에러
  factory AppError.api() => const AppError._(
    type: ErrorType.api,
    userMessage: '서버에 일시적인 문제가 발생했습니다.\n잠시 후 다시 시도해주세요',
    isRetryable: true,
  );

  // 알 수 없는 에러
  factory AppError.unknown(String? detail) => AppError._(
    type: ErrorType.unknown,
    userMessage: '예상치 못한 문제가 발생했습니다.\n문제가 계속되면 고객센터로 문의해주세요',
    technicalMessage: detail,
    isRetryable: true,
  );
}

/// 에러 타입 정의
enum ErrorType {
  network,    // 네트워크 연결 문제
  timeout,    // 요청 시간 초과
  permission, // 권한 문제  
  location,   // 위치 서비스 문제
  api,        // API 서버 문제
  unknown,    // 알 수 없는 문제
}

/// 에러 다이얼로그 위젯
class AppErrorDialog extends StatelessWidget {
  final AppError error;
  final String? title;
  final VoidCallback? onRetry;

  const AppErrorDialog({
    super.key,
    required this.error,
    this.title,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: Icon(
        AppErrorHandler._getErrorIcon(error.type),
        color: AppErrorHandler._getErrorColor(error.type),
        size: 48,
      ),
      title: Text(
        title ?? '문제가 발생했습니다',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            error.userMessage,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (kDebugMode && error.technicalMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🐛 ${error.technicalMessage}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('확인'),
        ),
        if (onRetry != null && error.isRetryable)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: const Text('재시도'),
          ),
      ],
    );
  }
}
