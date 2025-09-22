import '../../url_pages/models/sitemap_url.dart';
import '../../url_pages/services/url_checker.dart';
import '../models/sitemap_index_report.dart';
import '../models/sitemap_index_result.dart';

class SitemapIndexChecker {
  /// Проверяет статус всех страниц из результатов sitemap index
  static Future<SitemapIndexReport> checkAllPagesStatus(
    List<SitemapIndexResult> results,
    String originalUrl, {
    Function(int current, int total)? onProgress,
  }) async {
    final List<SitemapIndexReportItem> reportItems = [];
    int totalPages = 0;
    int checkedPages = 0;

    // Подсчитываем общее количество страниц
    for (final result in results) {
      if (result.isSuccess) {
        totalPages += result.pageUrls.length;
      }
    }

    // Проверяем каждый sitemap файл
    for (int i = 0; i < results.length; i++) {
      final result = results[i];

      if (result.isSuccess && result.pageUrls.isNotEmpty) {
        // Проверяем статус каждой страницы в sitemap
        final List<SitemapUrl> checkedPageUrls = [];

        for (int j = 0; j < result.pageUrls.length; j++) {
          final pageUrl = result.pageUrls[j];

          try {
            final statusCode = await UrlChecker.checkUrlStatus(pageUrl);
            checkedPageUrls.add(SitemapUrl(
              location: pageUrl,
              statusCode: statusCode,
            ));
          } on Exception{
            // Если не удалось проверить URL, добавляем с кодом ошибки
            checkedPageUrls.add(SitemapUrl(
              location: pageUrl,
              statusCode: 999, // Неизвестная ошибка
            ));
          }

          checkedPages++;

          // Обновляем прогресс
          if (onProgress != null) {
            onProgress(checkedPages, totalPages);
          }
        }

        reportItems.add(SitemapIndexReportItem(
          sitemapUrl: result.sitemapUrl,
          pageUrls: checkedPageUrls,
          isSuccess: true,
        ));
      } else {
        // Добавляем неуспешный sitemap без проверки страниц
        reportItems.add(SitemapIndexReportItem(
          sitemapUrl: result.sitemapUrl,
          pageUrls: [],
          isSuccess: false,
          errorMessage: result.errorMessage,
        ));
      }
    }

    return SitemapIndexReport(
      originalUrl: originalUrl,
      items: reportItems,
      generatedAt: DateTime.now(),
    );
  }
}
