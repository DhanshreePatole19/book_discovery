// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'navigate.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    BookDetailRoute.name: (routeData) {
      final args = routeData.argsAs<BookDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BookDetailScreen(key: args.key, book: args.book),
      );
    },
    CourseRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CourseScreen(),
      );
    },
    FilteredBooksRoute.name: (routeData) {
      final args = routeData.argsAs<FilteredBooksRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FilteredBooksScreen(
          key: args.key,
          categories: args.categories,
          minPrice: args.minPrice,
          maxPrice: args.maxPrice,
        ),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginPage(),
      );
    },
    OnboardingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const OnboardingPage1(),
      );
    },
    OnboardingRoute1.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const OnboardingPage(),
      );
    },
    SearchFilterRoute.name: (routeData) {
      final args = routeData.argsAs<SearchFilterRouteArgs>(
        orElse: () => const SearchFilterRouteArgs(),
      );
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SearchFilterScreen(
          key: args.key,
          initialCategories: args.initialCategories,
          initialPriceRange: args.initialPriceRange,
        ),
      );
    },
    SignUpRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SignUpPage(),
      );
    },
    Verifiedpage.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const Verifiedpage1(),
      );
    },
    Verifiedpage.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const Verifiedpage1(),
      );
    },
    ProfileTabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfileTab(),
      );
    },
    LogoutRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(routeData: routeData, child: LoginPage());
    },
    AnalyticsScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AnalyticsTab(),
      );
    },
  };
}

/// generated route for
/// [BookDetailScreen]
class BookDetailRoute extends PageRouteInfo<BookDetailRouteArgs> {
  BookDetailRoute({Key? key, required Book book, List<PageRouteInfo>? children})
    : super(
        BookDetailRoute.name,
        args: BookDetailRouteArgs(key: key, book: book),
        initialChildren: children,
      );

  static const String name = 'BookDetailRoute';

  static const PageInfo<BookDetailRouteArgs> page =
      PageInfo<BookDetailRouteArgs>(name);
}

class BookDetailRouteArgs {
  const BookDetailRouteArgs({this.key, required this.book});

  final Key? key;

  final Book book;

  @override
  String toString() {
    return 'BookDetailRouteArgs{key: $key, book: $book}';
  }
}

/// generated route for
/// [CourseScreen]
class CourseRoute extends PageRouteInfo<void> {
  const CourseRoute({List<PageRouteInfo>? children})
    : super(CourseRoute.name, initialChildren: children);

  static const String name = 'CourseRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [FilteredBooksScreen]
class FilteredBooksRoute extends PageRouteInfo<FilteredBooksRouteArgs> {
  FilteredBooksRoute({
    Key? key,
    required Set<String> categories,
    required double minPrice,
    required double maxPrice,
    List<PageRouteInfo>? children,
  }) : super(
         FilteredBooksRoute.name,
         args: FilteredBooksRouteArgs(
           key: key,
           categories: categories,
           minPrice: minPrice,
           maxPrice: maxPrice,
         ),
         initialChildren: children,
       );

  static const String name = 'FilteredBooksRoute';

  static const PageInfo<FilteredBooksRouteArgs> page =
      PageInfo<FilteredBooksRouteArgs>(name);
}

class FilteredBooksRouteArgs {
  const FilteredBooksRouteArgs({
    this.key,
    required this.categories,
    required this.minPrice,
    required this.maxPrice,
  });

  final Key? key;

  final Set<String> categories;

  final double minPrice;

  final double maxPrice;

  @override
  String toString() {
    return 'FilteredBooksRouteArgs{key: $key, categories: $categories, minPrice: $minPrice, maxPrice: $maxPrice}';
  }
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [OnboardingPage]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [OnboardingPage1]
class OnboardingRoute1 extends PageRouteInfo<void> {
  const OnboardingRoute1({List<PageRouteInfo>? children})
    : super(OnboardingRoute1.name, initialChildren: children);

  static const String name = 'OnboardingRoute1';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SearchFilterScreen]
class SearchFilterRoute extends PageRouteInfo<SearchFilterRouteArgs> {
  SearchFilterRoute({
    Key? key,
    Set<String>? initialCategories,
    RangeValues? initialPriceRange,
    List<PageRouteInfo>? children,
  }) : super(
         SearchFilterRoute.name,
         args: SearchFilterRouteArgs(
           key: key,
           initialCategories: initialCategories,
           initialPriceRange: initialPriceRange,
         ),
         initialChildren: children,
       );

  static const String name = 'SearchFilterRoute';

  static const PageInfo<SearchFilterRouteArgs> page =
      PageInfo<SearchFilterRouteArgs>(name);
}

class SearchFilterRouteArgs {
  const SearchFilterRouteArgs({
    this.key,
    this.initialCategories,
    this.initialPriceRange,
  });

  final Key? key;

  final Set<String>? initialCategories;

  final RangeValues? initialPriceRange;

  @override
  String toString() {
    return 'SearchFilterRouteArgs{key: $key, initialCategories: $initialCategories, initialPriceRange: $initialPriceRange}';
  }
}

/// generated route for
/// [SignUpPage]
class SignUpRoute extends PageRouteInfo<void> {
  const SignUpRoute({List<PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [Verifiedpage]
class Verifiedpage extends PageRouteInfo<void> {
  const Verifiedpage({List<PageRouteInfo>? children})
    : super(Verifiedpage.name, initialChildren: children);

  static const String name = 'Verifiedpage';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProfileTab]
class ProfileTabRoute extends PageRouteInfo<void> {
  const ProfileTabRoute({List<PageRouteInfo>? children})
    : super(ProfileTabRoute.name, initialChildren: children);
  static const String name = 'ProfileTabRoute';
  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ContactsScreen]
class ContactsScreenRoute extends PageRouteInfo<void> {
  const ContactsScreenRoute({List<PageRouteInfo>? children})
    : super(ContactsScreenRoute.name, initialChildren: children);
  static const String name = 'ContactsScreenRoute';
  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AnalyticsScreen]
class AnalyticsScreenRoute extends PageRouteInfo<void> {
  const AnalyticsScreenRoute({List<PageRouteInfo>? children})
    : super(AnalyticsScreenRoute.name, initialChildren: children);
  static const String name = 'AnalyticsScreenRoute';
  static const PageInfo<void> page = PageInfo<void>(name);
}

//generated route for
/// [LoginPage]
class LogoutRoute extends PageRouteInfo<void> {
  const LogoutRoute({List<PageRouteInfo>? children})
    : super(LogoutRoute.name, initialChildren: children);
  static const String name = 'LogoutRoute';
  static const PageInfo<void> page = PageInfo<void>(name);
}
