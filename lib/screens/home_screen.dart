import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'recommendation_result_screen.dart';
import 'location_setting_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _peopleCount = 2.0; // 기본값 2명
  bool _isLoading = false;
  UserLocation? _selectedLocation;
  
  final LocationService _locationService = LocationService();
  final RecommendationService _recommendationService = RecommendationService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _userService.initialize();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();
      setState(() {
        _selectedLocation = location;
      });
    } catch (e) {
      // 기본값 유지
    }
  }

  Future<void> _navigateToLocationSetting() async {
    final result = await Navigator.of(context).push<UserLocation>(
      MaterialPageRoute(
        builder: (context) => const LocationSettingScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  Future<void> _getRecommendations() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 선택된 위치 또는 현재 위치 사용
      final userLocation = _selectedLocation ?? await _locationService.getCurrentLocation();
      
      // 빠른 추천 요청
      final recommendations = await _recommendationService.getQuickRecommendations(
        userLocation: userLocation,
        numberOfPeople: _peopleCount.round(),
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecommendationResultScreen(
              restaurants: recommendations,
              numberOfPeople: _peopleCount.round(),
              userLocation: userLocation,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('추천을 가져오는데 실패했습니다: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '메뉴 추천',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 상단 여백
              const SizedBox(height: 32),

              // 현재 위치 표시 (터치 가능)
              GestureDetector(
                onTap: _navigateToLocationSetting,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedLocation?.address ?? '강남역',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.edit,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              // 중간 여백 (확장)
              const Expanded(child: SizedBox()),

              // 인원수 텍스트
              Text(
                '${_peopleCount.round()}명을 위한 추천',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 32),

              // 추천 버튼
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: _isLoading ? null : _getRecommendations,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                                              child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isLoading
                                ? SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: CircularProgressIndicator(
                                      color: colorScheme.onPrimary,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : Icon(
                                    Icons.restaurant_menu,
                                    size: 48,
                                    color: colorScheme.onPrimary,
                                  ),
                            const SizedBox(height: 12),
                            Text(
                              _isLoading ? '추천 중...' : '지금 추천받기!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // 인원수 슬라이더
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '인원수 선택',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: colorScheme.primary,
                        inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
                        thumbColor: colorScheme.primary,
                        overlayColor: colorScheme.primary.withOpacity(0.1),
                        valueIndicatorColor: colorScheme.primary,
                        valueIndicatorTextStyle: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Slider(
                        value: _peopleCount,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '${_peopleCount.round()}명',
                        onChanged: (value) {
                          setState(() {
                            _peopleCount = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1명',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '10명',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 하단 여백
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
} 