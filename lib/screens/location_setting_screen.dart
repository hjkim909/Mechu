import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class LocationSettingScreen extends StatefulWidget {
  const LocationSettingScreen({super.key});

  @override
  State<LocationSettingScreen> createState() => _LocationSettingScreenState();
}

class _LocationSettingScreenState extends State<LocationSettingScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  
  UserLocation? _currentLocation;
  List<String> _favoriteLocations = [];
  List<String> _nearbyAreas = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _loadFavoriteLocations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final location = await _locationService.getCurrentLocation();
      final nearbyAreas = _locationService.getNearbyAreas(location);
      
      setState(() {
        _currentLocation = location;
        _nearbyAreas = nearbyAreas;
      });
    } catch (e) {
      _showErrorSnackBar('현재 위치를 가져올 수 없습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavoriteLocations() async {
    // TODO: SharedPreferences에서 즐겨찾기 위치 로드
    setState(() {
      _favoriteLocations = ['강남역', '홍대입구역', '명동역']; // 임시 데이터
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final location = await _locationService.getLocationFromAddress(query);
      if (location != null) {
        _selectLocation(location);
      } else {
        _showErrorSnackBar('위치를 찾을 수 없습니다: $query');
      }
    } catch (e) {
      _showErrorSnackBar('검색 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _selectLocation(UserLocation location) {
    Navigator.of(context).pop(location);
  }

  void _addToFavorites(String locationName) {
    if (!_favoriteLocations.contains(locationName)) {
      setState(() {
        _favoriteLocations.add(locationName);
      });
      // TODO: SharedPreferences에 저장
      _showSuccessSnackBar('$locationName이(가) 즐겨찾기에 추가되었습니다');
    }
  }

  void _removeFromFavorites(String locationName) {
    setState(() {
      _favoriteLocations.remove(locationName);
    });
    // TODO: SharedPreferences에서 제거
    _showSuccessSnackBar('$locationName이(가) 즐겨찾기에서 제거되었습니다');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '위치 설정',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 검색 바
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '지역명을 입력하세요 (예: 강남역, 홍대입구역)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              onSubmitted: _searchLocation,
            ),
          ),

          // 현재 위치 섹션
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 현재 위치
                _buildSectionTitle('현재 위치', Icons.my_location),
                const SizedBox(height: 8),
                if (_isLoading)
                  _buildLoadingCard()
                else if (_currentLocation != null)
                  _buildLocationCard(
                    _currentLocation!.address ?? '알 수 없는 위치',
                    '현재 위치',
                    Icons.location_on,
                    () => _selectLocation(_currentLocation!),
                    showFavoriteButton: true,
                    onFavoritePressed: () => _addToFavorites(_currentLocation!.address ?? '현재 위치'),
                  ),

                const SizedBox(height: 24),

                // 즐겨찾기 위치
                _buildSectionTitle('즐겨찾기', Icons.favorite),
                const SizedBox(height: 8),
                if (_favoriteLocations.isEmpty)
                  _buildEmptyCard('즐겨찾기 위치가 없습니다')
                else
                  ..._favoriteLocations.map((location) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildLocationCard(
                          location,
                          '즐겨찾기',
                          Icons.favorite,
                          () async {
                            final locationData = await _locationService.getLocationFromAddress(location);
                            if (locationData != null) {
                              _selectLocation(locationData);
                            }
                          },
                          showFavoriteButton: false,
                          showDeleteButton: true,
                          onDeletePressed: () => _removeFromFavorites(location),
                        ),
                      )),

                const SizedBox(height: 24),

                // 근처 지역
                _buildSectionTitle('근처 지역', Icons.near_me),
                const SizedBox(height: 8),
                if (_nearbyAreas.isEmpty)
                  _buildEmptyCard('근처 지역 정보가 없습니다')
                else
                  ..._nearbyAreas.map((area) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildLocationCard(
                          area,
                          '근처 지역',
                          Icons.place,
                          () async {
                            final locationData = await _locationService.getLocationFromAddress(area);
                            if (locationData != null) {
                              _selectLocation(locationData);
                            }
                          },
                          showFavoriteButton: true,
                          onFavoritePressed: () => _addToFavorites(area),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(
    String locationName,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool showFavoriteButton = false,
    bool showDeleteButton = false,
    VoidCallback? onFavoritePressed,
    VoidCallback? onDeletePressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (showFavoriteButton)
                IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: colorScheme.outline,
                  ),
                  onPressed: onFavoritePressed,
                ),
              if (showDeleteButton)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red[400],
                  ),
                  onPressed: onDeletePressed,
                ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '현재 위치를 가져오는 중...',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
} 