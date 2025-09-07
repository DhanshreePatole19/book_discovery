import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

import '../routes/navigate.dart'; // Import your BooksService

@RoutePage()
class SearchFilterScreen extends StatefulWidget {
  final Set<String>? initialCategories;
  final RangeValues? initialPriceRange;

  const SearchFilterScreen({
    Key? key,
    this.initialCategories,
    this.initialPriceRange,
  }) : super(key: key);

  @override
  _SearchFilterScreenState createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  late Set<String> selectedCategories;
  late RangeValues priceRange;

  final List<String> availableCategories = [
    'Fiction',
    'Science Fiction',
    'Biography',
    'Music',
    'Non-fiction',
    'Mathematics',
  ];

  @override
  void initState() {
    super.initState();
    selectedCategories = Set.from(widget.initialCategories ?? {});
    priceRange = widget.initialPriceRange ?? RangeValues(0, 5000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Color(0xFF7B7B8B),
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with drag indicator
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12, bottom: 8),
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => context.router.pop(),
                            child: Icon(
                              Icons.close,
                              color: Colors.black87,
                              size: 24,
                            ),
                          ),
                          Text(
                            'Search Filter',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 24),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: ListView(
                          controller: controller,
                          children: [
                            // Categories Section
                            Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 16),

                            // Category chips
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children:
                                  availableCategories.map((category) {
                                    bool isSelected = selectedCategories
                                        .contains(category);
                                    return _buildCategoryChip(
                                      category,
                                      isSelected,
                                    );
                                  }).toList(),
                            ),

                            SizedBox(height: 40),

                            // Price Section
                            Text(
                              'Price Range (USD)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 20),

                            // Price Range Slider
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: Color(0xFF4285F4),
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Color(0xFF4285F4),
                                overlayColor: Color(
                                  0xFF4285F4,
                                ).withOpacity(0.2),
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 10,
                                ),
                                trackHeight: 4,
                              ),
                              child: RangeSlider(
                                values: priceRange,
                                min: 0,
                                max: 5000,
                                divisions: 20,
                                labels: RangeLabels(
                                  '\$${priceRange.start.round()}',
                                  '\$${priceRange.end.round()}',
                                ),
                                onChanged: (RangeValues values) {
                                  setState(() {
                                    priceRange = values;
                                  });
                                },
                              ),
                            ),

                            // Price labels
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${priceRange.start.round()}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '\$${priceRange.end.round()}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),

                    // Bottom buttons
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedCategories.clear();
                                    priceRange = RangeValues(0, 5000);
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigate to filtered books screen with the selected filters
                                  context.router.push(
                                    FilteredBooksRoute(
                                      categories: selectedCategories,
                                      minPrice: priceRange.start,
                                      maxPrice: priceRange.end,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF4285F4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Apply Filter',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedCategories.remove(label);
          } else {
            selectedCategories.add(label);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4285F4) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
