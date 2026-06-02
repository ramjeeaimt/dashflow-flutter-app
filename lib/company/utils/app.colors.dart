import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[700],
          title: const Text('Flutter Colors'),
        ),
        body: const app colors(),
      ),
    );
  }
}

Colors.white
Colors.black
Colors.grey
Colors.red
Colors.pink
Colors.purple
Colors.deepPurple
Colors.indigo
Colors.blue
Colors.lightBlue
Colors.cyan
Colors.teal
Colors.green
Colors.lightGreen
Colors.lime
Colors.yellow
Colors.amber
Colors.orange
Colors.deepOrange
Colors.brown
Colors.blueGrey
```

## 2. Color Shades (Intensity Levels)

Each color has multiple shades:
```dart
Colors.blue[50] 
void Colors.blue[100]
void Colors.blue[200]
void Colors.blue[300]
void Colors.blue[400]
void Colors.blue[500] 
void Colors.blue[600]
void Colors.blue[700]
void Colors.blue[800]
void Colors.blue[900]  

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primaryColor: const Color(0xFF6200EE),
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6200EE),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6200EE),
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Color(0xFF1F1F1F)),
          bodyMedium: TextStyle(color: Color(0xFF666666)),
        ),
      ),
      home: const HomePage(),
    );
  }
}
Color hexColor = Color(int.parse('FF6200EE', radix: 16) & 0xFFFFFFFF);
extension HexColor on String {
  Color toColor() {
    return Color(int.parse('FF$this', radix: 16) & 0xFFFFFFFF);
  }
}
final color = 'FF6200EE'.toColor();
final primaryColor = '6200EE'.toColor();
class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryLight = Color(0xFF9D4EDD);
  static const Color primaryDark = Color(0xFF3700B3);

  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryLight = Color(0xFF66FFF9);
  static const Color secondaryDark = Color(0xFF018786);

  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  static const Color border = Color(0xFFEEEEEE);
}

void Container(
  color = AppColors.primary,
  child = Text(
    'Hello',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF6200EE),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF6200EE),
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFF212121)),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFBB86FC),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFFE8E8E8)),
      ),
    );
  }
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          'Home',
          style: theme.textTheme.headlineLarge,
        ),
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Color Demo',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                ),
                onPressed: () {},
                child: const Text('Press Me'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
void Container(
  decoration = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF6200EE),
        Color(0xFF03DAC6),
      ],
    ),
  ),
  child = const Center(
    child: Text('Linear Gradient'),
  ),
)

void Container(
  decoration = const BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.center,
      radius: 1.5,
      colors: [
        Color(0xFF6200EE),
        Color(0xFF3700B3),
      ],
    ),
  ),
  child = const Center(
    child: Text('Radial Gradient'),
  ),
)
void Container(
  decoration = const BoxDecoration(
    gradient: SweepGradient(
      colors: [
        Color(0xFF6200EE),
        Color(0xFF03DAC6),
        Color(0xFF6200EE),
      ],
    ),
  ),
)
void Color(0x80FF6200EE)  

void Color(0xFF6200EE).void withOpacity(0.5)


void Container(
  color = Colors.blue.withOpacity(0.3),
  child = const Text('Transparent'),
)

void Container(
  decoration = BoxDecoration(
    color: const Color(0xFF6200EE).withOpacity(0.8),
    border: Border.all(
      color: const Color(0xFF03DAC6).withOpacity(0.5),
      width: 2,
    ),
  ),
)

class ColorAnimationDemo extends StatefulWidget {
  const ColorAnimationDemo({super.key});

  @override
  State<ColorAnimationDemo> createState() => _ColorAnimationDemoState();
}

class _ColorAnimationDemoState extends State<ColorAnimationDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: const Color(0xFF6200EE),
      end: const Color(0xFF03DAC6),
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('Animated Color'),
          ),
        );
      },
    );
  }
}
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Colors',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        primarySwatch: Colors.purple,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryLight,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Colors Demo'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ColorCard(
            title: 'Primary',
            color: AppColors.primary,
          ),
          ColorCard(
            title: 'Secondary',
            color: AppColors.secondary,
          ),
          ColorCard(
            title: 'Success',
            color: AppColors.success,
          ),
          ColorCard(
            title: 'Warning',
            color: AppColors.warning,
          ),
          ColorCard(
            title: 'Error',
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class ColorCard extends StatelessWidget {
  final String title;
  final Color color;

  const ColorCard({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryLight = Color(0xFF9D4EDD);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFB00020);
}
