import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/page_transitions.dart';
import '../widgets/animated_grid_view.dart';

class RecommendationHistoryScreen extends StatefulWidget {
  final bool showAppBar;
  
  const RecommendationHistoryScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<RecommendationHistoryScreen> createState() => _RecommendationHistoryScreenState();
}

class _RecommendationHistoryScreenState extends State<RecommendationHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadHistories();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  Future<void> _loadHistories() async {
    final historyProvider = context.read<RecommendationHistoryProvider>();
    await historyProvider.refreshHistory();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: widget.showAppBar ? AppBar(
        title: Consumer<RecommendationHistoryProvider>(
          builder: (context, historyProvider, child) {
            return Column(
              children: [
                Text(
                  '추천 이력',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (historyProvider.hasHistories)
                  Text(
                    '총 ${historyProvider.historyCount}개',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            );
          },
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
              HapticFeedback.lightImpact();
            },
            tooltip: '필터',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('새로고침'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('통계 보기'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('백업'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever),
                    SizedBox(width: 8),
                    Text('전체 삭제'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ) : null,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<RecommendationHistoryProvider>(
          builder: (context, historyProvider, child) {
            if (historyProvider.isLoading) {
              return const Center(child: EnhancedLoadingIndicator());
            }

            if (historyProvider.error != null) {
              return ErrorStateWidget(
                title: '이력을 불러올 수 없습니다',
                subtitle: historyProvider.error!,
                onRetry: _loadHistories,
              );
            }

            if (!historyProvider.hasHistories) {
              return EmptyStateWidget(
                title: '추천 이력이 없습니다',
                subtitle: '메뉴를 추천받으면 이곳에 이력이 표시됩니다',
                icon: Icons.history,
                actionText: '메뉴 추천받기',
                onActionPressed: () => Navigator.of(context).pop(),
              );
            }

            return Column(
              children: [
                // 검색 및 필터
                _buildSearchAndFilter(historyProvider),
                
                // 이력 목록
                Expanded(
                  child: _buildHistoryList(historyProvider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(RecommendationHistoryProvider historyProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // 검색바
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: historyProvider.setSearchQuery,
            decoration: InputDecoration(
              hintText: '이력 검색...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        historyProvider.setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
          ),
        ),

        // 필터 옵션
        if (_showFilters)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // 필터 버튼들
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterChip(
                        label: '전체',
                        isSelected: historyProvider.currentFilter == HistoryFilter.all,
                        onSelected: () => historyProvider.setFilter(HistoryFilter.all),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterChip(
                        label: '최근',
                        isSelected: historyProvider.currentFilter == HistoryFilter.recent,
                        onSelected: () => historyProvider.setFilter(HistoryFilter.recent),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterChip(
                        label: '방문함',
                        isSelected: historyProvider.currentFilter == HistoryFilter.visited,
                        onSelected: () => historyProvider.setFilter(HistoryFilter.visited),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterChip(
                        label: '방문 안함',
                        isSelected: historyProvider.currentFilter == HistoryFilter.notVisited,
                        onSelected: () => historyProvider.setFilter(HistoryFilter.notVisited),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // 정렬 옵션
                Row(
                  children: [
                    const Icon(Icons.sort, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '정렬:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<HistorySort>(
                        value: historyProvider.currentSort,
                        isExpanded: true,
                        underline: Container(),
                        onChanged: (sort) {
                          if (sort != null) {
                            historyProvider.setSort(sort);
                            HapticFeedback.selectionClick();
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: HistorySort.dateDesc,
                            child: Text('최신순'),
                          ),
                          DropdownMenuItem(
                            value: HistorySort.dateAsc,
                            child: Text('오래된순'),
                          ),
                          DropdownMenuItem(
                            value: HistorySort.restaurantCount,
                            child: Text('추천 개수순'),
                          ),
                          DropdownMenuItem(
                            value: HistorySort.category,
                            child: Text('카테고리순'),
                          ),
                          DropdownMenuItem(
                            value: HistorySort.location,
                            child: Text('위치순'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        onSelected();
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildHistoryList(RecommendationHistoryProvider historyProvider) {
    final histories = historyProvider.filteredHistories;

    return RefreshIndicator(
      onRefresh: _loadHistories,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: histories.length,
        itemBuilder: (context, index) {
          final history = histories[index];
          return _buildHistoryCard(history, index);
        },
      ),
    );
  }

  Widget _buildHistoryCard(RecommendationHistory history, int index) {
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
        onTap: () => _showHistoryDetail(history),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (날짜, 방문 여부)
              Row(
                children: [
                  // 추천 방식 아이콘
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: history.source == RecommendationSource.swipe
                          ? Colors.blue.shade100
                          : Colors.purple.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      history.source == RecommendationSource.swipe
                          ? Icons.swipe
                          : Icons.grid_view,
                      size: 16,
                      color: history.source == RecommendationSource.swipe
                          ? Colors.blue.shade700
                          : Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history.summaryText,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${history.dateText} ${history.timeText}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 방문 여부 표시
                  if (history.wasVisited)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '방문함',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 추천 정보
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.restaurant_menu,
                      label: history.selectedCategory,
                      color: colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.people,
                      label: '${history.numberOfPeople}명',
                      color: colorScheme.secondary,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.store,
                      label: '${history.restaurantCount}곳',
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              
              // 노트 (있는 경우)
              if (history.note != null && history.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '📝 ${history.note}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              
              // 태그 (있는 경우)
              if (history.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: history.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showHistoryDetail(RecommendationHistory history) {
    // TODO: 이력 상세보기 다이얼로그 또는 화면 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(history.selectedCategory),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('위치: ${history.location}'),
            Text('날짜: ${history.dateText} ${history.timeText}'),
            Text('인원: ${history.numberOfPeople}명'),
            Text('추천 음식점: ${history.restaurantCount}곳'),
            if (history.wasVisited) Text('방문: ${history.visitedRestaurant?.name ?? "예"}'),
            if (history.note != null) Text('노트: ${history.note}'),
          ],
        ),
        actions: [
          if (!history.wasVisited)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _markAsVisited(history);
              },
              child: const Text('방문 표시'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _markAsVisited(RecommendationHistory history) {
    // 첫 번째 음식점을 방문한 것으로 표시 (임시)
    if (history.recommendedRestaurants.isNotEmpty) {
      final firstRestaurant = history.recommendedRestaurants.first;
      final historyProvider = context.read<RecommendationHistoryProvider>();
      
      historyProvider.markAsVisited(
        history.id,
        firstRestaurant.id,
        note: '방문 완료',
      );
    }
  }

  void _handleMenuAction(String action) async {
    final historyProvider = context.read<RecommendationHistoryProvider>();
    
    switch (action) {
      case 'refresh':
        HapticFeedback.lightImpact();
        await _loadHistories();
        break;
        
      case 'stats':
        _showStatsDialog();
        break;
        
      case 'export':
        _exportHistory();
        break;
        
      case 'clear':
        _showClearConfirmDialog();
        break;
    }
  }

  void _showStatsDialog() async {
    final historyProvider = context.read<RecommendationHistoryProvider>();
    final stats = await historyProvider.getHistoryStats();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 추천 이력 통계'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('총 추천 횟수: ${stats.totalCount}번'),
            Text('방문 횟수: ${stats.visitedCount}번'),
            Text('방문율: ${stats.visitRatioPercentText}'),
            if (stats.mostFrequentCategory != null)
              Text('자주 찾는 메뉴: ${stats.mostFrequentCategory}'),
            if (stats.mostFrequentLocation != null)
              Text('자주 가는 위치: ${stats.mostFrequentLocation}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _exportHistory() async {
    final historyProvider = context.read<RecommendationHistoryProvider>();
    final exported = await historyProvider.exportHistory();
    
    if (mounted && exported != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이력을 백업했습니다'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // TODO: 실제 파일 저장 또는 공유 기능 구현
    }
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ 전체 삭제'),
        content: const Text('모든 추천 이력을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllHistory();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _clearAllHistory() async {
    final historyProvider = context.read<RecommendationHistoryProvider>();
    final success = await historyProvider.clearAllHistory();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '모든 이력을 삭제했습니다' : '삭제에 실패했습니다',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
} 