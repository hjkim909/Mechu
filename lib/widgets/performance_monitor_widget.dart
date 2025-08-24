import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/services.dart';

/// 성능 모니터링 위젯 (디버그 모드에서만 사용)
class PerformanceMonitorWidget extends StatefulWidget {
  final Widget child;

  const PerformanceMonitorWidget({
    super.key,
    required this.child,
  });

  @override
  State<PerformanceMonitorWidget> createState() => _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  final HttpService _httpService = HttpService();
  bool _showMonitor = false;
  Map<String, dynamic> _cacheStatus = {};

  @override
  void initState() {
    super.initState();
    _updateCacheStatus();
  }

  void _updateCacheStatus() {
    if (mounted) {
      setState(() {
        _cacheStatus = _httpService.getCacheStatus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        
        // 디버그 모드에서만 표시
        if (kDebugMode) ...[
          // 성능 모니터 토글 버튼
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: "performance_monitor",
              backgroundColor: Colors.black54,
              onPressed: () {
                setState(() {
                  _showMonitor = !_showMonitor;
                });
                _updateCacheStatus();
              },
              child: Icon(
                _showMonitor ? Icons.visibility_off : Icons.speed,
                color: Colors.white,
              ),
            ),
          ),

          // 성능 정보 패널
          if (_showMonitor)
            Positioned(
              top: MediaQuery.of(context).padding.top + 110,
              right: 16,
              child: Container(
                width: 280,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '⚡ 성능 모니터',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                          onPressed: _updateCacheStatus,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // HTTP 캐시 정보
                    _buildMetricRow(
                      '📦 캐시된 요청',
                      '${_cacheStatus['cached_requests'] ?? 0}개',
                      Colors.blue,
                    ),
                    _buildMetricRow(
                      '⏱️ 캐시 만료시간',
                      '${_cacheStatus['cache_expiry_minutes'] ?? 0}분',
                      Colors.green,
                    ),
                    _buildMetricRow(
                      '🔄 요청 타임아웃',
                      '${_cacheStatus['request_timeout_seconds'] ?? 0}초',
                      Colors.orange,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 캐시 제어 버튼
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _httpService.clearCache();
                              _updateCacheStatus();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('캐시가 초기화되었습니다'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                            ),
                            child: const Text(
                              '캐시 초기화',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // 네트워크 상태 확인
                    FutureBuilder<bool>(
                      future: _httpService.isConnected(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text(
                            '🌐 연결 상태 확인 중...',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          );
                        }
                        
                        final isConnected = snapshot.data ?? false;
                        return Text(
                          isConnected ? '🌐 네트워크 연결됨' : '❌ 네트워크 연결 안됨',
                          style: TextStyle(
                            color: isConnected ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
