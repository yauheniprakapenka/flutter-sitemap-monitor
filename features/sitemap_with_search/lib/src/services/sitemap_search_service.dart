import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import '../models/sitemap_search_result.dart';

class SitemapSearchService {
  static Future<List<SitemapSearchResult>> searchInSitemaps(
    String sitemapUrl,
    String searchText, {
    Function(int current, int total)? onProgress,
  }) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      final response = await dio.get(sitemapUrl);

      if (response.statusCode != 200) {
        throw Exception('Не удалось загрузить sitemap: ${response.statusCode}');
      }

      final xmlString = response.data as String;
      final document = XmlDocument.parse(xmlString);

      // Проверяем, является ли это sitemap index (содержит ссылки на другие sitemap'ы)
      final sitemapElements = document.findAllElements('sitemap').toList();
      final urlElements = document.findAllElements('url').toList();

      final List<SitemapSearchResult> results = [];

      if (sitemapElements.isNotEmpty) {
        // Это sitemap index - обрабатываем каждый вложенный sitemap
        for (int i = 0; i < sitemapElements.length; i++) {
          final sitemapElement = sitemapElements[i];
          final locElement = sitemapElement.findElements('loc').firstOrNull;

          if (locElement != null) {
            final nestedSitemapUrl = locElement.innerText;
            final result = await _searchInSingleSitemap(
              nestedSitemapUrl,
              searchText,
              dio,
            );

            if (result != null) {
              results.add(result);
            }

            // Обновляем прогресс
            if (onProgress != null) {
              onProgress(i + 1, sitemapElements.length);
            }
          }
        }
      } else if (urlElements.isNotEmpty) {
        // Это обычный sitemap - ищем прямо в нем
        final result = await _searchInSingleSitemap(
          sitemapUrl,
          searchText,
          dio,
        );

        if (result != null) {
          results.add(result);
        }

        if (onProgress != null) {
          onProgress(1, 1);
        }
      }

      return results;
    } on DioException catch (e) {
      throw Exception('Ошибка при загрузке sitemap: ${e.message}');
    } catch (e) {
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  static Future<SitemapSearchResult?> _searchInSingleSitemap(
    String sitemapUrl,
    String searchText,
    Dio dio,
  ) async {
    try {
      final response = await dio.get(sitemapUrl);

      if (response.statusCode != 200) {
        return null;
      }

      final xmlString = response.data as String;
      final document = XmlDocument.parse(xmlString);
      final urlElements = document.findAllElements('url').toList();

      final List<String> matchingUrls = [];

      for (final urlElement in urlElements) {
        final locElement = urlElement.findElements('loc').firstOrNull;
        if (locElement != null) {
          final url = locElement.innerText;
          if (url.toLowerCase().contains(searchText.toLowerCase())) {
            matchingUrls.add(url);
          }
        }
      }

      return SitemapSearchResult(
        sitemapUrl: sitemapUrl,
        matchingUrls: matchingUrls,
        totalUrls: urlElements.length,
        matchingCount: matchingUrls.length,
      );
    } on Exception {
      // Игнорируем ошибки для отдельных sitemap'ов
      return null;
    }
  }
}
