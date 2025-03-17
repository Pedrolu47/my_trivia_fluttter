import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';

/// Modelo de datos para las preguntas de trivia
class TriviaQuestion {
  final String category;
  final String type;
  final String difficulty;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> allAnswers; // Todas las respuestas mezcladas

  TriviaQuestion({
    required this.category,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  }) : allAnswers = [] {
    // Mezclar todas las respuestas al crear el objeto
    allAnswers.addAll(incorrectAnswers);
    allAnswers.add(correctAnswer);
    allAnswers.shuffle();
  }

  // Método de fábrica para crear un objeto TriviaQuestion desde JSON
  factory TriviaQuestion.fromJson(Map<String, dynamic> json, HtmlUnescape htmlUnescape) {
    return TriviaQuestion(
      category: json['category'],
      type: json['type'],
      difficulty: json['difficulty'],
      question: htmlUnescape.convert(json['question']),
      correctAnswer: htmlUnescape.convert(json['correct_answer']),
      incorrectAnswers: List<String>.from(
        json['incorrect_answers'].map((answer) => htmlUnescape.convert(answer)),
      ),
    );
  }

  // Método para obtener un ícono basado en la categoría
  IconData getCategoryIcon() {
    if (category.contains('Science')) return Icons.science;
    if (category.contains('History')) return Icons.history;
    if (category.contains('Geography')) return Icons.public;
    if (category.contains('Entertainment')) {
      if (category.contains('Film')) return Icons.movie;
      if (category.contains('Music')) return Icons.music_note;
      if (category.contains('Television')) return Icons.tv;
      if (category.contains('Video Games')) return Icons.videogame_asset;
      if (category.contains('Books')) return Icons.book;
      return Icons.theaters;
    }
    if (category.contains('Sports')) return Icons.sports;
    if (category.contains('Art')) return Icons.palette;
    if (category.contains('Celebrities')) return Icons.person;
    if (category.contains('Animals')) return Icons.pets;
    if (category.contains('Vehicles')) return Icons.directions_car;
    if (category.contains('Computers')) return Icons.computer;
    if (category.contains('Mathematics')) return Icons.calculate;
    if (category.contains('Mythology')) return Icons.auto_stories;
    if (category.contains('Politics')) return Icons.gavel;
    return Icons.lightbulb;
  }

