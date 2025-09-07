import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_model.dart';
import 'database_helper.dart';



class BooksService {
  static const String baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  
  // Your existing methods...
  static Future<List<Book>> fetchBooks() async {
    // Your existing implementation
    final response = await http.get(Uri.parse('$baseUrl?q=flutter&maxResults=20'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      return items.map((item) => Book.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  static Future<List<Book>> searchBooks(String query) async {
    // Your existing implementation
    final response = await http.get(Uri.parse('$baseUrl?q=$query&maxResults=20'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      return items.map((item) => Book.fromJson(item)).toList();
    } else {
      throw Exception('Failed to search books');
    }
  }

  // NEW METHOD: Search books by author
  static Future<List<Book>> searchBooksByAuthor(String author) async {
    try {
      final encodedAuthor = Uri.encodeComponent(author);
      final response = await http.get(
        Uri.parse('$baseUrl?q=inauthor:$encodedAuthor&maxResults=10&orderBy=relevance')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) => Book.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search books by author');
      }
    } catch (e) {
      print('Error searching books by author: $e');
      return [];
    }
  }

  // NEW METHOD: Get book details by ID
  static Future<Book?> getBookDetails(String bookId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$bookId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Book.fromJson(data);
      } else {
        throw Exception('Failed to get book details');
      }
    } catch (e) {
      print('Error getting book details: $e');
      return null;
    }
  }

  // NEW METHOD: Get similar books by category
  static Future<List<Book>> getSimilarBooks(Book book) async {
    try {
      String query = '';
      if (book.categories.isNotEmpty) {
        query = book.categories.first;
      } else if (book.authors.isNotEmpty) {
        query = 'subject:${book.authors.first}';
      } else {
        query = 'fiction'; // Default fallback
      }
      
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http.get(
        Uri.parse('$baseUrl?q=$encodedQuery&maxResults=10&orderBy=relevance')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        final similarBooks = items.map((item) => Book.fromJson(item)).toList();
        
        // Filter out the current book
        return similarBooks.where((b) => b.id != book.id).toList();
      } else {
        throw Exception('Failed to get similar books');
      }
    } catch (e) {
      print('Error getting similar books: $e');
      return [];
    }
  }

  // Your existing clearSearchHistory method...
  static Future<void> clearSearchHistory() async {
    // Your existing implementation
  }
  // Add to your BooksService class
static Future<List<Book>> getBooksByCategoryAndPrice({
  required List<String> categories,
  required double minPrice,
  required double maxPrice,
}) async {
  try {
    // Build query for categories
    String categoryQuery = '';
    if (categories.isNotEmpty) {
      categoryQuery = categories.map((category) => 'subject:"$category"').join(' OR ');
    } else {
      categoryQuery = 'books'; // Default query
    }

    // Fetch books from Google Books API
    final encodedQuery = Uri.encodeComponent(categoryQuery);
    final response = await http.get(
      Uri.parse('$baseUrl?q=$encodedQuery&maxResults=40&orderBy=relevance')
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      List<Book> books = items.map((item) => Book.fromJson(item)).toList();
      
      // Filter by price on the client side
      return books.where((book) => 
        book.price >= minPrice && book.price <= maxPrice
      ).toList();
    } else {
      throw Exception('Failed to load filtered books');
    }
  } catch (e) {
    print('Error getting filtered books: $e');
    return [];
  }
}
static Future<List<Book>> fetchBooksForAnalytics() async {
    try {
      // You might want to fetch more books for analytics
      // or use a different endpoint that returns more data
      return await fetchBooks();
    } catch (e) {
      print('Error fetching books for analytics: $e');
      return [];
    }
  }
}

