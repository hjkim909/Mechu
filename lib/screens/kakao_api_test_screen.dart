import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/performance_monitor_widget.dart';
import '../widgets/error_boundary_widget.dart';
import '../utils/error_handler.dart';

/// 카카오 API 테스트 전용 화면
class KakaoApiTestScreen extends StatefulWidget {
  const KakaoApiTestScreen({super.key});

  @override
  State<KakaoApiTestScreen> createState() => _KakaoApiTestScreenState();
}

class _KakaoApiTestScreenState extends State<KakaoApiTestScreen> {
  final KakaoApiService _kakaoApiService = KakaoApiService();
  final ConfigService _configService = ConfigService();
  final LocationService _locationService = LocationService();
  final TextEditingController _keywordController = TextEditingController();
  
  List<Restaurant> _testResults = [];
  bool _isLoading = false;
  String _statusMessage = '';
  String _addressResult = '';
  bool _isApiKeyValid = false;
  Map<String, dynamic> _configStatus = {};
  UserLocation? _currentLocation;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _initializeTests();
  }

  Future<void> _initializeTests() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'API 상태 확인 중...';
    });

    try {
      // ConfigService 상태 확인
      _configStatus = _configService.getConfigStatus();
      
      // 현재 위치 가져오기
      _currentLocation = await _locationService.getCurrentLocation();
      
      // API 키 유효성 검사
      _isApiKeyValid = await _kakaoApiService.isApiKeyValid();
      
      setState(() {
        _statusMessage = _isApiKeyValid ? 'API 키가 유효합니다!' : 'API 키가 유효하지 않습니다.';
      });
    } catch (e) {
      final appError = AppErrorHandler.analyzeError(e);
      setState(() {
        _statusMessage = 'API 상태 확인 실패: ${appError.userMessage}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCategorySearch() async {
    if (_currentLocation == null) {
      setState(() {
        _statusMessage = '위치 정보가 필요합니다. 위치를 가져오는 중...';
      });
      await _initializeTests();
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '카테고리 검색 테스트 중...';
      _testResults.clear();
    });

    try {
      final restaurants = await _kakaoApiService.searchRestaurantsByCategory(
        category: '김치찌개',
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        radius: 2000,
        size: 5,
      );

      setState(() {
        _testResults = restaurants;
        _statusMessage = '카테고리 검색 성공! ${restaurants.length}개 결과';
      });
    } catch (e) {
      final appError = AppErrorHandler.analyzeError(e);
      setState(() {
        _statusMessage = '카테고리 검색 실패: ${appError.userMessage}';
      });
      
      // 상세 에러 로깅
      AppErrorHandler.showError(context, e, onRetry: _testCategorySearch);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testKeywordSearch() async {
    if (_keywordController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = '검색 키워드를 입력하세요.';
      });
      return;
    }

    if (_currentLocation == null) {
      setState(() {
        _statusMessage = '위치 정보가 필요합니다. 위치를 가져오는 중...';
      });
      await _initializeTests();
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '키워드 검색 테스트 중...';
      _testResults.clear();
    });

    try {
      final restaurants = await _kakaoApiService.searchRestaurantsByKeyword(
        keyword: _keywordController.text.trim(),
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        radius: 3000,
        size: 5,
      );

      setState(() {
        _testResults = restaurants;
        _statusMessage = '키워드 검색 성공! ${restaurants.length}개 결과';
      });
    } catch (e) {
      final appError = AppErrorHandler.analyzeError(e);
      setState(() {
        _statusMessage = '키워드 검색 실패: ${appError.userMessage}';
      });
      
      AppErrorHandler.showError(context, e, onRetry: _testKeywordSearch);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testReverseGeocoding() async {
    if (_currentLocation == null) {
      setState(() {
        _statusMessage = '위치 정보가 필요합니다. 위치를 가져오는 중...';
      });
      await _initializeTests();
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '주소 변환 테스트 중...';
    });

    try {
      final address = await _kakaoApiService.getAddressFromCoordinates(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
      );

      setState(() {
        _addressResult = address;
        _statusMessage = '주소 변환 성공!';
      });
    } catch (e) {
      final appError = AppErrorHandler.analyzeError(e);
      setState(() {
        _statusMessage = '주소 변환 실패: ${appError.userMessage}';
      });
      
      AppErrorHandler.showError(context, e, onRetry: _testReverseGeocoding);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return PerformanceMonitorWidget(
      child: Scaffold(
      appBar: AppBar(
        title: const Text('카카오 API 테스트'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API 상태 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API 상태 정보',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('API 키 유효성: ${_isApiKeyValid ? "✅ 유효함" : "❌ 유효하지 않음"}'),
                    Text('실제 API 사용: ${_configStatus['useRealApi'] ?? false ? "✅ 활성화" : "❌ 비활성화"}'),
                    Text('API 키 길이: ${_configStatus['kakaoApiKeyLength'] ?? 0}자'),
                    Text('기본 키 사용: ${_configStatus['isDefaultKey'] ?? true ? "❌ 기본 키" : "✅ 실제 키"}'),
                    const SizedBox(height: 8),
                    Text(
                      '현재 위치: ${_currentLocation != null 
                        ? "${_currentLocation!.address} (${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)})" 
                        : "위치 정보 없음"}',
                      style: TextStyle(
                        color: _currentLocation != null 
                          ? Colors.green 
                          : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 상태 메시지
            if (_statusMessage.isNotEmpty)
              Card(
                color: _isApiKeyValid ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      if (_isLoading) const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            color: _isApiKeyValid ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // 테스트 버튼들
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testCategorySearch,
                  icon: const Icon(Icons.restaurant),
                  label: const Text('카테고리 검색 테스트 (김치찌개)'),
                ),
                const SizedBox(height: 8),
                
                // 키워드 검색
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _keywordController,
                        decoration: const InputDecoration(
                          labelText: '검색 키워드',
                          hintText: '예: 치킨, 피자, 카페',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testKeywordSearch,
                      child: const Text('검색'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testReverseGeocoding,
                  icon: const Icon(Icons.location_on),
                  label: const Text('주소 변환 테스트'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 주소 변환 결과
            if (_addressResult.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '주소 변환 결과',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(_addressResult),
                    ],
                  ),
                ),
              ),
            
            // 검색 결과
            if (_testResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '검색 결과 (${_testResults.length}개)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...(_testResults.map((restaurant) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(restaurant.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('카테고리: ${restaurant.category}'),
                      Text('주소: ${restaurant.address}'),
                      Text('평점: ${restaurant.rating} ⭐'),
                    ],
                  ),
                  trailing: Text(
                    '${restaurant.priceLevel}만원대',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ))),
            ],
          ],
        ),
      ),
    ),
    );
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }
}
