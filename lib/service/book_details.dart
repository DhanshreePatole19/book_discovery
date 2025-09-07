import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../service/book_model.dart';
import '../service/books_service.dart';

@RoutePage()
class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with TickerProviderStateMixin {
  List<Book> authorBooks = [];
  bool isLoadingAuthorBooks = false;
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBooksByAuthor();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
    _fadeController.forward();
  }

  Future<void> _loadBooksByAuthor() async {
    if (widget.book.authors.isEmpty) return;

    setState(() {
      isLoadingAuthorBooks = true;
    });

    try {
      final books = await BooksService.searchBooksByAuthor(
        widget.book.authors.first,
      );
      setState(() {
        authorBooks =
            books.where((book) => book.id != widget.book.id).take(5).toList();
        isLoadingAuthorBooks = false;
      });
    } catch (e) {
      setState(() {
        isLoadingAuthorBooks = false;
      });
      print('Failed to load books by author: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF4285F4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              flexibleSpace: FlexibleSpaceBar(
                background: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF8F9FA), Colors.white],
                      ),
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'book-${widget.book.id}',
                        child: Container(
                          width: 180,
                          height: 240,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child:
                                widget.book.thumbnailUrl.isNotEmpty
                                    ? Image.network(
                                      widget.book.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _buildBookPlaceholder(),
                                    )
                                    : _buildBookPlaceholder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Book Details
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Book Title and Author
                        Text(
                          widget.book.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 12),

                        if (widget.book.authors.isNotEmpty)
                          Text(
                            'by ${widget.book.authors.join(', ')}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF4285F4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                        SizedBox(height: 20),

                        // Rating and Price Row
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFF3CD),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    widget.book.averageRating > 0
                                        ? '${widget.book.averageRating.toStringAsFixed(1)}'
                                        : 'No ratings',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Spacer(),

                            Text(
                              '₹${widget.book.price > 0 ? widget.book.price.toStringAsFixed(2) : 'Free'}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30),

                        // Book Information Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Pages',
                                widget.book.pageCount > 0
                                    ? '${widget.book.pageCount}'
                                    : 'N/A',
                                Icons.book_outlined,
                              ),
                            ),
                            SizedBox(width: 15),
                            // Expanded(
                            //   child: _buildInfoCard(
                            //     'Language',
                            //     widget.book.language.isNotEmpty
                            //         ? widget.book.language.toUpperCase()
                            //         : 'N/A',
                            //     Icons.language,
                            //   ),
                            // ),
                            SizedBox(width: 15),
                            Expanded(
                              child: _buildInfoCard(
                                'Year',
                                widget.book.publishedDate.isNotEmpty
                                    ? widget.book.publishedDate.substring(0, 4)
                                    : 'N/A',
                                Icons.calendar_today,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30),

                        // Description
                        if (widget.book.description.isNotEmpty) ...[
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            widget.book.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 30),
                        ],

                        // Categories
                        if (widget.book.categories.isNotEmpty) ...[
                          Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 15),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                widget.book.categories.map((category) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: Color(0xFF4285F4),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                          SizedBox(height: 30),
                        ],

                        // More Books by Author
                        if (widget.book.authors.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'More by ${widget.book.authors.first}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              if (authorBooks.length > 3)
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'View All',
                                    style: TextStyle(
                                      color: Color(0xFF4285F4),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 15),

                          if (isLoadingAuthorBooks)
                            Center(child: CircularProgressIndicator())
                          else if (authorBooks.isNotEmpty)
                            Container(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: authorBooks.length,
                                itemBuilder: (context, index) {
                                  return _buildAuthorBookItem(
                                    authorBooks[index],
                                    index,
                                  );
                                },
                              ),
                            )
                          else
                            Center(
                              child: Text(
                                'No other books found by this author',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ),

                          SizedBox(height: 100), // Bottom spacing
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Buttons
    );
  }

  Widget _buildBookPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(child: Icon(Icons.book, size: 60, color: Colors.grey[600])),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF4285F4), size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAuthorBookItem(Book book, int index) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 15),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      BookDetailScreen(book: book),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return SlideTransition(
                  position: animation.drive(
                    Tween(
                      begin: Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeInOut)),
                  ),
                  child: child,
                );
              },
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'book-${book.id}',
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      book.thumbnailUrl.isNotEmpty
                          ? Image.network(
                            book.thumbnailUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    _buildSmallBookPlaceholder(),
                          )
                          : _buildSmallBookPlaceholder(),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              book.title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            if (book.price > 0)
              Text(
                '₹${book.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF4285F4),
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text(
                'Free',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBookPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(child: Icon(Icons.book, size: 30, color: Colors.grey[600])),
    );
  }
}
