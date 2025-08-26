import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../utils/page_transitions.dart';
import '../widgets/network_status_banner.dart';
import 'recommendation_result_screen.dart';
import 'location_setting_screen.dart';
import 'recommendation_history_screen.dart';
import 'settings_screen.dart';
import 'swipe_recommendation_screen.dart';
import 'kakao_api_test_screen.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool showAppBar;
  
  const HomeScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double _peopleCount = 2.0; // 기본값 2명
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late AnimationController _successAnimationController;
  late Animation<double> _successScaleAnimation;
  late Animation<Color?> _successColorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // 버튼 터치 애니메이션
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));

    // 성공 애니메이션
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _successScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    ));
    _successColorAnimation = ColorTween(
      begin: null,
      end: Colors.green,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadUserPreferences() async {
    final savedCount = await PreferencesService.getSelectedNumberOfPeople();
    if (mounted && savedCount != _peopleCount.round()) {
      setState(() {
        _peopleCount = savedCount.toDouble();
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.getCurrentLocationFromGPS();
      
      if (mounted) {
        // 성공 햅틱
        HapticFeedback.lightImpact();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('현재 위치: ${locationProvider.currentLocation}'),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // 실패 햅틱
        HapticFeedback.heavyImpact();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('위치 권한을 확인해주세요'),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: '설정',
              textColor: Colors.white,
              onPressed: () {
                final locationProvider = context.read<LocationProvider>();
                locationProvider.openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _getRecommendations() async {
    // 햅틱 피드백
    HapticFeedback.selectionClick();
    
    // 스와이프 추천 화면으로 부드러운 애니메이션과 함께 이동
    Navigator.of(context).push(
      PageTransitions.slideFromRight(
        SwipeRecommendationScreen(
          numberOfPeople: _peopleCount.round(),
        ),
      ),
    );
  }

  void _onSliderChanged(double value) {
    setState(() {
      _peopleCount = value;
    });
    
    // 슬라이더 변경 시 햅틱 피드백
    HapticFeedback.selectionClick();
    
    // 변경된 값 저장
    PreferencesService.setSelectedNumberOfPeople(_peopleCount.round());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: Text(
          '메뉴 추천',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          // 개발자 테스트 버튼 (디버그 모드에서만 표시)
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              tooltip: '개발자 도구',
              onPressed: () {
                // 설정 탭으로 전환하고 개발자 도구 접근
                _navigateToTab(3);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('설정 > 개발자 도구에서 API 테스트를 확인하세요'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 설정 탭으로 전환 (탭 인덱스 3)
              _navigateToTab(3);
            },
          ),
        ],
      ) : null,
      body: NetworkStatusBanner(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 현재 위치 표시 (터치 가능)
                  Consumer<LocationProvider>(
                    builder: (context, locationProvider, child) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: _getCurrentLocation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: theme.colorScheme.onPrimaryContainer,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      locationProvider.currentLocation.isEmpty
                                          ? '현재 위치'
                                          : locationProvider.currentLocation,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.edit,
                                    color: theme.colorScheme.onPrimaryContainer,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 현재 위치로 설정하기 버튼
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _getCurrentLocation,
                              icon: Icon(
                                Icons.my_location,
                                size: 20,
                                color: theme.colorScheme.onPrimary,
                              ),
                              label: Text(
                                '현재 위치로 설정하기',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // 인원수 선택
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // 제목
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_peopleCount.round()}명을 위한 추천',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 슬라이더
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: theme.colorScheme.primary,
                                inactiveTrackColor: theme.colorScheme.outline.withOpacity(0.3),
                                thumbColor: theme.colorScheme.primary,
                                overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                                trackHeight: 6,
                                valueIndicatorColor: theme.colorScheme.primary,
                                valueIndicatorTextStyle: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: Slider(
                                value: _peopleCount,
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: '${_peopleCount.round()}명',
                                onChanged: _onSliderChanged,
                              ),
                            ),
                          ),
                          
                          // 슬라이더 범위 표시
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '1명',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '10명',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 추천 버튼 (높이 대폭 축소)
                  Consumer<RecommendationProvider>(
                    builder: (context, recommendationProvider, child) {
                      final isLoading = recommendationProvider.isLoading;
                      
                      return Container(
                        width: double.infinity,
                        height: 80, // 150에서 80으로 대폭 축소
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _getRecommendations,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                          ),
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: theme.colorScheme.onPrimary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '메뉴 찾는 중...',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu,
                                      size: 28,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '메뉴 추천',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // 빠른 액션 버튼들 (높이 축소)
                  _buildQuickActionButtons(),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 빠른 액션 버튼들 (추천 이력, 즐겨찾기)
  Widget _buildQuickActionButtons() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Consumer<RecommendationHistoryProvider>(
            builder: (context, historyProvider, child) {
              return Container(
                height: 50, // 80에서 50으로 축소
                child: ElevatedButton.icon(
                  onPressed: _navigateToHistory,
                  icon: Icon(
                    Icons.history,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '추천 이력',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      if (historyProvider.hasHistories)
                        Text(
                          '${historyProvider.historyCount}개',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    elevation: 2,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              return Container(
                height: 50, // 80에서 50으로 축소
                child: ElevatedButton.icon(
                  onPressed: _navigateToFavorites,
                  icon: Icon(
                    Icons.favorite,
                    color: theme.colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '즐겨찾기',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                      if (favoriteProvider.hasFavorites)
                        Text(
                          '${favoriteProvider.favoriteCount}개',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    foregroundColor: theme.colorScheme.onTertiaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    elevation: 2,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 추천 이력 화면으로 이동
  void _navigateToHistory() {
    HapticFeedback.lightImpact();
    // 이력 탭으로 전환 (탭 인덱스 1)
    _navigateToTab(1);
  }

  /// 특정 탭으로 이동하는 헬퍼 메서드
  void _navigateToTab(int tabIndex) {
    // MainNavigationScreen의 탭 전환을 위해 context를 통해 접근
    final mainNavState = 
        context.findAncestorStateOfType<MainNavigationScreenState>();
    if (mainNavState != null) {
      mainNavState.switchToTab(tabIndex);
    }
  }

  /// 즐겨찾기 화면으로 이동
  void _navigateToFavorites() {
    HapticFeedback.lightImpact();
    // 즐겨찾기 탭으로 전환 (탭 인덱스 2)
    _navigateToTab(2);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('즐겨찾기 기능이 추가되었습니다'),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}