  // Método para obtener un color basado en la dificultad
  Color getDifficultyColor() {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

/// Servicio para obtener datos de la API de Trivia
class TriviaService {
  final HtmlUnescape htmlUnescape = HtmlUnescape();
  
  // Método para obtener categorías de trivia
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final url = Uri.parse('https://opentdb.com/api_category.php');
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['trivia_categories']);
      } else {
        throw Exception('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Método para obtener preguntas de trivia con filtros
  Future<List<TriviaQuestion>> fetchQuestions({
    int amount = 10,
    String? category,
    String difficulty = 'easy',
    String type = 'multiple',
  }) async {
    // Construir URL con parámetros
    final queryParams = {
      'amount': amount.toString(),
      'type': type,
    };
    
    // Añadir dificultad si no es vacía
    if (difficulty.isNotEmpty) {
      queryParams['difficulty'] = difficulty;
    }
    
    // Añadir categoría si está especificada
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    
    final uri = Uri.https('opentdb.com', '/api.php', queryParams);
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Verificar el código de respuesta de la API
        if (data['response_code'] != 0) {
          throw Exception('Error en la API: código ${data['response_code']}');
        }
        
        // Convertir los resultados a objetos TriviaQuestion
        return List<TriviaQuestion>.from(
          data['results'].map((json) => TriviaQuestion.fromJson(json, htmlUnescape))
        );
      } else {
        throw Exception('Error al cargar preguntas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}

void main() {
  runApp(const TriviaApp());
}

class TriviaApp extends StatelessWidget {
  const TriviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivia Challenge',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.system, // Usar el tema del sistema
      home: const HomeScreen(),
    );
  }
}

/// Pantalla de inicio con opciones de juego
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo o título
                const Icon(
                  Icons.lightbulb,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'TRIVIA CHALLENGE',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Test your knowledge!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 60),
                
                // Botones de opciones
                HomeMenuButton(
                  icon: Icons.play_arrow,
                  label: 'Quick Play',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TriviaScreen(
                          amount: 10,
                          difficulty: 'easy',
                        ),
                      ),
                    );
                  },
                ),
                
                HomeMenuButton(
                  icon: Icons.category,
                  label: 'Categories',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryScreen(),
                      ),
                    );
                  },
                ),
                
                HomeMenuButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Información adicional
                const Text(
                  'Powered by Open Trivia Database',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón personalizado para el menú principal
class HomeMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const HomeMenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(double.infinity, 60),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Pantalla de selección de categorías
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TriviaService _triviaService = TriviaService();
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _triviaService.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Lista de categorías
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _categoriesFuture = _triviaService.fetchCategories();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories found'));
                } else {
                  // Filtrar categorías según la búsqueda
                  final categories = snapshot.data!.where((category) {
                    return category['name'].toString().toLowerCase().contains(_searchQuery);
                  }).toList();
                  
                  return categories.isEmpty
                      ? const Center(child: Text('No matching categories'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return CategoryCard(
                              name: category['name'],
                              id: category['id'].toString(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DifficultyScreen(
                                      categoryId: category['id'].toString(),
                                      categoryName: category['name'],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta para mostrar una categoría
class CategoryCard extends StatelessWidget {
  final String name;
  final String id;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.id,
    required this.onTap,
  });

  IconData _getCategoryIcon() {
    if (name.contains('Science')) return Icons.science;
    if (name.contains('History')) return Icons.history;
    if (name.contains('Geography')) return Icons.public;
    if (name.contains('Entertainment')) {
      if (name.contains('Film')) return Icons.movie;
      if (name.contains('Music')) return Icons.music_note;
      if (name.contains('Television')) return Icons.tv;
      if (name.contains('Video Games')) return Icons.videogame_asset;
      if (name.contains('Books')) return Icons.book;
      return Icons.theaters;
    }
    if (name.contains('Sports')) return Icons.sports;
    if (name.contains('Art')) return Icons.palette;
    if (name.contains('Celebrities')) return Icons.person;
    if (name.contains('Animals')) return Icons.pets;
    if (name.contains('Vehicles')) return Icons.directions_car;
    if (name.contains('Computers')) return Icons.computer;
    if (name.contains('Mathematics')) return Icons.calculate;
    if (name.contains('Mythology')) return Icons.auto_stories;
    if (name.contains('Politics')) return Icons.gavel;
    return Icons.lightbulb;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.7),
                Theme.of(context).primaryColor,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getCategoryIcon(),
                  size: 36,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pantalla de selección de dificultad
class DifficultyScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const DifficultyScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Difficulty'),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: $categoryName',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose difficulty level:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            
            // Opciones de dificultad
            DifficultyOption(
              difficulty: 'easy',
              label: 'Easy',
              description: 'Simple questions for beginners',
              color: Colors.green,
              icon: Icons.sentiment_very_satisfied,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TriviaScreen(
                      amount: 10,
                      difficulty: 'easy',
                      category: categoryId,
                      categoryName: categoryName,
                    ),
                  ),
                );
              },
            ),
            
            DifficultyOption(
              difficulty: 'medium',
              label: 'Medium',
              description: 'Moderate challenge for casual players',
              color: Colors.orange,
              icon: Icons.sentiment_satisfied,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TriviaScreen(
                      amount: 10,
                      difficulty: 'medium',
                      category: categoryId,
                      categoryName: categoryName,
                    ),
                  ),
                );
              },
            ),
            
            DifficultyOption(
              difficulty: 'hard',
              label: 'Hard',
              description: 'Challenging questions for experts',
              color: Colors.red,
              icon: Icons.sentiment_very_dissatisfied,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TriviaScreen(
                      amount: 10,
                      difficulty: 'hard',
                      category: categoryId,
                      categoryName: categoryName,
                    ),
                  ),
                );
              },
            ),
            
            const Spacer(),
            
            // Botón para juego aleatorio
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TriviaScreen(
                        amount: 10,
                        category: categoryId,
                        categoryName: categoryName,
                        isRandom: true,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shuffle),
                label: const Text('Random Mix'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opción de dificultad para la pantalla de selección
class DifficultyOption extends StatelessWidget {
  final String difficulty;
  final String label;
  final String description;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const DifficultyOption({
    super.key,
    required this.difficulty,
    required this.label,
    required this.description,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pantalla de configuración
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SettingsHeader(title: 'Game Settings'),
          
          SettingsSwitch(
            title: 'Sound Effects',
            subtitle: 'Enable sound effects during gameplay',
            value: true,
            onChanged: (value) {
              // Implementar cambio de configuración
            },
          ),
          
          SettingsSwitch(
            title: 'Vibration',
            subtitle: 'Enable vibration feedback',
            value: false,
            onChanged: (value) {
              // Implementar cambio de configuración
            },
          ),
          
          const SettingsHeader(title: 'Display Settings'),
          
          SettingsSwitch(
            title: 'Dark Mode',
            subtitle: 'Use dark theme',
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
              // Implementar cambio de tema
            },
          ),
          
          const SettingsHeader(title: 'About'),
          
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline),
          ),
          
          ListTile(
            title: const Text('Open Trivia Database'),
            subtitle: const Text('Data provided by opentdb.com'),
            leading: const Icon(Icons.link),
            onTap: () {
              // Abrir enlace a la web
            },
          ),
        ],
      ),
    );
  }
}

