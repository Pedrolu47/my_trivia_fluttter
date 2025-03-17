# Trivia Challenge App
Descripción
Trivia Challenge es una aplicación móvil desarrollada con Flutter que permite a los usuarios poner a prueba sus conocimientos en diversas categorías a través de preguntas de trivia. La aplicación consume la API de Open Trivia Database para ofrecer miles de preguntas en múltiples categorías y niveles de dificultad.

Características
Juego rápido: Comienza a jugar inmediatamente con preguntas aleatorias
Selección de categorías: Elige entre más de 20 categorías diferentes
Niveles de dificultad: Selecciona entre fácil, medio y difícil
Sistema de puntuación: Gana puntos basados en respuestas correctas y tiempo de respuesta
Temporizador: Cada pregunta tiene un límite de tiempo de 15 segundos
Ayuda 50/50: Elimina dos respuestas incorrectas para facilitar la elección
Interfaz atractiva: Diseño moderno y atractivo con animaciones fluidas
Modo oscuro: Soporte para tema claro y oscuro según la configuración del sistema
Tecnologías utilizadas
Flutter: Framework de UI para desarrollo multiplataforma
Dart: Lenguaje de programación
HTTP: Para realizar peticiones a la API
API REST: Consumo de Open Trivia Database
Animaciones: Para mejorar la experiencia de usuario
Gestión de estado: Uso de StatefulWidget para manejar el estado de la aplicación
Arquitectura
La aplicación sigue una arquitectura simple pero efectiva:

Modelos de datos: Clases para representar preguntas y categorías
Servicios: Clase para manejar las peticiones a la API
Widgets de UI: Componentes reutilizables para la interfaz de usuario
Pantallas: Diferentes vistas de la aplicación
Instalación
Requisitos previos
Flutter SDK (versión 3.7.0 o superior)
Dart SDK (versión 3.0.0 o superior)
Un editor de código (VS Code, Android Studio, etc.)
Un emulador o dispositivo físico para ejecutar la aplicación
Pasos para instalar
Clona este repositorio:

git clone https://github.com/tu-usuario/trivia_challenge.git
Uso
Pantalla de inicio
La pantalla de inicio presenta tres opciones principales:

Juego rápido: Inicia un juego con 10 preguntas de dificultad fácil
Categorías: Permite seleccionar una categoría específica
Configuración: Accede a las opciones de configuración de la aplicación
Selección de categoría
En esta pantalla puedes:

Buscar categorías específicas usando la barra de búsqueda
Seleccionar una categoría tocando su tarjeta
Selección de dificultad
Después de elegir una categoría, puedes seleccionar la dificultad:

Fácil: Preguntas simples para principiantes
Medio: Desafío moderado para jugadores casuales
Difícil: Preguntas desafiantes para expertos
Mezcla aleatoria: Combinación de preguntas de todas las dificultades
Pantalla de juego
Durante el juego:

Lee la pregunta y selecciona una respuesta
Observa el temporizador para responder antes de que se acabe el tiempo
Usa la ayuda 50/50 para eliminar dos respuestas incorrectas
Avanza a la siguiente pregunta después de responder
Resultados
Al finalizar el juego:

Verás tu puntuación final
Recibirás un mensaje basado en tu desempeño
Podrás volver al menú o jugar de nuevo
Estructura del proyecto
lib/
├── main.dart # Punto de entrada de la aplicación
├── models/ # Modelos de datos
│ └── trivia_question.dart # Modelo para preguntas de trivia
├── services/ # Servicios para API
│ └── trivia_service.dart # Servicio para consumir Open Trivia Database
└── screens/ # Pantallas de la aplicación
├── home_screen.dart # Pantalla de inicio
├── category_screen.dart # Pantalla de selección de categoría
├── difficulty_screen.dart # Pantalla de selección de dificultad
├── trivia_screen.dart # Pantalla principal del juego
└── settings_screen.dart # Pantalla de configuración
API utilizada
La aplicación consume la API de Open Trivia Database, que proporciona acceso gratuito a miles de preguntas de trivia en múltiples categorías y niveles de dificultad.

URL base: <https://opentdb.com/api.php>
Documentación: Open Trivia Database API
Endpoints principales:
Obtener categorías: <https://opentdb.com/api_category.php>
Obtener preguntas: <https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple>
Desafíos y soluciones
Desafío 1: Deserialización de datos HTML
Las preguntas y respuestas de la API contienen caracteres HTML codificados que necesitan ser decodificados para mostrarlos correctamente.

Solución: Utilizamos el paquete html_unescape para decodificar estos caracteres.

Desafío 2: Gestión del temporizador
Implementar un temporizador que funcione correctamente y se sincronice con el estado de la aplicación.

Solución: Utilizamos AnimationController para crear un temporizador preciso que se integra con el ciclo de vida de los widgets.

Desafío 3: Interfaz adaptativa
URL base: [https://opentdb.com/api.php](https://opentdb.com/api.php)  
Documentación: [Open Trivia Database API](https://opentdb.com)  
Endpoints principales:  
- Obtener categorías: [https://opentdb.com/api_category.php](https://opentdb.com/api_category.php)  
- Obtener preguntas: [https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple](https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple)
Modo multijugador: Permitir competir con amigos en tiempo real
Tablas de clasificación: Implementar un sistema de clasificación global
Modo sin conexión: Permitir jugar sin conexión a internet
Personalización avanzada: Más opciones de personalización de la experiencia
Estadísticas detalladas: Seguimiento del progreso y estadísticas de juego
Integración con redes sociales: Compartir resultados en plataformas sociales
Contribución
Las contribuciones son bienvenidas. Para contribuir:

Haz un fork del repositorio
Crea una rama para tu característica (git checkout -b feature/amazing-feature)
Haz commit de tus cambios (git commit -m 'Add some amazing feature')
Haz push a la rama (git push origin feature/amazing-feature)
Abre un Pull Request
Licencia
Este proyecto está licenciado bajo la Licencia MIT - ver el archivo LICENSE para más detalles.



Enlace del proyecto: <https://github.com/Pedrolu47/trivia_challenge>

Agradecimientos
Open Trivia Database por proporcionar la API gratuita
Flutter por el increíble framework
Iconos e imágenes utilizados en la aplicación
Desarrollado con ❤️ por [Pedrolu47]
