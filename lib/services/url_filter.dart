import '../models/sitemap_url.dart';

class UrlFilter {
  static List<SitemapUrl> filterByStatus(List<SitemapUrl> urls, int tabIndex) {
    switch (tabIndex) {
      case 0: // Все
        return urls;
      case 1: // 1xx - Информационные
        return urls.where((url) => url.statusCode != null && url.statusCode! >= 100 && url.statusCode! < 200).toList();
      case 2: // 2xx - Успешные
        return urls.where((url) => url.statusCode != null && url.statusCode! >= 200 && url.statusCode! < 300).toList();
      case 3: // 3xx - Перенаправления
        return urls.where((url) => url.statusCode != null && url.statusCode! >= 300 && url.statusCode! < 400).toList();
      case 4: // 4xx - Ошибки клиента
        return urls.where((url) => url.statusCode != null && url.statusCode! >= 400 && url.statusCode! < 500).toList();
      case 5: // 5xx - Ошибки сервера
        return urls.where((url) => url.statusCode != null && url.statusCode! >= 500 && url.statusCode! < 600).toList();
      case 6: // Остальное (null, нестандартные коды)
        return urls.where((url) => url.statusCode == null || url.statusCode! < 100 || url.statusCode! >= 600).toList();
      default:
        return urls;
    }
  }

  static String getTabTitle(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'Все';
      case 1:
        return '1xx';
      case 2:
        return '2xx';
      case 3:
        return '3xx';
      case 4:
        return '4xx';
      case 5:
        return '5xx';
      case 6:
        return 'Остальное';
      default:
        return 'Все';
    }
  }
}
