import 'package:flutter/material.dart';

import 'screens/sitemap_home_screen.dart';
import 'screens/url_input_screen.dart';

void main() {
  runApp(const SitemapApp());
}

class SitemapApp extends StatelessWidget {
  const SitemapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sitemap Parser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UrlInputScreen(),
      routes: {
        '/sitemap': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          if (args == null) {
            return const UrlInputScreen();
          }
          return SitemapHomeScreen(sitemapUrl: args);
        },
      },
    );
  }
}
