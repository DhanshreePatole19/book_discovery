import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../routes/navigate.dart';
import '../service/book_details.dart';
import '../service/book_model.dart';
import '../service/books_service.dart';
import '../service/database_helper.dart';
import '../service/debouncer.dart';
import 'search.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CourseScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}

@RoutePage()
class CourseScreen extends StatefulWidget {
  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  int selectedTabIndex = 0;
  int selectedBottomIndex = 0;
  List<Book> books = [];
  List<Book> filteredBooks = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  bool showHistory = false;
  List<String> searchHistory = [];
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  final FocusNode _searchFocusNode = FocusNode();
  Set<String> selectedCategories = {};
  RangeValues priceRange = RangeValues(0, 500);
  List<Book> originalBooks = []; // Store original unfiltered books
  String profileImageUrl = "";
  @override
  void initState() {
    super.initState();
    _loadBooks();
    _loadSearchHistory();

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
        setState(() {
          showHistory = true;
        });
      }
    });
  }

  Future<void> _loadBooks() async {
    try {
      final fetchedBooks = await BooksService.fetchBooks();
      setState(() {
        books = fetchedBooks;
        originalBooks = fetchedBooks; // Store original books
        filteredBooks = fetchedBooks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load books: $e';
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Book> filtered = List.from(originalBooks);

    // Apply category filter
    if (selectedCategories.isNotEmpty) {
      filtered =
          filtered.where((book) {
            return selectedCategories.any(
              (category) =>
                  book.categories?.any(
                    (bookCategory) => bookCategory.toLowerCase().contains(
                      category.toLowerCase(),
                    ),
                  ) ??
                  false,
            );
          }).toList();
    }

    // Apply price filter
    filtered =
        filtered.where((book) {
          return book.price >= priceRange.start && book.price <= priceRange.end;
        }).toList();

    setState(() {
      filteredBooks = filtered;
    });
  }

  // Add this method to show filter bottom sheet
  // Update the _showFilterBottomSheet method in CourseScreen
  void _showFilterBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            child: SearchFilterScreen(
              initialCategories: selectedCategories,
              initialPriceRange: priceRange,
            ),
          ),
    );

    if (result != null) {
      setState(() {
        selectedCategories = Set<String>.from(result['categories'] ?? {});
        priceRange = result['priceRange'] ?? RangeValues(0, 500);
      });
      _applyFilters();
    }
  }

  // Alternative method using route navigation if you prefer
  void _showFilterBottomSheetRoute() async {
    final result = await context.router.push(
      SearchFilterRoute(
        initialCategories: selectedCategories,
        initialPriceRange: priceRange,
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        selectedCategories = result['categories'] ?? {};
        priceRange = result['priceRange'] ?? RangeValues(0, 500);
      });
      _applyFilters();
    }
  }

  // Update your routes file (app_router.dart or wherever you define routes)
  // Add this to your routes list:
  /*
AutoRoute(
  page: SearchFilterRoute.page,
  path: '/search-filter',
),
*/

  Future<void> _loadSearchHistory() async {
    try {
      final history = await DatabaseHelper().getSearchHistory();
      setState(() {
        searchHistory = history;
      });
    } catch (e) {
      print('Failed to load search history: $e');
    }
  }

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredBooks = books;
        isSearching = false;
        showHistory = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      isSearching = true;
      showHistory = false;
    });

    try {
      final searchedBooks = await BooksService.searchBooks(query);
      setState(() {
        filteredBooks = searchedBooks;
        isLoading = false;
      });

      // Reload search history
      _loadSearchHistory();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to search books: $e';
        isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      filteredBooks = books;
      isSearching = false;
      showHistory = false;
    });
    _searchFocusNode.unfocus();
  }

  void _selectHistoryItem(String query) {
    _searchController.text = query;
    _searchBooks(query);
  }

  void _clearHistory() async {
    await BooksService.clearSearchHistory();
    setState(() {
      searchHistory.clear();
    });
  }

  // Navigation to book detail screen with animation
  void _navigateToBookDetail(Book book) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                BookDetailScreen(book: book),
        transitionDuration: Duration(milliseconds: 600),
        reverseTransitionDuration: Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide and fade animation
          final slideAnimation = Tween<Offset>(
            begin: Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );

          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSearching ? 'Search Results' : 'Choice your course',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      // Add filter button
                      CircleAvatar(
                        radius: 24,
                        child: ClipOval(
                          child:
                              profileImageUrl.isNotEmpty
                                  ? Image.network(
                                    profileImageUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 48,
                                        height: 48,
                                        color: Color(0xFF4285F4),
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      );
                                    },
                                  )
                                  : Container(
                                    width: 48,
                                    height: 48,
                                    color: Color(0xFF4285F4),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 25),

              // Search Bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search books...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: _showFilterBottomSheet,
                            child: Icon(
                              Icons
                                  .filter, // Using filter icon instead of menu_open
                              color: Colors.grey[400],
                              size: 20,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 15,
                          ),
                        ),
                        onChanged: (value) {
                          _debouncer.run(() {
                            _searchBooks(value);
                          });
                        },
                        onTap: () {
                          if (_searchController.text.isEmpty) {
                            setState(() {
                              showHistory = true;
                            });
                          }
                        },
                      ),
                    ),
                    if (isSearching || _searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        onPressed: _clearSearch,
                      ),
                  ],
                ),
              ),

              // Search history dropdown
              if (showHistory && searchHistory.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Searches',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: _clearHistory,
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  color: Color(0xFF4285F4),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1),
                      ...searchHistory
                          .map(
                            (query) => ListTile(
                              leading: Icon(
                                Icons.history,
                                size: 20,
                                color: Colors.grey,
                              ),
                              title: Text(query),
                              onTap: () => _selectHistoryItem(query),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),

              SizedBox(height: 25),

              // Category Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 15,
                            bottom: 15,
                            child: Text(
                              'Language',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Color(0xFF4285F4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.translate,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 15),

                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 15,
                            bottom: 15,
                            child: Text(
                              'Painting',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Color(0xFFFF9800),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.brush,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Choice your course header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSearching ? 'Search Results' : 'Choice your course',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF4285F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.view_list,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.grid_view,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Filter Tabs (only show when not searching)
              if (!isSearching)
                Row(
                  children: [
                    _buildFilterTab('All', 0, true),
                    SizedBox(width: 15),
                    _buildFilterTab('Popular', 1, false),
                    SizedBox(width: 15),
                    _buildFilterTab('New', 2, false),
                  ],
                )
              else
                SizedBox(height: 20),

              SizedBox(height: 25),

              // Books List
              Expanded(
                child:
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : errorMessage.isNotEmpty
                        ? Center(child: Text(errorMessage))
                        : filteredBooks.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No books found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Try a different search term',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];
                            return _buildBookItem(book);
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  Widget _buildCustomBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top indicator line for selected tab
          Container(
            height: 3,
            width: double.infinity,
            child: Stack(
              children: [
                // Background line (optional - for subtle background)
                Container(
                  height: 3,
                  width: double.infinity,
                  color: Colors.grey[200],
                ),
                // Animated positioned indicator
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left:
                      (MediaQuery.of(context).size.width / 5) *
                          selectedBottomIndex +
                      (MediaQuery.of(context).size.width / 5 - 30) /
                          2, // Center the indicator
                  child: Container(
                    height: 3,
                    width: 30, // Manageable width - you can change this value
                    decoration: BoxDecoration(
                      color: Color(0xFF4285F4),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
                _buildBottomNavItem(
                  Icons.analytics_outlined,
                  Icons.analytics,
                  'Analytics',
                  1,
                ),
                _buildBottomNavItem(
                  Icons.search_outlined,
                  Icons.search,
                  'Search',
                  2,
                ),
                _buildBottomNavItem(
                  Icons.contacts_outlined,
                  Icons.contacts,
                  'Contacts',
                  3,
                ),
                _buildBottomNavItem(
                  Icons.person_outline,
                  Icons.person,
                  'Profile',
                  4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    bool isSelected = selectedBottomIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBottomIndex = index;
        });

        // Add navigation logic for different tabs
        if (index == 0) {
          // Home tab - don't navigate, just stay on current page
          // Already selected, no navigation needed
        } else if (index == 1) {
          // Analytics tab
          context.router.push(AnalyticsScreenRoute()).then((_) {
            // Reset to home when returning from Analytics
            setState(() {
              selectedBottomIndex = 0;
            });
          });
        } else if (index == 2) {
          // Search tab
          context.router.push(SearchFilterRoute()).then((_) {
            // Reset to home when returning from Search
            setState(() {
              selectedBottomIndex = 0;
            });
          });
        } else if (index == 3) {
          // Contacts tab - add navigation if needed
          // context.router.push(ContactsRoute()).then((_) {
          //   setState(() {
          //     selectedBottomIndex = 0;
          //   });
          // });
        } else if (index == 4) {
          // Profile tab
          context.router.push(ProfileTabRoute()).then((_) {
            // Reset to home when returning from Profile
            setState(() {
              selectedBottomIndex = 0;
            });
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Light blue circle for selected option
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFFE3F2FD) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Color(0xFF4285F4) : Colors.grey[400],
                size: 22,
              ),
            ),

            SizedBox(height: 4),

            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Color(0xFF4285F4) : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4285F4) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBookItem(Book book) {
    return GestureDetector(
      onTap:
          () => _navigateToBookDetail(book), // Added this line for navigation
      child: Container(
        height: 120,
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                image:
                    book.thumbnailUrl.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(book.thumbnailUrl),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  book.thumbnailUrl.isEmpty
                      ? Icon(Icons.book, size: 40, color: Colors.grey[600])
                      : null,
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey[500]),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          book.authors.isNotEmpty
                              ? book.authors.join(', ')
                              : 'Unknown Author',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        book.averageRating > 0
                            ? '${book.averageRating.toStringAsFixed(1)}'
                            : 'No ratings',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '₹${book.price > 0 ? book.price.toStringAsFixed(2) : 'Free'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4285F4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