/// Encabezado para secciones de configuración
class SettingsHeader extends StatelessWidget {
  final String title;

  const SettingsHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

/// Interruptor para opciones de configuración
class SettingsSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Icon(
        value ? Icons.check_circle : Icons.circle_outlined,
        color: value ? Theme.of(context).primaryColor : Colors.grey,
      ),
    );
  }
}

/// Pantalla principal del juego de trivia
class TriviaScreen extends StatefulWidget {
  final int amount;
  final String difficulty;
  final String? category;
  final String? categoryName;
  final bool isRandom;

  const TriviaScreen({
    super.key,
    required this.amount,
    this.difficulty = 'easy',
    this.category,
    this.categoryName,
    this.isRandom = false,
  });

  @override
  _TriviaScreenState createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> with SingleTickerProviderStateMixin {
  final TriviaService _triviaService = TriviaService();
  late Future<List<TriviaQuestion>> _questionsFuture;
  int _currentScore = 0;
  int _currentQuestionIndex = 0;
  bool _answered = false;
  String? _selectedAnswer;
  int _timeRemaining = 15; // Tiempo en segundos para responder
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  bool _showHint = false;
  List<String> _eliminatedAnswers = [];

  @override
  void initState() {
    super.initState();
    
    // Inicializar el controlador de animación para el temporizador
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    
    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_timerController)
      ..addListener(() {
        setState(() {
          // Actualizar el tiempo restante basado en la animación
          _timeRemaining = (15 * _timerAnimation.value).ceil();
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_answered) {
          // Si el tiempo se acaba y no se ha respondido
          _checkAnswer(null, '');
        }
      });
    
    // Cargar preguntas
    _questionsFuture = _triviaService.fetchQuestions(
      amount: widget.amount,
      category: widget.category,
      difficulty: widget.isRandom ? '' : widget.difficulty,
      type: 'multiple',
    );
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timeRemaining = 15;
    _timerController.reset();
    _timerController.forward();
  }

  void _checkAnswer(String? selectedAnswer, String correctAnswer) {
    _timerController.stop();
    
    setState(() {
      _selectedAnswer = selectedAnswer;
      _answered = true;
      _showHint = false;
      _eliminatedAnswers = [];
      
      if (selectedAnswer == correctAnswer) {
        // Calcular puntos basados en el tiempo restante
        int timeBonus = (_timeRemaining * 10).round();
        _currentScore += 100 + timeBonus;
      }
    });
  }

  void _nextQuestion(List<TriviaQuestion> questions) {
  if (_currentQuestionIndex < questions.length - 1) {
    setState(() {
      _currentQuestionIndex++;
      _answered = false;
      _selectedAnswer = null;
      _showHint = false;
      _eliminatedAnswers = [];
    });
    _startTimer();
  } else {
    // Mostrar resultado final
    _showResultDialog();
  }
}

void _showResultDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Game Over'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _currentScore > 500 ? Icons.emoji_events : Icons.sentiment_satisfied,
            size: 48,
            color: _currentScore > 500 ? Colors.amber : Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            'Your final score: $_currentScore',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getScoreMessage(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop(); // Volver a la pantalla anterior
          },
          child: const Text('Back to Menu'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Reiniciar el juego
            setState(() {
              _currentQuestionIndex = 0;
              _currentScore = 0;
              _answered = false;
              _selectedAnswer = null;
              _showHint = false;
              _eliminatedAnswers = [];
              _questionsFuture = _triviaService.fetchQuestions(
                amount: widget.amount,
                category: widget.category,
                difficulty: widget.isRandom ? '' : widget.difficulty,
                type: 'multiple',
              );
            });
          },
          child: const Text('Play Again'),
        ),
      ],
    ),
  );
}

