import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../models/models.dart';

class RecommendationResultScreen extends StatefulWidget {
  final List<Restaurant> restaurants;
  final int numberOfPeople;
  final UserLocation userLocation;
  final String? selectedCategory;

  const RecommendationResultScreen({
    super.key,
    required this.restaurants,
    required this.numberOfPeople,
    required this.userLocation,
    this.selectedCategory,
  });

  @override
  State<RecommendationResultScreen> createState() => _RecommendationResultScreenState();
}

class _RecommendationResultScreenState extends State<RecommendationResultScreen> {
  late KakaoMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    for (final restaurant in widget.restaurants) {
      if (restaurant.latitude != 0.0 && restaurant.longitude != 0.0) {
        _markers.add(
          Marker(
            markerId: restaurant.id,
            latLng: LatLng(restaurant.latitude, restaurant.longitude),
            infoWindowContent: restaurant.name,
          ),
        );
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
          widget.selectedCategory != null 
              ? '${widget.selectedCategory} 맛집 ${widget.restaurants.length}곳'
              : '${widget.numberOfPeople}명을 위한 추천',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: widget.restaurants.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                // 지도 표시 (조건부)
                if (widget.restaurants.isNotEmpty && _markers.isNotEmpty)
                  _buildMapView(),
                Expanded(
                  child: _buildRecommendationList(context),
                ),
              ],
            ),
    );
  }

  Widget _buildMapView() {
    return Container(
      height: 250,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: KakaoMap(
          onMapCreated: (controller) {
            _mapController = controller;
          },
          markers: _markers.toList(),
          center: LatLng(widget.userLocation.latitude, widget.userLocation.longitude),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '추천할 음식점이 없습니다',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 조건으로 다시 검색해보세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // 헤더 정보
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.userLocation.address ?? '현재 위치',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.restaurants.length}개 음식점',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 음식점 목록
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = widget.restaurants[index];
              return _buildRestaurantCard(context, restaurant, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Restaurant restaurant, int rank) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (restaurant.latitude != 0.0 && restaurant.longitude != 0.0) {
            _mapController.setCenter(LatLng(restaurant.latitude, restaurant.longitude));
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${restaurant.name} 상세 정보'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 순위 뱃지
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: rank <= 3 ? colorScheme.primary : colorScheme.outline,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: rank <= 3 ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 음식점 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              restaurant.category,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              restaurant.priceLevelText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 영업 상태
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: restaurant.isOpen ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      restaurant.isOpen ? '영업중' : '영업종료',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 평점과 주소
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.orange[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.ratingText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      restaurant.address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 