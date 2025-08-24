import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_navigation_screen.dart';
import 'providers/providers.dart';
import 'services/services.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // SharedPreferences 초기화
  await PreferencesService.init();

  // Kakao Map SDK 초기화
  AuthRepository.initialize(appKey: ConfigService().kakaoJsApiKey);
  
  runApp(const MenuRecommendationApp());
}

class MenuRecommendationApp extends StatelessWidget {
  const MenuRecommendationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationHistoryProvider()),
        ChangeNotifierProvider(create: (_) => NetworkStatusProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: '메뉴 추천 앱',
            themeMode: themeProvider.themeMode,
            theme: _getLightTheme(),
            darkTheme: _getDarkTheme(),
            home: const AppInitializer(),
          );
        },
      ),
    );
  }

  /// 라이트 테마 정의
  ThemeData _getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepOrange,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  /// 다크 테마 정의
  ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepOrange,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}

/// 앱 초기화 위젯
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// 앱 초기화
  Future<void> _initializeApp() async {
    final themeProvider = context.read<ThemeProvider>();
    final userProvider = context.read<UserProvider>();
    final locationProvider = context.read<LocationProvider>();

    // 앱 설정 초기화
    ConfigService().setDevelopmentApiKey();

    // API 키 유효성 검사
    final kakaoApiService = KakaoApiService();
    final isKakaoKeyValid = await kakaoApiService.isApiKeyValid();
    print('========================================');
    print('Kakao API Key 유효성: $isKakaoKeyValid');
    print('========================================');

    // 테마 초기화
    await themeProvider.initializeTheme();
    
    // 사용자 및 위치 정보 초기화
    await userProvider.initializeUser();
    await locationProvider.initializeLocation();
    await locationProvider.loadFavoriteLocations();
    
    // 즐겨찾기 초기화
    final favoriteProvider = context.read<FavoriteProvider>();
    await favoriteProvider.initializeFavorites();
    
    // 추천 이력 초기화
    final historyProvider = context.read<RecommendationHistoryProvider>();
    await historyProvider.initializeHistory();
  }

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
} 