import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../utils/page_transitions.dart';
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

  // 구체적인 메뉴 데이터 (강남역 인기 메뉴 예시)
  final List<MenuCategory> _menuCategories = [
    MenuCategory(
      name: '김치찌개',
      icon: '🥘',
      description: '매콤한 김치찌개와 따뜻한 밥',
      color: Colors.red,
    ),
    MenuCategory(
      name: '삼겹살',
      icon: '🥓',
      description: '직화구이 삼겹살과 쌈채소',
      color: Colors.pink,
    ),
    MenuCategory(
      name: '짜장면',
      icon: '🍜',
      description: '진한 춘장소스의 짜장면',
      color: Colors.brown,
    ),
    MenuCategory(
      name: '치킨',
      icon: '🍗',
      description: '바삭한 후라이드 & 양념치킨',
      color: Colors.orange,
    ),
    MenuCategory(
      name: '라멘',
      icon: '🍲',
      description: '진한 돈코츠 라멘',
      color: Colors.amber,
    ),
    MenuCategory(
      name: '떡볶이',
      icon: '🍢',
      description: '매콤달콤 떡볶이',
      color: Colors.deepOrange,
    ),
    MenuCategory(
      name: '피자',
      icon: '🍕',
      description: '치즈 가득한 피자',
      color: Colors.yellow,
    ),
    MenuCategory(
      name: '파스타',
      icon: '🍝',
      description: '크림/토마토 파스타',
      color: Colors.green,
    ),
    MenuCategory(
      name: '햄버거',
      icon: '🍔',
      description: '수제 패티 햄버거',
      color: Colors.red.shade800,
    ),
    MenuCategory(
      name: '초밥',
      icon: '🍣',
      description: '신선한 회와 초밥',
      color: Colors.teal,
    ),
    MenuCategory(
      name: '갈비탕',
      icon: '🍖',
      description: '진한 사골 갈비탕',
      color: Colors.brown.shade300,
    ),
    MenuCategory(
      name: '카페',
      icon: '☕',
      description: '아메리카노 & 디저트',
      color: Colors.brown.shade600,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
            return Text(
              '${locationProvider.currentLocation} 인기 메뉴',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
                     // 헤더 설명
           Consumer<LocationProvider>(
             builder: (context, locationProvider, child) {
               return Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     colors: [
                       colorScheme.primaryContainer.withOpacity(0.3),
                       colorScheme.primaryContainer.withOpacity(0.1),
                     ],
                     begin: Alignment.topCenter,
                     end: Alignment.bottomCenter,
                   ),
                 ),
                 child: Column(
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(
                           Icons.trending_up,
                           size: 24,
                           color: colorScheme.primary,
                         ),
                         const SizedBox(width: 8),
                         Text(
                           'TOP 인기 메뉴',
                           style: theme.textTheme.titleSmall?.copyWith(
                             fontWeight: FontWeight.bold,
                             color: colorScheme.primary,
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Text(
                       '${locationProvider.currentLocation}에서 인기 있는 메뉴예요',
                       style: theme.textTheme.titleLarge?.copyWith(
                         fontWeight: FontWeight.bold,
                         color: colorScheme.onSurface,
                       ),
                     ),
                     const SizedBox(height: 4),
                     Text(
                       '${widget.numberOfPeople}명이 함께 드실 메뉴를 골라보세요!',
                       style: theme.textTheme.bodyMedium?.copyWith(
                         color: colorScheme.onSurfaceVariant,
                       ),
                     ),
                   ],
                 ),
               );
             },
           ),

                     // 인기 메뉴 그리드
           Expanded(
             child: Padding(
               padding: const EdgeInsets.all(16),
               child: GridView.builder(
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 3, // 3열로 변경하여 더 많은 메뉴 표시
                   crossAxisSpacing: 8,
                   mainAxisSpacing: 8,
                   childAspectRatio: 0.85, // 카드를 좀 더 세로로 길게
                 ),
                 itemCount: _menuCategories.length,
                 itemBuilder: (context, index) {
                   final category = _menuCategories[index];
                   final isSelected = _selectedCategory == category.name;
                   final rank = index + 1; // 인기 순위 표시
                   
                   return _buildMenuCategoryCard(category, isSelected, rank);
                 },
               ),
             ),
           ),


        ],
      ),
    );
  }

  Widget _buildMenuCategoryCard(MenuCategory category, bool isSelected, int rank) {
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
        onTap: () async {
          setState(() {
            _selectedCategory = category.name;
          });
          // 카테고리 선택 시 바로 추천 결과로 이동
          await _getRecommendationsByCategory(category.name);
        },
      child: Container(
          padding: const EdgeInsets.all(10),
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 상단에 순위 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: rank <= 3 
                          ? (rank == 1 ? Colors.amber : rank == 2 ? Colors.grey : Colors.brown.shade400)
                          : colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        rank.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (rank <= 3)
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.orange,
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 메뉴 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? colorScheme.primary 
                      : category.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    category.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 메뉴 이름
              Text(
                category.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected 
                      ? colorScheme.primary 
                      : colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 4),
              
              // 메뉴 설명
              Expanded(
                child: Text(
                  category.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getRecommendationsByCategory(String categoryName) async {

    final recommendationProvider = context.read<RecommendationProvider>();
    final locationProvider = context.read<LocationProvider>();

    try {
      await recommendationProvider.getRecommendationsByCategory(
        location: locationProvider.currentLocation,
        category: categoryName,
      );

      if (mounted && recommendationProvider.hasRecommendations) {
        // 현재 위치를 UserLocation으로 변환
        final locationService = LocationService();
        final userLocation = await locationService.getLocationFromAddress(locationProvider.currentLocation) 
            ?? const UserLocation(latitude: 37.4979517, longitude: 127.0276188, address: '강남역');
        
        Navigator.of(context).push(
          PageTransitions.heroCard(
            RecommendationResultScreen(
              restaurants: recommendationProvider.recommendations,
              numberOfPeople: widget.numberOfPeople,
              userLocation: userLocation,
              selectedCategory: categoryName,
            ),
            heroTag: 'menuToResult',
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$categoryName 음식점을 찾을 수 없습니다'),
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