String _getScoreMessage() {
  if (_currentScore > 800) {
    return 'Excellent! You\'re a trivia master!';
  } else if (_currentScore > 500) {
    return 'Great job! You know your stuff!';
  } else if (_currentScore > 300) {
    return 'Good effort! Keep learning!';
  } else {
    return 'Practice makes perfect! Try again!';
  }
}

void _useHint() {
  if (!_answered && _eliminatedAnswers.length < 2) {
    final currentQuestion = _questionsFuture.then((questions) => questions[_currentQuestionIndex]);
    
    currentQuestion.then((question) {
      setState(() {
        // Encontrar respuestas incorrectas que no han sido eliminadas aún
        final availableIncorrect = question.allAnswers
            .where((answer) => 
                answer != question.correctAnswer && 
                !_eliminatedAnswers.contains(answer))
            .toList();
        
        if (availableIncorrect.isNotEmpty) {
          // Eliminar una respuesta incorrecta aleatoria
          final randomIndex = DateTime.now().millisecondsSinceEpoch % availableIncorrect.length;
          _eliminatedAnswers.add(availableIncorrect[randomIndex]);
          _showHint = true;
        }
      });
    });
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.categoryName ?? 'Trivia Challenge'),
      elevation: 0,
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              'Score: $_currentScore',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
    body: FutureBuilder<List<TriviaQuestion>>(
      future: _questionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading questions...'),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _questionsFuture = _triviaService.fetchQuestions(
                        amount: widget.amount,
                        category: widget.category,
                        difficulty: widget.isRandom ? '' : widget.difficulty,
                        type: 'multiple',
                      );
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No questions found'));
        } else {
          final questions = snapshot.data!;
          final currentQuestion = questions[_currentQuestionIndex];
          
          // Iniciar el temporizador si es la primera vez que se cargan las preguntas
          if (!_answered && _timerController.status != AnimationStatus.forward) {
            _startTimer();
          }
          
          return Column(
            children: [
              // Barra de progreso y temporizador
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1}/${questions.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '$_timeRemaining s',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _timeRemaining < 5 ? Colors.red : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_currentQuestionIndex) / questions.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenido principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información de la pregunta
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: currentQuestion.getDifficultyColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  currentQuestion.getCategoryIcon(),
                                  size: 20,
                                  color: currentQuestion.getDifficultyColor(),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  currentQuestion.category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: currentQuestion.getDifficultyColor(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: currentQuestion.getDifficultyColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              currentQuestion.difficulty.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: currentQuestion.getDifficultyColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Pregunta
                      Text(
                        currentQuestion.question,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Respuestas
                      ...currentQuestion.allAnswers.map((answer) {
                        final isCorrect = answer == currentQuestion.correctAnswer;
                        final isSelected = answer == _selectedAnswer;
                        final isEliminated = _eliminatedAnswers.contains(answer);
                        
                        // Determinar el color del botón
                        Color? backgroundColor;
                        Color? textColor = Colors.black;
                        
                        if (_answered) {
                          if (isCorrect) {
                            backgroundColor = Colors.green;
                            textColor = Colors.white;
                          } else if (isSelected) {
                            backgroundColor = Colors.red;
                            textColor = Colors.white;
                          }
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AnimatedOpacity(
                            opacity: isEliminated ? 0.5 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: ElevatedButton(
                              onPressed: (_answered || isEliminated) 
                                  ? null 
                                  : () => _checkAnswer(answer, currentQuestion.correctAnswer),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: backgroundColor,
                                foregroundColor: textColor,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: isEliminated 
                                      ? Colors.grey 
                                      : (isSelected ? Colors.blue : Colors.transparent),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      answer,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isEliminated ? Colors.grey : textColor,
                                      ),
                                    ),
                                  ),
                                  if (_answered && isCorrect)
                                    const Icon(Icons.check_circle, color: Colors.white),
                                  if (_answered && isSelected && !isCorrect)
                                    const Icon(Icons.cancel, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              
              // Barra inferior con botones de acción
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Botón de pista (50/50)
                    if (!_answered)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _eliminatedAnswers.length >= 2 ? null : _useHint,
                          icon: const Icon(Icons.lightbulb_outline),
                          label: const Text('Hint (50/50)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                    
                    // Botón de siguiente pregunta
                    if (_answered)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _nextQuestion(questions),
                          icon: Icon(
                            _currentQuestionIndex < questions.length - 1
                                ? Icons.arrow_forward
                                : Icons.done_all,
                          ),
                          label: Text(
                            _currentQuestionIndex < questions.length - 1
                                ? 'Next Question'
                                : 'See Results',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    ),
  );
}
}