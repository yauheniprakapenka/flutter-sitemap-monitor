import 'package:flutter/material.dart';
import 'package:sitemap_with_search/sitemap_with_search.dart';
import 'package:sitemap_with_url/sitemap_with_url.dart';

import 'widgets/welcome_screen.dart';

void main() {
  runApp(const SitemapApp());
}

class SitemapApp extends StatelessWidget {
  const SitemapApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
      routes: {
        '/sitemap': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          if (args == null) {
            return const UrlInputScreen();
          }
          return SitemapHomeScreen(sitemapUrl: args);
        },
        '/sitemap-search-results': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
          if (args == null) {
            return const SearchInputScreen();
          }
          return SearchResultsScreen(
            sitemapUrl: args['url']!,
            searchText: args['searchText']!,
          );
        },
      },
    );
  }
}
