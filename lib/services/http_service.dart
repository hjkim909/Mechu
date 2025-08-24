import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// HTTP 요청 최적화 서비스
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  // 요청 캐시 (간단한 메모리 캐시)
  final Map<String, _CachedResponse> _cache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static const Duration _requestTimeout = Duration(seconds: 10);

  /// GET 요청 (캐싱 지원)
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    bool useCache = true,
    Duration? timeout,
  }) async {
    // 캐시 확인
    if (useCache && _cache.containsKey(url)) {
      final cached = _cache[url]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheExpiry) {
        print('📦 캐시 히트: $url');
        return cached.response;
      } else {
        _cache.remove(url); // 만료된 캐시 제거
      }
    }

    try {
      print('🌐 HTTP GET: $url');
      final response = await http
          .get(
            Uri.parse(url),
            headers: _getDefaultHeaders(headers),
          )
          .timeout(timeout ?? _requestTimeout);

      // 성공한 응답만 캐싱
      if (useCache && response.statusCode == 200) {
        _cache[url] = _CachedResponse(response, DateTime.now());
        _cleanupExpiredCache(); // 주기적으로 만료된 캐시 정리
      }

      return response;
    } on SocketException {
      throw NetworkException('네트워크 연결을 확인해주세요');
    } on TimeoutException {
      throw NetworkException('요청 시간이 초과되었습니다');
    } on FormatException {
      throw NetworkException('잘못된 응답 형식입니다');
    }
  }

  /// POST 요청
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    try {
      print('🌐 HTTP POST: $url');
      return await http
          .post(
            Uri.parse(url),
            headers: _getDefaultHeaders(headers),
            body: body,
            encoding: encoding,
          )
          .timeout(timeout ?? _requestTimeout);
    } on SocketException {
      throw NetworkException('네트워크 연결을 확인해주세요');
    } on TimeoutException {
      throw NetworkException('요청 시간이 초과되었습니다');
    } on FormatException {
      throw NetworkException('잘못된 응답 형식입니다');
    }
  }

  /// 기본 헤더 설정
  Map<String, String> _getDefaultHeaders(Map<String, String>? customHeaders) {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Mechu-App/1.0',
    };

    if (customHeaders != null) {
      defaultHeaders.addAll(customHeaders);
    }

    return defaultHeaders;
  }

  /// 만료된 캐시 정리
  void _cleanupExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, cached) {
      return now.difference(cached.timestamp) > _cacheExpiry;
    });
    
    // 캐시 크기 제한 (최대 100개)
    if (_cache.length > 100) {
      final oldestKeys = _cache.keys.take(_cache.length - 100).toList();
      for (final key in oldestKeys) {
        _cache.remove(key);
      }
    }
  }

  /// 캐시 초기화
  void clearCache() {
    _cache.clear();
    print('🗑️ HTTP 캐시가 초기화되었습니다');
  }

  /// 네트워크 연결 상태 확인
  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// 캐시 상태 정보
  Map<String, dynamic> getCacheStatus() {
    return {
      'cached_requests': _cache.length,
      'cache_expiry_minutes': _cacheExpiry.inMinutes,
      'request_timeout_seconds': _requestTimeout.inSeconds,
    };
  }
}

/// 캐시된 응답 데이터
class _CachedResponse {
  final http.Response response;
  final DateTime timestamp;

  _CachedResponse(this.response, this.timestamp);
}

/// 네트워크 예외 클래스
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// 타임아웃 예외 클래스
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
