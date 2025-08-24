import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/error_handler.dart';

/// 에러 경계 위젯 - 자식 위젯에서 발생하는 에러를 잡아서 처리
class ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;
  final String? fallbackTitle;
  final String? fallbackMessage;
  final VoidCallback? onRetry;
  final Function(dynamic error, StackTrace? stackTrace)? onError;

  const ErrorBoundaryWidget({
    super.key,
    required this.child,
    this.fallbackTitle,
    this.fallbackMessage,
    this.onRetry,
    this.onError,
  });

  @override
  State<ErrorBoundaryWidget> createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<ErrorBoundaryWidget> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    
    // Flutter 에러 핸들링
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
        
        // 에러 콜백 호출
        widget.onError?.call(details.exception, details.stack);
        
        // 에러 로깅
        if (kDebugMode) {
          FlutterError.presentError(details);
        }
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorWidget(context);
    }

    return widget.child;
  }

  Widget _buildErrorWidget(BuildContext context) {
    final appError = AppErrorHandler.analyzeError(_error);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),
                
                Text(
                  widget.fallbackTitle ?? '예상치 못한 문제가 발생했습니다',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                Text(
                  widget.fallbackMessage ?? appError.userMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                
                if (kDebugMode) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        '🐛 Debug Info:\n${_error.toString()}\n\n${_stackTrace.toString()}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 재시도 버튼
                    if (widget.onRetry != null)
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _error = null;
                            _stackTrace = null;
                          });
                          widget.onRetry!();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('재시도'),
                      ),
                    
                    // 홈으로 가기 버튼
                    OutlinedButton.icon(
                      onPressed: () {
                        // 홈으로 이동하거나 앱 재시작
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('홈으로'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 안전한 비동기 작업 실행기
class SafeAsyncExecutor {
  /// 안전한 비동기 작업 실행
  static Future<T?> execute<T>(
    Future<T> Function() operation, {
    String? context,
    Function(dynamic error)? onError,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      // 에러 로깅
      if (kDebugMode) {
        print('🚨 [SafeAsyncExecutor] Error in ${context ?? 'unknown'}: $error');
        print('📝 [StackTrace] $stackTrace');
      }
      
      // 에러 콜백 호출
      onError?.call(error);
      
      return null;
    }
  }

  /// 재시도가 가능한 비동기 작업 실행
  static Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? context,
    Function(dynamic error, int attempt)? onRetry,
    Function(dynamic error)? onFinalError,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (error) {
        if (kDebugMode) {
          print('🚨 [Attempt $attempt/$maxRetries] Error in ${context ?? 'unknown'}: $error');
        }
        
        // 마지막 시도인 경우
        if (attempt == maxRetries) {
          onFinalError?.call(error);
          return null;
        }
        
        // 재시도 콜백 호출
        onRetry?.call(error, attempt);
        
        // 지연 후 재시도
        await Future.delayed(delay * attempt);
      }
    }
    
    return null;
  }
}

/// Future Builder with Error Handling
class SafeFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, dynamic error)? errorBuilder;
  final VoidCallback? onRetry;

  const SafeFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ?? 
            const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          if (errorBuilder != null) {
            return errorBuilder!(context, snapshot.error);
          }
          
          final appError = AppErrorHandler.analyzeError(snapshot.error);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appError.userMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('재시도'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        
        if (snapshot.hasData) {
          return builder(context, snapshot.data!);
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}
