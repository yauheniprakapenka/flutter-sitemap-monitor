import 'package:dio/dio.dart';

import '../models/sitemap_url.dart';

class UrlChecker {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Future<int?> checkUrlStatus(String url) async {
    try {
      final response = await _dio.head(
        url,
        options: Options(
          followRedirects: true,
          maxRedirects: 5,
        ),
      );
      return response.statusCode;
    } on Exception {
      // Если HEAD запрос не поддерживается, пробуем GET
      try {
        final response = await _dio.get(
          url,
          options: Options(
            followRedirects: true,
            maxRedirects: 5,
          ),
        );
        return response.statusCode;
      } on Exception {
        return null; // Ошибка при запросе
      }
    }
  }

  static Future<List<SitemapUrl>> checkUrlsStatus(List<SitemapUrl> urls) async {
    final List<SitemapUrl> updatedUrls = [];

    for (final url in urls) {
      final statusCode = await checkUrlStatus(url.location);
      updatedUrls.add(
        SitemapUrl(
          location: url.location,
          lastModified: url.lastModified,
          changeFrequency: url.changeFrequency,
          priority: url.priority,
          statusCode: statusCode,
        ),
      );
    }

    return updatedUrls;
  }

  static Future<List<SitemapUrl>> checkUrlsStatusBatch(
    List<SitemapUrl> urls, {
    int batchSize = 10,
    Function(int current, int total)? onProgress,
  }) async {
    final List<SitemapUrl> updatedUrls = [];

    for (int i = 0; i < urls.length; i += batchSize) {
      final batch = urls.skip(i).take(batchSize).toList();
      final batchResults = await Future.wait(
        batch.map((url) async {
          final statusCode = await checkUrlStatus(url.location);
          return SitemapUrl(
            location: url.location,
            lastModified: url.lastModified,
            changeFrequency: url.changeFrequency,
            priority: url.priority,
            statusCode: statusCode,
          );
        }),
      );

      updatedUrls.addAll(batchResults);

      if (onProgress != null) {
        onProgress(updatedUrls.length, urls.length);
      }
    }

    return updatedUrls;
  }
}
