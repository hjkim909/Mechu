import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import 'recommendation_result_screen.dart';

class MenuSelectionScreen extends StatefulWidget {
  final int numberOfPeople;

  const MenuSelectionScreen({
    super.key,
    required this.numberOfPeople,
  });

  @override
  State<MenuSelectionScreen> createState() => _MenuSelectionScreenState();
}

class _MenuSelectionScreenState extends State<MenuSelectionScreen> {
  String? _selectedCategory;

  // 메뉴 카테고리 데이터
  final List<MenuCategory> _menuCategories = [
    MenuCategory(
      name: '한식',
      icon: '🍚',
      description: '김치찌개, 불고기, 비빔밥',
      color: Colors.red,
    ),
    MenuCategory(
      name: '중식',
      icon: '🥢',
      description: '짜장면, 짬뽕, 탕수육',
      color: Colors.orange,
    ),
    MenuCategory(
      name: '일식',
      icon: '🍣',
      description: '초밥, 라멘, 돈까스',
      color: Colors.pink,
    ),
    MenuCategory(
      name: '양식',
      icon: '🍝',
      description: '파스타, 스테이크, 피자',
      color: Colors.green,
    ),
    MenuCategory(
      name: '치킨',
      icon: '🍗',
      description: '후라이드, 양념, 간장',
      color: Colors.amber,
    ),
    MenuCategory(
      name: '분식',
      icon: '🍢',
      description: '떡볶이, 순대, 김밥',
      color: Colors.deepOrange,
    ),
    MenuCategory(
      name: '카페',
      icon: '☕',
      description: '커피, 디저트, 브런치',
      color: Colors.brown,
    ),
    MenuCategory(
      name: '패스트푸드',
      icon: '🍔',
      description: '햄버거, 피자, 샌드위치',
      color: Colors.red.shade800,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.numberOfPeople}명을 위한 메뉴 선택',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 헤더 설명
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: colorScheme.primaryContainer.withOpacity(0.3),
            child: Column(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 32,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  '어떤 메뉴를 드시고 싶나요?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '메뉴를 선택하면 맛있는 음식점을 추천해드릴게요!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // 메뉴 카테고리 그리드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: _menuCategories.length,
                itemBuilder: (context, index) {
                  final category = _menuCategories[index];
                  final isSelected = _selectedCategory == category.name;
                  
                  return _buildMenuCategoryCard(category, isSelected);
                },
              ),
            ),
          ),

          // 하단 선택 완료 버튼
          if (_selectedCategory != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Consumer<RecommendationProvider>(
                builder: (context, recommendationProvider, child) {
                  return ElevatedButton(
                    onPressed: recommendationProvider.isLoading 
                        ? null 
                        : () => _getRecommendationsByCategory(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: recommendationProvider.isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: colorScheme.onPrimary,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text('음식점 찾는 중...'),
                            ],
                          )
                        : Text(
                            '$_selectedCategory 음식점 찾기',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuCategoryCard(MenuCategory category, bool isSelected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected 
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedCategory = _selectedCategory == category.name ? null : category.name;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 메뉴 아이콘
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? colorScheme.primary 
                      : category.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    category.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 메뉴 이름
              Text(
                category.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected 
                      ? colorScheme.primary 
                      : colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // 메뉴 설명
              Text(
                category.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getRecommendationsByCategory() async {
    if (_selectedCategory == null) return;

    final recommendationProvider = context.read<RecommendationProvider>();
    final locationProvider = context.read<LocationProvider>();

    try {
      await recommendationProvider.getRecommendationsByCategory(
        location: locationProvider.currentLocation,
        category: _selectedCategory!,
      );

      if (mounted && recommendationProvider.hasRecommendations) {
        // 현재 위치를 UserLocation으로 변환
        final locationService = LocationService();
        final userLocation = await locationService.getLocationFromAddress(locationProvider.currentLocation) 
            ?? const UserLocation(latitude: 37.4979517, longitude: 127.0276188, address: '강남역');
        
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecommendationResultScreen(
              restaurants: recommendationProvider.recommendations,
              numberOfPeople: widget.numberOfPeople,
              userLocation: userLocation,
              selectedCategory: _selectedCategory,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_selectedCategory 음식점을 찾을 수 없습니다'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('음식점 검색 중 오류가 발생했습니다: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// 메뉴 카테고리 데이터 클래스
class MenuCategory {
  final String name;
  final String icon;
  final String description;
  final Color color;

  MenuCategory({
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
  });
} 