// Representa una página individual dentro de una secuencia de historia o narrativa.
class StoryPageModel {
  final int pageNumber; // Número de página, para ordenar la secuencia.
  final String text; // Contenido de texto de la página.
  final String? imageUrl; // URL opcional a una imagen para esta página de la historia.

  // Constructor para crear una instancia de StoryPageModel.
  StoryPageModel({
    required this.pageNumber,
    required this.text,
    this.imageUrl,
  });

  // Factory constructor for creating a new StoryPageModel instance from a map
  factory StoryPageModel.fromJson(Map<String, dynamic> json) {
    if (json['pageNumber'] == null || json['text'] == null) {
      throw ArgumentError('Missing required fields: pageNumber and text are required.');
    }
    return StoryPageModel(
      pageNumber: json['pageNumber'] as int,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  // Method for converting a StoryPageModel instance to a map
  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
