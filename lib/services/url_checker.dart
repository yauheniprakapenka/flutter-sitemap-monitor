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
    } on DioException catch (e) {
      // Если это badResponse (404, 500 и т.д.), возвращаем реальный статус-код
      if (e.type == DioExceptionType.badResponse && e.response?.statusCode != null) {
        return e.response!.statusCode!;
      }

      // Для других ошибок (connectionError, timeout и т.д.) пробуем GET
      try {
        final response = await _dio.get(
          url,
          options: Options(
            followRedirects: true,
            maxRedirects: 5,
          ),
        );
        return response.statusCode;
      } on DioException catch (getError) {
        // Если GET тоже badResponse, возвращаем реальный статус-код
        if (getError.type == DioExceptionType.badResponse && getError.response?.statusCode != null) {
          return getError.response!.statusCode!;
        }
        // Для других ошибок возвращаем специальные коды
        return _getErrorStatusCode(getError);
      }
    } on Exception {
      return 999; // Неизвестная ошибка
    }
  }

  static int _getErrorStatusCode(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 998; // Таймаут подключения
      case DioExceptionType.sendTimeout:
        return 997; // Таймаут отправки
      case DioExceptionType.receiveTimeout:
        return 996; // Таймаут получения
      case DioExceptionType.connectionError:
        return 995; // Ошибка подключения
      case DioExceptionType.cancel:
        return 993; // Запрос отменен
      case DioExceptionType.unknown:
        return 992; // Неизвестная ошибка
      case DioExceptionType.badResponse:
        // Этот случай не должен сюда попадать, так как мы обрабатываем badResponse отдельно
        return 994; // Ошибка ответа сервера
      default:
        return 991; // Другая ошибка
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
