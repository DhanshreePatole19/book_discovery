class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String publisher;
  final String publishedDate;
  final String description;
  final int pageCount;
  final String thumbnailUrl;
  final double averageRating;
  final int ratingsCount;
  final double price;
  final List<String> categories;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.publisher,
    required this.publishedDate,
    required this.description,
    required this.pageCount,
    required this.thumbnailUrl,
    required this.averageRating,
    required this.ratingsCount,
    required this.price,
    required this.categories,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final saleInfo = json['saleInfo'] ?? {};
    final retailPrice = saleInfo['retailPrice'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};

    return Book(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'No Title',
      authors: List<String>.from(volumeInfo['authors'] ?? []),
      publisher: volumeInfo['publisher'] ?? 'Unknown Publisher',
      publishedDate: volumeInfo['publishedDate'] ?? '',
      description: volumeInfo['description'] ?? 'No description available',
      pageCount: volumeInfo['pageCount'] ?? 0,
      thumbnailUrl: imageLinks['thumbnail'] ?? '',
      averageRating: (volumeInfo['averageRating'] ?? 0.0).toDouble(),
      ratingsCount: volumeInfo['ratingsCount'] ?? 0,
      price: (retailPrice['amount'] ?? 0.0).toDouble(),
      categories: List<String>.from(volumeInfo['categories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'publisher': publisher,
      'publishedDate': publishedDate,
      'description': description,
      'pageCount': pageCount,
      'thumbnailUrl': thumbnailUrl,
      'averageRating': averageRating,
      'ratingsCount': ratingsCount,
      'price': price,
      'categories': categories,
    };
  }

  static Book fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      authors: List<String>.from(map['authors']),
      publisher: map['publisher'],
      publishedDate: map['publishedDate'],
      description: map['description'],
      pageCount: map['pageCount'],
      thumbnailUrl: map['thumbnailUrl'],
      averageRating: map['averageRating'],
      ratingsCount: map['ratingsCount'],
      price: map['price'],
      categories: List<String>.from(map['categories']),
    );
  }
  // Helper method to get the primary genre/category
  String get primaryCategory {
    if (categories.isEmpty) return 'Uncategorized';
    return categories.first;
  }
  
  // Helper method to get the publication year
 int get publishedYear {
    try {
      if (publishedDate.isEmpty) return 0;
      final year = publishedDate.split('-').first;
      return int.tryParse(year) ?? 0;
    } catch (e) {
      return 0;
    }
  }
  
  // Helper method to check if book is from recent years (2021-2025)
  bool get isRecent {
    return publishedYear >= 2021 && publishedYear <= 2025;
  }
}
