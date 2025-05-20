class StoryPageModel {
  final int pageNumber;
  final String text;
  final String? imageUrl; // Optional image URL

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
