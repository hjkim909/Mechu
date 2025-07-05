import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();
  
  User? _currentUser;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _locationPermissionEnabled = true;
  String _selectedTheme = 'system'; // system, light, dark

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _userService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      _showErrorSnackBar('사용자 정보를 불러올 수 없습니다');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserPreferences() async {
    if (_currentUser == null) return;

    try {
      // TODO: 사용자 설정 저장 로직 구현
      _showSuccessSnackBar('설정이 저장되었습니다');
    } catch (e) {
      _showErrorSnackBar('설정 저장 중 오류가 발생했습니다');
    }
  }

  void _showUserProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => _UserProfileDialog(
        user: _currentUser,
        onSave: (updatedUser) {
          setState(() {
            _currentUser = updatedUser;
          });
        },
      ),
    );
  }

  void _showFoodPreferencesDialog() {
    showDialog(
      context: context,
      builder: (context) => _FoodPreferencesDialog(
        user: _currentUser,
        onSave: (updatedUser) {
          setState(() {
            _currentUser = updatedUser;
          });
        },
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: '메뉴 추천 앱',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Mechu. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text('맛있는 메뉴를 추천해드리는 앱입니다.'),
        const SizedBox(height: 8),
        const Text('개발자: Mechu Team'),
      ],
    );
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
          '설정',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 사용자 프로필 섹션
                _buildSectionTitle('사용자 프로필', Icons.person),
                const SizedBox(height: 8),
                _buildProfileCard(),

                const SizedBox(height: 24),

                // 음식 설정 섹션
                _buildSectionTitle('음식 설정', Icons.restaurant_menu),
                const SizedBox(height: 8),
                _buildFoodPreferencesCard(),

                const SizedBox(height: 24),

                // 앱 설정 섹션
                _buildSectionTitle('앱 설정', Icons.settings),
                const SizedBox(height: 8),
                _buildAppSettingsCard(),

                const SizedBox(height: 24),

                // 정보 섹션
                _buildSectionTitle('정보', Icons.info),
                const SizedBox(height: 8),
                _buildInfoCard(),

                const SizedBox(height: 32),
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

  Widget _buildProfileCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUser?.name ?? '사용자',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '프로필을 수정하려면 터치하세요',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showUserProfileDialog,
                icon: const Icon(Icons.edit),
                label: const Text('프로필 수정'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodPreferencesCard() {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            '음식 선호도',
            '좋아하는 음식 종류를 설정하세요',
            Icons.favorite,
            onTap: _showFoodPreferencesDialog,
          ),
          const Divider(height: 1),
          _buildSettingTile(
            '알레르기 정보',
            '알레르기 유발 식품을 설정하세요',
            Icons.warning,
            onTap: _showFoodPreferencesDialog,
          ),
          const Divider(height: 1),
          _buildSettingTile(
            '가격대 설정',
            '선호하는 가격대를 설정하세요',
            Icons.attach_money,
            onTap: _showFoodPreferencesDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsCard() {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            '알림 설정',
            '추천 및 이벤트 알림을 받습니다',
            Icons.notifications,
            _notificationsEnabled,
            (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _updateUserPreferences();
            },
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            '위치 권한',
            '현재 위치 기반 추천을 받습니다',
            Icons.location_on,
            _locationPermissionEnabled,
            (value) {
              setState(() {
                _locationPermissionEnabled = value;
              });
              _updateUserPreferences();
            },
          ),
          const Divider(height: 1),
          _buildSettingTile(
            '테마 설정',
            _getThemeDisplayName(_selectedTheme),
            Icons.palette,
            onTap: _showThemeDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            '앱 정보',
            '버전 및 개발자 정보',
            Icons.info_outline,
            onTap: _showAboutDialog,
          ),
          const Divider(height: 1),
          _buildSettingTile(
            '이용약관',
            '서비스 이용약관을 확인하세요',
            Icons.description,
            onTap: () {
              // TODO: 이용약관 화면으로 이동
              _showErrorSnackBar('준비 중인 기능입니다');
            },
          ),
          const Divider(height: 1),
          _buildSettingTile(
            '개인정보 처리방침',
            '개인정보 보호 정책을 확인하세요',
            Icons.privacy_tip,
            onTap: () {
              // TODO: 개인정보 처리방침 화면으로 이동
              _showErrorSnackBar('준비 중인 기능입니다');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: colorScheme.outline,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return '라이트 모드';
      case 'dark':
        return '다크 모드';
      case 'system':
      default:
        return '시스템 설정';
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테마 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('시스템 설정'),
              value: 'system',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.of(context).pop();
                _updateUserPreferences();
              },
            ),
            RadioListTile<String>(
              title: const Text('라이트 모드'),
              value: 'light',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.of(context).pop();
                _updateUserPreferences();
              },
            ),
            RadioListTile<String>(
              title: const Text('다크 모드'),
              value: 'dark',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.of(context).pop();
                _updateUserPreferences();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}

// 사용자 프로필 다이얼로그
class _UserProfileDialog extends StatefulWidget {
  final User? user;
  final Function(User) onSave;

  const _UserProfileDialog({
    required this.user,
    required this.onSave,
  });

  @override
  State<_UserProfileDialog> createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends State<_UserProfileDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('프로필 수정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '이름',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              final updatedUser = widget.user?.copyWith(
                name: _nameController.text.trim(),
              ) ?? User.create(
                id: 'user_001',
                name: _nameController.text.trim(),
              );
              widget.onSave(updatedUser);
              Navigator.of(context).pop();
            }
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}

// 음식 선호도 다이얼로그
class _FoodPreferencesDialog extends StatefulWidget {
  final User? user;
  final Function(User) onSave;

  const _FoodPreferencesDialog({
    required this.user,
    required this.onSave,
  });

  @override
  State<_FoodPreferencesDialog> createState() => _FoodPreferencesDialogState();
}

class _FoodPreferencesDialogState extends State<_FoodPreferencesDialog> {
  List<String> _favoriteCategories = [];
  List<String> _dislikedCategories = [];
  List<String> _allergies = [];
  int _preferredPriceLevel = 2;

  final List<String> _availableCategories = [
    '한식', '중식', '일식', '양식', '분식', '치킨', '피자', '햄버거', '카페', '디저트'
  ];

  final List<String> _availableAllergies = [
    '견과류', '갑각류', '계란', '우유', '대두', '밀', '생선', '조개류'
  ];

  @override
  void initState() {
    super.initState();
    final preferences = widget.user?.preferences;
    _favoriteCategories = List.from(preferences?.favoriteCategories ?? []);
    _dislikedCategories = List.from(preferences?.dislikedCategories ?? []);
    _allergies = List.from(preferences?.allergies ?? []);
    _preferredPriceLevel = preferences?.preferredPriceLevel ?? 2;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('음식 선호도'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('좋아하는 음식 종류'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableCategories.map((category) {
                  final isSelected = _favoriteCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCategories.add(category);
                          _dislikedCategories.remove(category);
                        } else {
                          _favoriteCategories.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              const Text('알레르기 정보'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableAllergies.map((allergy) {
                  final isSelected = _allergies.contains(allergy);
                  return FilterChip(
                    label: Text(allergy),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _allergies.add(allergy);
                        } else {
                          _allergies.remove(allergy);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              Text('선호 가격대: ${_getPriceLevelText(_preferredPriceLevel)}'),
              Slider(
                value: _preferredPriceLevel.toDouble(),
                min: 1,
                max: 4,
                divisions: 3,
                label: _getPriceLevelText(_preferredPriceLevel),
                onChanged: (value) {
                  setState(() {
                    _preferredPriceLevel = value.round();
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedPreferences = UserPreferences(
              favoriteCategories: _favoriteCategories,
              dislikedCategories: _dislikedCategories,
              preferredPriceLevel: _preferredPriceLevel,
              minRating: widget.user?.preferences?.minRating ?? 4.0,
              vegetarian: widget.user?.preferences?.vegetarian ?? false,
              halal: widget.user?.preferences?.halal ?? false,
              allergies: _allergies,
            );

            final updatedUser = widget.user?.copyWith(
              preferences: updatedPreferences,
            ) ?? User.create(
              id: 'user_001',
              name: '사용자',
              preferences: updatedPreferences,
            );

            widget.onSave(updatedUser);
            Navigator.of(context).pop();
          },
          child: const Text('저장'),
        ),
      ],
    );
  }

  String _getPriceLevelText(int level) {
    switch (level) {
      case 1:
        return '저렴 (1만원 이하)';
      case 2:
        return '보통 (1-2만원)';
      case 3:
        return '비쌈 (2-3만원)';
      case 4:
        return '매우 비쌈 (3만원 이상)';
      default:
        return '보통';
    }
  }
} 