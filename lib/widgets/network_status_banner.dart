import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/network_service.dart';

/// 네트워크 상태를 표시하는 배너 위젯
class NetworkStatusBanner extends StatelessWidget {
  final Widget child;
  final bool showWhenOnline;
  
  const NetworkStatusBanner({
    super.key,
    required this.child,
    this.showWhenOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkStatusProvider>(
      builder: (context, networkProvider, _) {
        return Column(
          children: [
            // 네트워크 상태 배너
            if (_shouldShowBanner(networkProvider.status))
              _buildStatusBanner(context, networkProvider.status),
            
            // 메인 콘텐츠
            Expanded(child: child),
          ],
        );
      },
    );
  }

  bool _shouldShowBanner(NetworkStatus status) {
    if (status == NetworkStatus.offline) {
      return true; // 오프라인 시 항상 표시
    }
    
    if (status == NetworkStatus.online && showWhenOnline) {
      return true; // 온라인 상태 표시가 활성화된 경우
    }
    
    return false;
  }

  Widget _buildStatusBanner(BuildContext context, NetworkStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (status) {
      case NetworkStatus.online:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.wifi;
        break;
      case NetworkStatus.offline:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.wifi_off;
        break;
      case NetworkStatus.unknown:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        icon = Icons.wifi_find;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: textColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getStatusMessage(status),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (status == NetworkStatus.offline)
            _buildRetryButton(context, textColor),
        ],
      ),
    );
  }

  String _getStatusMessage(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.online:
        return '인터넷에 연결됨';
      case NetworkStatus.offline:
        return '오프라인 모드 - 캐시된 데이터를 사용 중';
      case NetworkStatus.unknown:
        return '네트워크 상태 확인 중...';
    }
  }

  Widget _buildRetryButton(BuildContext context, Color textColor) {
    return InkWell(
      onTap: () async {
        final networkProvider = context.read<NetworkStatusProvider>();
        await networkProvider.refresh();
        
        // 재시도 피드백
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('네트워크 상태를 다시 확인했습니다'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              size: 14,
              color: textColor,
            ),
            const SizedBox(width: 4),
            Text(
              '재시도',
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 간단한 네트워크 상태 표시 위젯
class NetworkStatusIndicator extends StatelessWidget {
  final double? size;
  final bool showText;
  
  const NetworkStatusIndicator({
    super.key,
    this.size,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkStatusProvider>(
      builder: (context, networkProvider, _) {
        final status = networkProvider.status;
        final iconSize = size ?? 16;
        
        Color color;
        IconData icon;
        
        switch (status) {
          case NetworkStatus.online:
            color = Colors.green;
            icon = Icons.wifi;
            break;
          case NetworkStatus.offline:
            color = Colors.orange;
            icon = Icons.wifi_off;
            break;
          case NetworkStatus.unknown:
            color = Colors.grey;
            icon = Icons.wifi_find;
            break;
        }

        if (showText) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: color),
              const SizedBox(width: 4),
              Text(
                status.message,
                style: TextStyle(
                  color: color,
                  fontSize: iconSize * 0.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }

        return Icon(icon, size: iconSize, color: color);
      },
    );
  }
}
