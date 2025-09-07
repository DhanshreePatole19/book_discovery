import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


import 'book_model.dart';
import 'books_service.dart'; // Import your BooksService

@RoutePage()
class FilteredBooksScreen extends StatefulWidget {
  final Set<String> categories;
  final double minPrice;
  final double maxPrice;

  const FilteredBooksScreen({
    Key? key,
    required this.categories,
    required this.minPrice,
    required this.maxPrice,
  }) : super(key: key);

  @override
  _FilteredBooksScreenState createState() => _FilteredBooksScreenState();
}

class _FilteredBooksScreenState extends State<FilteredBooksScreen> {
  List<Book> filteredBooks = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFilteredBooks();
  }

  Future<void> _fetchFilteredBooks() async {
  try {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    // Convert categories set to list
    List<String> categoriesList = widget.categories.toList();
    
    // Use the BooksService to fetch filtered books
    final books = await BooksService.getBooksByCategoryAndPrice(
      categories: categoriesList,
      minPrice: widget.minPrice,
      maxPrice: widget.maxPrice,
    );

    setState(() {
      filteredBooks = books;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
      hasError = true;
      errorMessage = e.toString();
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Books'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Error loading books',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchFilteredBooks,
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : filteredBooks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No books found',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.router.pop(),
                            child: Text('Adjust Filters'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Found ${filteredBooks.length} books',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredBooks.length,
                            itemBuilder: (context, index) {
                              final book = filteredBooks[index];
                              return BookListItem(book: book);
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}

// Book list item widget
class BookListItem extends StatelessWidget {
  final Book book;

  const BookListItem({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: book.thumbnailUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  book.thumbnailUrl,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 90,
                      color: Colors.grey[200],
                      child: Icon(Icons.book, color: Colors.grey[400]),
                    );
                  },
                ),
              )
            : Container(
                width: 60,
                height: 90,
                color: Colors.grey[200],
                child: Icon(Icons.book, color: Colors.grey[400]),
              ),
        title: Text(
          book.title,
          style: TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              book.authors.isNotEmpty ? book.authors.join(', ') : 'Unknown Author',
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                if (book.averageRating > 0) ...[
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    '${book.averageRating}',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '(${book.ratingsCount})',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(width: 8),
                ],
                Text(
                  '\$${book.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            if (book.categories.isNotEmpty) ...[
              SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: book.categories
                    .take(2)
                    .map((category) => Chip(
                          label: Text(
                            category,
                            style: TextStyle(fontSize: 10),
                          ),
                          padding: EdgeInsets.all(0),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        onTap: () {
          // Navigate to book details page
          // context.router.push(BookDetailsRoute(bookId: book.id));
        },
      ),
    );
  }
}