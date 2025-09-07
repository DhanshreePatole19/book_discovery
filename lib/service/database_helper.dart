import 'package:firebase_database/firebase_database.dart';
import 'book_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static final DatabaseReference _firebaseDatabaseRef =
      FirebaseDatabase.instance.ref();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  DatabaseReference get firebaseRef => _firebaseDatabaseRef;

  // Search history methods
  Future<void> addSearchQuery(String query) async {
    try {
      final userId = await _getCurrentUserId();

      final currentHistory = await getSearchHistory();
      final updatedHistory = [
        query,
        ...currentHistory.where((item) => item != query),
      ];
      final limitedHistory = updatedHistory.take(10).toList();

      await firebaseRef
          .child('users/$userId/search_history')
          .set(limitedHistory);
    } catch (e) {
      print('Failed to add search query to Firebase: $e');
    }
  }

  Future<List<String>> getSearchHistory() async {
    try {
      final userId = await _getCurrentUserId();
      final snapshot =
          await firebaseRef.child('users/$userId/search_history').get();

      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is List) return data.cast<String>().toList();
        if (data is Map) return data.values.cast<String>().toList();
      }
      return [];
    } catch (e) {
      print('Failed to get search history from Firebase: $e');
      return [];
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      final userId = await _getCurrentUserId();
      await firebaseRef.child('users/$userId/search_history').remove();
    } catch (e) {
      print('Failed to clear search history from Firebase: $e');
    }
  }

  // Analytics methods
  Future<void> recordBookView(String bookId) async {
    try {
      final userId = await _getCurrentUserId();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final analyticsRef = firebaseRef.child('analytics/$bookId');
      final snapshot = await analyticsRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final currentCount = (data['view_count'] as num?)?.toInt() ?? 0;
        await analyticsRef.update({
          'view_count': currentCount + 1,
          'last_viewed': timestamp,
          'last_viewed_by': userId,
        });
      } else {
        await analyticsRef.set({
          'view_count': 1,
          'last_viewed': timestamp,
          'last_viewed_by': userId,
          'book_id': bookId,
        });
      }

      await firebaseRef.child('users/$userId/view_history/$bookId').set({
        'timestamp': timestamp,
        'view_count': 1,
      });
    } catch (e) {
      print('Failed to record book view to Firebase: $e');
    }
  }

  Future<Map<String, dynamic>> getBookAnalytics(String bookId) async {
    try {
      final snapshot = await firebaseRef.child('analytics/$bookId').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return {
          'view_count': data['view_count'] ?? 0,
          'last_viewed': data['last_viewed'],
          'last_viewed_by': data['last_viewed_by'],
        };
      }
      return {'view_count': 0, 'last_viewed': null, 'last_viewed_by': null};
    } catch (e) {
      print('Failed to get book analytics from Firebase: $e');
      return {'view_count': 0, 'last_viewed': null, 'last_viewed_by': null};
    }
  }

  // Book caching methods
  Future<void> cacheBook(Book book) async {
    try {
      await firebaseRef.child('books/${book.id}').set({
        'title': book.title,
        'authors': book.authors,
        'publisher': book.publisher,
        'publishedDate': book.publishedDate,
        'description': book.description,
        'pageCount': book.pageCount,
        'thumbnailUrl': book.thumbnailUrl,
        'averageRating': book.averageRating,
        'ratingsCount': book.ratingsCount,
        'price': book.price,
        'categories': book.categories,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Failed to cache book to Firebase: $e');
    }
  }

  Future<Book?> getCachedBook(String bookId) async {
    try {
      final snapshot = await firebaseRef.child('books/$bookId').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return Book(
          id: bookId,
          title: data['title'] as String,
          authors: List<String>.from(data['authors']),
          publisher: data['publisher'] as String,
          publishedDate: data['publishedDate'] as String,
          description: data['description'] as String,
          pageCount: data['pageCount'] as int,
          thumbnailUrl: data['thumbnailUrl'] as String,
          averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
          ratingsCount: data['ratingsCount'] as int? ?? 0,
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          categories: List<String>.from(data['categories']),
        );
      }
      return null;
    } catch (e) {
      print('Failed to get cached book from Firebase: $e');
      return null;
    }
  }

  // Helper method to get current user ID
  Future<String> _getCurrentUserId() async {
    return 'default_user';
  }

  // Books by author method
  Future<List<Book>> getBooksByAuthor(String authorName) async {
    try {
      final snapshot = await firebaseRef.child('books').get();

      if (snapshot.exists) {
        final booksData = snapshot.value as Map<dynamic, dynamic>;
        final List<Book> books = [];

        booksData.forEach((bookId, bookData) {
          try {
            final authors = List<String>.from(bookData['authors'] ?? []);
            final hasMatchingAuthor = authors.any(
              (author) =>
                  author.toLowerCase().contains(authorName.toLowerCase()),
            );

            if (hasMatchingAuthor) {
              books.add(
                Book(
                  id: bookId as String,
                  title: bookData['title'] as String,
                  authors: authors,
                  publisher: bookData['publisher'] as String,
                  publishedDate: bookData['publishedDate'] as String,
                  description: bookData['description'] as String,
                  pageCount: bookData['pageCount'] as int,
                  thumbnailUrl: bookData['thumbnailUrl'] as String,
                  averageRating:
                      (bookData['averageRating'] as num?)?.toDouble() ?? 0.0,
                  ratingsCount: bookData['ratingsCount'] as int? ?? 0,
                  price: (bookData['price'] as num?)?.toDouble() ?? 0.0,
                  categories: List<String>.from(bookData['categories'] ?? []),
                ),
              );
            }
          } catch (e) {
            print('Error parsing book $bookId: $e');
          }
        });

        return books;
      }
      return [];
    } catch (e) {
      print('Failed to get books by author from Firebase: $e');
      return [];
    }
  }
}
