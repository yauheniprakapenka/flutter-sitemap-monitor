import 'sitemap_url.dart';

class SitemapIndexReport {
  final String originalUrl;
  final List<SitemapIndexReportItem> items;
  final DateTime generatedAt;

  const SitemapIndexReport({
    required this.originalUrl,
    required this.items,
    required this.generatedAt,
  });

  int get totalUrls {
    return items.fold(0, (sum, item) => sum + item.pageUrls.length);
  }

  int get totalSitemaps {
    return items.length;
  }

  int get successfulSitemaps {
    return items.where((item) => item.isSuccess).length;
  }

  int get failedSitemaps {
    return items.where((item) => !item.isSuccess).length;
  }

  int get successfulUrls {
    return items.fold(
        0,
        (sum, item) =>
            sum +
            item.pageUrls
                .where((url) =>
                    url.statusCode != null && url.statusCode! >= 200 && url.statusCode! < 300)
                .length);
  }

  int get errorUrls {
    return items.fold(
        0,
        (sum, item) =>
            sum +
            item.pageUrls
                .where((url) =>
                    url.statusCode != null && (url.statusCode! >= 400 || url.statusCode! >= 990))
                .length);
  }
}

class SitemapIndexReportItem {
  final String sitemapUrl;
  final List<SitemapUrl> pageUrls;
  final bool isSuccess;
  final String? errorMessage;

  const SitemapIndexReportItem({
    required this.sitemapUrl,
    required this.pageUrls,
    required this.isSuccess,
    this.errorMessage,
  });

  int get successfulUrls {
    return pageUrls
        .where((url) => url.statusCode != null && url.statusCode! >= 200 && url.statusCode! < 300)
        .length;
  }

  int get errorUrls {
    return pageUrls
        .where(
            (url) => url.statusCode != null && (url.statusCode! >= 400 || url.statusCode! >= 990))
        .length;
  }
}
