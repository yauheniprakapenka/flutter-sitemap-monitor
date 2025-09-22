import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import '../models/sitemap_index_result.dart';

class SitemapIndexParser {
  /// Получает XML по URL и извлекает все URL из sitemap index, затем получает данные из каждого XML
  static Future<List<SitemapIndexResult>> parseSitemapIndexWithPages(String url) async {
    try {
      // Сначала получаем список XML ссылок из sitemap index
      final sitemapUrls = await parseSitemapIndexFromUrl(url);

      final List<SitemapIndexResult> results = [];

      // Обрабатываем каждый sitemap файл
      for (int i = 0; i < sitemapUrls.length; i++) {
        final sitemapUrl = sitemapUrls[i];

        try {
          final pageUrls = await _getPageUrlsFromSitemap(sitemapUrl);
          results.add(SitemapIndexResult(
            sitemapUrl: sitemapUrl,
            pageUrls: pageUrls,
            isSuccess: true,
          ));
        } on Exception catch (e) {
          results.add(SitemapIndexResult(
            sitemapUrl: sitemapUrl,
            pageUrls: [],
            isSuccess: false,
            errorMessage: e.toString(),
          ));
        }
      }

      return results;
    } catch (e) {
      throw Exception('Ошибка при обработке sitemap index: $e');
    }
  }

  /// Получает XML по URL и извлекает все URL из sitemap index
  static Future<List<String>> parseSitemapIndexFromUrl(String url) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final xmlString = response.data as String;
        return _parseSitemapIndexXml(xmlString);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse && e.response?.statusCode != null) {
        throw Exception('HTTP ${e.response!.statusCode}: ${e.response!.statusMessage}');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Таймаут подключения');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Таймаут получения данных');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Ошибка подключения');
      } else {
        throw Exception('Ошибка сети: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  /// Парсит XML строку и извлекает URL из sitemap index
  static List<String> _parseSitemapIndexXml(String xmlString) {
    try {
      final XmlDocument document = XmlDocument.parse(xmlString);

      // Ищем элементы sitemap в sitemap index
      final List<XmlElement> sitemapElements = document.findAllElements('sitemap').toList();

        if (sitemapElements.isEmpty) {
          // Если это не sitemap index, попробуем найти обычные URL
          final List<XmlElement> urlElements = document.findAllElements('url').toList();
          if (urlElements.isNotEmpty) {
            return _extractUrlsFromElements(urlElements);
          } else {
            throw Exception('Не удалось найти ни элементы <sitemap>, ни элементы <url>');
          }
        }

      // Извлекаем URL из каждого элемента sitemap
      return _extractUrlsFromSitemapElements(sitemapElements);

    } catch (e) {
      throw Exception('Ошибка парсинга XML: $e');
    }
  }

  /// Извлекает URL из элементов sitemap в sitemap index
  static List<String> _extractUrlsFromSitemapElements(List<XmlElement> sitemapElements) {
    final List<String> urls = [];

    for (int i = 0; i < sitemapElements.length; i++) {
      final sitemapElement = sitemapElements[i];

      // Ищем элемент <loc> внутри <sitemap>
      final locElement = sitemapElement.findElements('loc').firstOrNull;
        if (locElement != null) {
          final url = locElement.innerText.trim();
          if (url.isNotEmpty) {
            urls.add(url);
          }
        }
    }

    return urls;
  }

  /// Извлекает URL из обычных элементов url (для случая когда это не sitemap index)
  static List<String> _extractUrlsFromElements(List<XmlElement> urlElements) {
    final List<String> urls = [];

    for (int i = 0; i < urlElements.length; i++) {
      final urlElement = urlElements[i];

      // Ищем элемент <loc> внутри <url>
      final locElement = urlElement.findElements('loc').firstOrNull;
        if (locElement != null) {
          final url = locElement.innerText.trim();
          if (url.isNotEmpty) {
            urls.add(url);
          }
        }
      }

    return urls;
  }

  /// Получает URL страниц из отдельного sitemap файла
  static Future<List<String>> _getPageUrlsFromSitemap(String sitemapUrl) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      final response = await dio.get(sitemapUrl);

      if (response.statusCode == 200) {
        final xmlString = response.data as String;
        return _parsePageUrlsFromXml(xmlString);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse && e.response?.statusCode != null) {
        throw Exception('HTTP ${e.response!.statusCode}: ${e.response!.statusMessage}');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Таймаут подключения');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Таймаут получения данных');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Ошибка подключения');
      } else {
        throw Exception('Ошибка сети: ${e.message}');
      }
    } on Exception catch (e) {
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  /// Парсит XML и извлекает URL страниц
  static List<String> _parsePageUrlsFromXml(String xmlString) {
    try {
      final XmlDocument document = XmlDocument.parse(xmlString);
      final List<XmlElement> urlElements = document.findAllElements('url').toList();

      final List<String> pageUrls = [];

      for (final urlElement in urlElements) {
        final locElement = urlElement.findElements('loc').firstOrNull;
        if (locElement != null) {
          final url = locElement.innerText.trim();
          if (url.isNotEmpty) {
            pageUrls.add(url);
          }
        }
      }

      return pageUrls;
    } catch (e) {
      throw Exception('Ошибка парсинга XML: $e');
    }
  }
}
