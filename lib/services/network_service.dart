import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 네트워크 연결 상태 관리 서비스
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  late StreamController<NetworkStatus> _networkStatusController;
  
  NetworkStatus _currentStatus = NetworkStatus.unknown;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  /// 네트워크 상태 스트림
  Stream<NetworkStatus> get networkStatusStream => 
      _networkStatusController.stream;

  /// 현재 네트워크 상태
  NetworkStatus get currentStatus => _currentStatus;

  /// 현재 온라인 상태인지 확인
  bool get isOnline => _currentStatus == NetworkStatus.online;

  /// 현재 오프라인 상태인지 확인
  bool get isOffline => _currentStatus == NetworkStatus.offline;

  /// 네트워크 서비스 초기화
  Future<void> initialize() async {
    _networkStatusController = StreamController<NetworkStatus>.broadcast();
    
    // 초기 연결 상태 확인
    await _checkInitialConnection();
    
    // 연결 상태 변화 감지
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        print('네트워크 상태 감지 오류: $error');
      },
    );
  }

  /// 초기 연결 상태 확인
  Future<void> _checkInitialConnection() async {
    try {
      final ConnectivityResult connectivityResult = 
          await _connectivity.checkConnectivity();
      await _onConnectivityChanged(connectivityResult);
    } catch (e) {
      print('초기 네트워크 상태 확인 실패: $e');
      _updateNetworkStatus(NetworkStatus.offline);
    }
  }

  /// 연결 상태 변화 처리
  Future<void> _onConnectivityChanged(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      _updateNetworkStatus(NetworkStatus.offline);
      return;
    }

    // 실제 인터넷 연결 가능 여부 확인
    final bool hasInternetConnection = await _hasInternetConnection();
    
    if (hasInternetConnection) {
      _updateNetworkStatus(NetworkStatus.online);
    } else {
      _updateNetworkStatus(NetworkStatus.offline);
    }
  }

  /// 실제 인터넷 연결 가능 여부 확인
  Future<bool> _hasInternetConnection() async {
    try {
      // Google DNS 서버로 간단한 연결 테스트
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('인터넷 연결 테스트 실패: $e');
      }
      return false;
    }
  }

  /// 네트워크 상태 업데이트
  void _updateNetworkStatus(NetworkStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _networkStatusController.add(status);
      
      if (kDebugMode) {
        print('🌐 네트워크 상태 변경: ${status.name}');
      }
    }
  }

  /// 수동으로 네트워크 상태 재확인
  Future<void> refreshNetworkStatus() async {
    await _checkInitialConnection();
  }

  /// 리소스 정리
  void dispose() {
    _connectivitySubscription?.cancel();
    _networkStatusController.close();
  }
}

/// 네트워크 연결 상태
enum NetworkStatus {
  /// 온라인 상태
  online,
  
  /// 오프라인 상태
  offline,
  
  /// 상태 확인 중
  unknown;

  /// 상태 표시용 메시지
  String get message {
    switch (this) {
      case NetworkStatus.online:
        return '인터넷에 연결됨';
      case NetworkStatus.offline:
        return '인터넷 연결 없음';
      case NetworkStatus.unknown:
        return '연결 상태 확인 중...';
    }
  }

  /// 상태 표시용 아이콘
  String get icon {
    switch (this) {
      case NetworkStatus.online:
        return '🌐';
      case NetworkStatus.offline:
        return '📱';
      case NetworkStatus.unknown:
        return '🔄';
    }
  }
}

/// 네트워크 상태 제공자 (Provider 패턴용)
class NetworkStatusProvider extends ChangeNotifier {
  final NetworkService _networkService = NetworkService();
  StreamSubscription<NetworkStatus>? _subscription;
  
  NetworkStatus _status = NetworkStatus.unknown;
  
  /// 현재 네트워크 상태
  NetworkStatus get status => _status;
  
  /// 온라인 상태인지
  bool get isOnline => _status == NetworkStatus.online;
  
  /// 오프라인 상태인지
  bool get isOffline => _status == NetworkStatus.offline;

  NetworkStatusProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _networkService.initialize();
    
    _subscription = _networkService.networkStatusStream.listen(
      (NetworkStatus status) {
        _status = status;
        notifyListeners();
      },
    );
    
    // 초기 상태 설정
    _status = _networkService.currentStatus;
    notifyListeners();
  }

  /// 네트워크 상태 수동 새로고침
  Future<void> refresh() async {
    await _networkService.refreshNetworkStatus();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _networkService.dispose();
    super.dispose();
  }
}
