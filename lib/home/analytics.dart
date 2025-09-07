import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:auto_route/auto_route.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../routes/navigate.dart';
import '../service/book_model.dart';
import '../service/books_service.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab>
    with TickerProviderStateMixin {
  late List<Book> _books = [];
  bool _isLoading = true;
  int selectedTabIndex = 1;
  int selectedBottomIndex = 1;
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // User data
  String userName = "User";
  String userEmail = "";
  String profileImageUrl = "";
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentReference? userDocRef;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadUserData();

    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await BooksService.fetchBooksForAnalytics();
      setState(() {
        _books = books;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('Error loading books: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      userDocRef = _firestore.collection('users').doc(user.uid);

      try {
        final doc = await userDocRef!.get();
        if (doc.exists) {
          setState(() {
            userName = doc['name'] ?? "User";
            userEmail = user.email ?? "";
            profileImageUrl = doc['profileImageUrl'] ?? "";
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4285F4), // Purple background
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : RefreshIndicator(
                onRefresh: _loadBooks,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Header Section
                      // Header Section
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hi, $userName', // Use the actual user name
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Let's start learning",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    child:
                                        profileImageUrl.isNotEmpty
                                            ? Image.network(
                                              profileImageUrl,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  width: 48,
                                                  height: 48,
                                                  color: Colors.white,
                                                  child: const Icon(
                                                    Icons.person,
                                                    color: Color(0xFF4285F4),
                                                    size: 24,
                                                  ),
                                                );
                                              },
                                            )
                                            : Container(
                                              width: 48,
                                              height: 48,
                                              color: Colors.white,
                                              child: const Icon(
                                                Icons.person,
                                                color: Color(0xFF4285F4),
                                                size: 24,
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Main Content
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                // Genre Distribution Card
                                _buildGenreDistributionCard(),
                                const SizedBox(height: 24),

                                // Publishing Trends Card
                                _buildPublishingTrendsCard(),
                                const SizedBox(height: 24),
                                _buildMeetupCard(),
                                const SizedBox(height: 24),

                                // Sales Chart Card (replaces Meetup Card)
                                _buildSalesChartCard(),

                                // Bottom Navigation Space
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  Widget _buildGenreDistributionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F4FF), // Light blue background
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Genre distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 2,
                child: SizedBox(height: 120, child: _buildGenreChart()),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(flex: 3, child: _buildGenreLegend()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenreLegend() {
    // Get genre counts
    final genreCounts = <String, int>{};
    for (final book in _books) {
      if (book.categories.isNotEmpty) {
        final genre = book.categories.first;
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }

    // If no books with categories, use sample data
    if (genreCounts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildLegendItem('No genres found', Colors.grey)],
      );
    }

    // Sort genres by count
    final sortedGenres =
        genreCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 3 genres for legend
    final topGenres = sortedGenres.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < topGenres.length; i++)
          Column(
            children: [
              _buildLegendItem(
                '${topGenres[i].key} (${((topGenres[i].value / _books.length) * 100).toStringAsFixed(1)}%)',
                _getColorForGenre(topGenres[i].key),
              ),
              if (i < topGenres.length - 1) const SizedBox(height: 8),
            ],
          ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF666666)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPublishingTrendsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Publishing Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTrendLegend('Books Published', const Color(0xFF4ECDC4)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 150, child: _buildTrendChart()),
        ],
      ),
    );
  }

  Widget _buildTrendLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildSalesChartCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Distribution of book prices in your collection',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: _buildSalesChart()),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    // Group books by price ranges
    final priceRanges = {
      '\$0-\$10': 0,
      '\$10-\$20': 0,
      '\$20-\$30': 0,
      '\$30+': 0,
    };

    for (final book in _books) {
      if (book.price <= 10) {
        priceRanges['\$0-\$10'] = priceRanges['\$0-\$10']! + 1;
      } else if (book.price <= 20) {
        priceRanges['\$10-\$20'] = priceRanges['\$10-\$20']! + 1;
      } else if (book.price <= 30) {
        priceRanges['\$20-\$30'] = priceRanges['\$20-\$30']! + 1;
      } else {
        priceRanges['\$30+'] = priceRanges['\$30+']! + 1;
      }
    }

    final ranges = priceRanges.entries.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < ranges.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      ranges[index].key,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xFFE5E5E5), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups:
            ranges.asMap().entries.map((entry) {
              final index = entry.key;
              final range = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: range.value.toDouble(),
                    color: Color(0xFF4285F4),
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
        maxY: ranges.map((e) => e.value.toDouble()).reduce(max) + 1,
      ),
    );
  }

  // ... (keep the existing _buildCustomBottomNavigationBar, _buildBottomNavItem,
  // _buildMeetupCard methods as they are)

  Widget _buildGenreChart() {
    // Categorize books by genre
    final genreCounts = <String, int>{};

    for (final book in _books) {
      if (book.categories.isNotEmpty) {
        final genre = book.categories.first;
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }

    // If no books with categories, use sample data
    if (genreCounts.isEmpty) {
      genreCounts['Fiction'] = 45;
      genreCounts['Non-fiction'] = 30;
      genreCounts['Romance'] = 25;
    }

    final sections =
        genreCounts.entries.map((entry) {
          final color = _getColorForGenre(entry.key);
          return PieChartSectionData(
            color: color,
            value: entry.value.toDouble(),
            title: '',
            radius: 35,
            titleStyle: const TextStyle(fontSize: 0),
          );
        }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 25,
        startDegreeOffset: -90,
      ),
    );
  }

  Widget _buildTrendChart() {
    // Group books by publication year
    final yearCounts = <int, int>{};
    for (final book in _books) {
      if (book.publishedYear > 0) {
        yearCounts[book.publishedYear] =
            (yearCounts[book.publishedYear] ?? 0) + 1;
      }
    }

    // If no valid publication years, create sample data
    if (yearCounts.isEmpty) {
      final currentYear = DateTime.now().year;
      for (int i = currentYear - 5; i <= currentYear; i++) {
        yearCounts[i] = Random().nextInt(10) + 1;
      }
    }

    // Sort years and get the data points
    final sortedYears = yearCounts.keys.toList()..sort();
    final spots =
        sortedYears.asMap().entries.map((entry) {
          final index = entry.key;
          final year = entry.value;
          return FlSpot(index.toDouble(), yearCounts[year]!.toDouble());
        }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xFFE5E5E5), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedYears.length) {
                  return Text(
                    sortedYears[index].toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF4ECDC4),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF4ECDC4).withOpacity(0.3),
            ),
          ),
        ],
        minX: 0,
        maxX: spots.isEmpty ? 5 : spots.length - 1.toDouble(),
        minY: 0,
        maxY:
            spots.isEmpty ? 10 : (yearCounts.values.reduce(max) + 2).toDouble(),
      ),
    );
  }

  Color _getColorForGenre(String genre) {
    // Assign consistent colors based on genre
    switch (genre.toLowerCase()) {
      case 'fiction':
        return Colors.blue;
      case 'non-fiction':
        return Colors.green;
      case 'romance':
        return Colors.pink;
      case 'sci-fi':
        return Colors.purple;
      case 'thriller':
        return Colors.red;
      case 'history':
        return Colors.orange;
      case 'biography':
        return Colors.brown;
      default:
        // Generate a color from the genre name hash
        final hash = genre.hashCode;
        return Color((hash & 0xFFFFFF) | 0xFF000000).withOpacity(0.7);
    }
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
          context.router.push(const CourseRoute());

          // Home tab - don't navigate, just stay on current page
          // Already selected, no navigation needed
        } else if (index == 1) {
          // Analytics tab
          context.router.push(AnalyticsScreenRoute()).then((_) {
            // Reset to home when returning from Analytics
            setState(() {
              selectedBottomIndex = 1;
            });
          });
        } else if (index == 2) {
          // Search tab
          context.router.push(SearchFilterRoute()).then((_) {
            // Reset to home when returning from Search
            setState(() {
              selectedBottomIndex = 1;
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
              selectedBottomIndex = 1;
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

  Widget _buildMeetupCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6E6FA), Color(0xFFDDA0DD)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meetup',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A154B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Off-line exchange of learning\nexperiences',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B4C93),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              // Illustration placeholder
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.orange,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      bottom: 10,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.green,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
