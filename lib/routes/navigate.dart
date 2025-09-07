import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../auth/login.dart';
import '../auth/signup.dart';
import '../auth/verified.dart';
import '../home/analytics.dart';
import '../home/contact.dart';
import '../home/home.dart'; // Import your home page
import '../home/profile.dart';
import '../home/search.dart';
import '../onboarding.dart';
import '../onboarding03.dart';
import '../service/book_details.dart';
import '../service/book_model.dart';
import '../service/filter_book.dart';
part 'navigate.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    // Onboarding route (initial route)
    AutoRoute(page: OnboardingRoute.page, path: '/', initial: true),
    AutoRoute(page: OnboardingRoute1.page, path: '/onboarding'),
    // Auth routes
    AutoRoute(page: SignUpRoute.page, path: '/signup'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: Verifiedpage.page, path: '/verified'),
    AutoRoute(page: CourseRoute.page, path: '/home'),
    AutoRoute(page: SearchFilterRoute.page, path: '/search'),
    AutoRoute(page: FilteredBooksRoute.page, path: '/filter_book'),
    AutoRoute(page: ProfileTabRoute.page, path: '/profile'),
    AutoRoute(page: BookDetailRoute.page, path: '/book_detail'),
    AutoRoute(page: ContactsScreenRoute.page, path: '/ContactsScreen'),
    AutoRoute(page: AnalyticsScreenRoute.page, path: '/analytics'),
    AutoRoute(page: LogoutRoute.page, path: '/login'),

    // Add these new routes ContactsScreen
  ];
}
