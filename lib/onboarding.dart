// File: lib/pages/onboarding_page.dart
import 'package:booksdiscovery/routes/navigate.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'dart:async';

@RoutePage()
class OnboardingPage1 extends StatefulWidget {
  const OnboardingPage1({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage1> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Create your own\nstudy plan',
      subtitle:
          'Study according to the\nstudy plan, make study\nmore motivated',
      imagePath: 'assets/c1.png', // Update with your actual image path
    ),
    OnboardingData(
      title: 'Numerous free\ntrial courses',
      subtitle: 'Free courses for you to\nfind your way to learning',
      imagePath: 'assets/c2.png', // Update with your actual image path
    ),
  ]; // Removed the third page

  @override
  void initState() {
    super.initState();
    // Removed _startAutoScroll() call
  }

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      // Go to next onboarding page
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // If on the last page, navigate to the next route
      context.router.push(const OnboardingRoute1());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 10.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _goToNextPage, // Use the new method
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Skip'
                        : 'Skip', // Change text on last page
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // PageView content with images
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      _pages[index].imagePath,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index
                              ? const Color(0xFF4F46E5)
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              flex: 2,
              child: PageView.builder(
                controller: PageController(viewportFraction: 1.0),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _pages[index].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _pages[index].subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}
