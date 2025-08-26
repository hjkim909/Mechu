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

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _successScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  /// 저장된 설정 불러오기
  void _loadSavedSettings() {
    final savedNumberOfPeople = PreferencesService.getSelectedNumberOfPeople();
    setState(() {
      _peopleCount = savedNumberOfPeople.toDouble();
    });
  }

  Future<void> _navigateToLocationSetting() async {
    // 햅틱 피드백
    HapticFeedback.lightImpact();
    
    await Navigator.of(context).push(
      PageTransitions.slideFromBottom(
        const LocationSettingScreen(),
      ),
    );
  }

  /// GPS를 통한 현재 위치 가져오기
  Future<void> _getCurrentLocationFromGPS() async {
    final locationProvider = context.read<LocationProvider>();
    
    // 햅틱 피드백
    HapticFeedback.mediumImpact();
    
    try {
      await locationProvider.getCurrentLocationFromGPS();
      
      if (mounted) {
        // 성공 애니메이션
        _successAnimationController.forward().then((_) {
          _successAnimationController.reverse();
        });
        
        // 성공 햅틱
        HapticFeedback.lightImpact();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('현재 위치를 ${locationProvider.currentLocation}(으)로 설정했습니다'),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade600,
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
              onPressed: () => locationProvider.openAppSettings(),
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
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 상단 여백
                        const SizedBox(height: 8),

                        // 현재 위치 표시 (터치 가능)
                        Consumer<LocationProvider>(
                          builder: (context, locationProvider, child) {
                            return Column(
                              children: [
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
                                        if (locationProvider.isLoading)
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: colorScheme.onPrimaryContainer,
                                            ),
                                          )
                                        else
                                          Icon(
                                            Icons.location_on,
                                            color: colorScheme.onPrimaryContainer,
                                            size: 20,
                                          ),
                                        const SizedBox(width: 8),
                                        Text(
                                          locationProvider.currentLocation,
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
                                
                                const SizedBox(height: 12),
                                
                                // GPS 현재 위치 버튼
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: locationProvider.isLoading 
                                        ? null 
                                        : () => _getCurrentLocationFromGPS(),
                                    icon: Icon(
                                      Icons.my_location,
                                      size: 18,
                                      color: colorScheme.onPrimary,
                                    ),
                                    label: Text(
                                      '📍 현재 위치로 설정하기',
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                if (locationProvider.error != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    locationProvider.error!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            );
                          },
                        ),

                        // 중간 여백
                        const SizedBox(height: 24),

                        // 인원수 선택 섹션
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // 인원수 표시
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people,
                                    color: colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${_peopleCount.round()}명을 위한 추천',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // 슬라이더
                              Semantics(
                                label: '인원수 선택',
                                hint: '현재 ${_peopleCount.round()}명 선택됨',
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: colorScheme.primary,
                                    inactiveTrackColor: colorScheme.primary.withOpacity(0.2),
                                    thumbColor: colorScheme.primary,
                                    overlayColor: colorScheme.primary.withOpacity(0.2),
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 14,
                                      pressedElevation: 8,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 28,
                                    ),
                                    trackHeight: 6,
                                    valueIndicatorColor: colorScheme.primary,
                                    valueIndicatorTextStyle: TextStyle(
                                      color: colorScheme.onPrimary,
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
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 추천 버튼
                        Consumer<RecommendationProvider>(
                          builder: (context, recommendationProvider, child) {
                            final isLoading = recommendationProvider.isLoading;
                            
                            return Semantics(
                              label: '메뉴 추천받기',
                              hint: isLoading ? '추천을 받는 중입니다' : '${_peopleCount.round()}명을 위한 메뉴를 추천받습니다',
                              button: true,
                              enabled: !isLoading,
                              child: AnimatedBuilder(
                                animation: _successScaleAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _successScaleAnimation.value,
                                    child: AnimatedButton(
                                      onTap: isLoading ? null : _getRecommendations,
                                      scaleValue: 0.96,
                                      child: PulseAnimation(
                                        duration: const Duration(seconds: 2),
                                        minScale: 1.0,
                                        maxScale: isLoading ? 1.0 : 1.01,
                                        child: Container(
                                          width: double.infinity,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: isLoading ? [
                                                colorScheme.surfaceContainerHighest,
                                                colorScheme.surfaceContainerHigh,
                                              ] : [
                                                colorScheme.primary,
                                                colorScheme.primaryContainer,
                                                colorScheme.primary.withOpacity(0.9),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              stops: const [0.0, 0.5, 1.0],
                                            ),
                                            borderRadius: BorderRadius.circular(32),
                                            boxShadow: isLoading ? [
                                              BoxShadow(
                                                color: colorScheme.shadow.withOpacity(0.1),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ] : [
                                              BoxShadow(
                                                color: colorScheme.primary.withOpacity(0.3),
                                                blurRadius: 24,
                                                offset: const Offset(0, 12),
                                              ),
                                              BoxShadow(
                                                color: colorScheme.primary.withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                            border: isLoading ? Border.all(
                                              color: colorScheme.outline.withOpacity(0.2),
                                              width: 1,
                                            ) : null,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 16,
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                // 아이콘 또는 로딩 인디케이터
                                                AnimatedSwitcher(
                                                  duration: const Duration(milliseconds: 300),
                                                  child: isLoading
                                                      ? SizedBox(
                                                          width: 32,
                                                          height: 32,
                                                          child: CircularProgressIndicator(
                                                            color: colorScheme.onSurfaceVariant,
                                                            strokeWidth: 3,
                                                          ),
                                                        )
                                                      : Icon(
                                                          Icons.restaurant_menu,
                                                          size: 32,
                                                          color: colorScheme.onPrimary,
                                                        ),
                                                ),
                                                
                                                const SizedBox(height: 10),
                                                
                                                // 버튼 텍스트
                                                AnimatedSwitcher(
                                                  duration: const Duration(milliseconds: 300),
                                                  child: Text(
                                                    isLoading ? '메뉴를 찾는 중...' : '🍽️ 지금 추천받기!',
                                                    key: ValueKey(isLoading),
                                                    style: theme.textTheme.titleLarge?.copyWith(
                                                      color: isLoading 
                                                          ? colorScheme.onSurfaceVariant 
                                                          : colorScheme.onPrimary,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 0.5,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                
                                                if (!isLoading) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${_peopleCount.round()}명 맞춤 추천',
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: colorScheme.onPrimary.withOpacity(0.9),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // 추천 이력 및 즐겨찾기 버튼
                        _buildQuickActionButtons(),

                        // 하단 여백
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
              );
            },
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
        // 추천 이력 버튼
        Expanded(
          child: Consumer<RecommendationHistoryProvider>(
            builder: (context, historyProvider, child) {
              return AnimatedButton(
                onTap: () => _navigateToHistory(),
                scaleValue: 0.96,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '추천 이력',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (historyProvider.hasHistories)
                            Text(
                              '${historyProvider.historyCount}개',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        // 즐겨찾기 버튼
        Expanded(
          child: Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              return AnimatedButton(
                onTap: () => _navigateToFavorites(),
                scaleValue: 0.96,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '즐겨찾기',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (favoriteProvider.hasFavorites)
                            Text(
                              '${favoriteProvider.favoriteCount}개',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ],
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
            const Text('즐겨찾기 화면을 준비 중입니다'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
} 