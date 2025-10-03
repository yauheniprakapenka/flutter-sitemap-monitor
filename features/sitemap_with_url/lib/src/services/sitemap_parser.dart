import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import '../models/sitemap_url.dart';
import 'url_checker.dart';

class SitemapParser {
  static Future<List<SitemapUrl>> parseSitemapFromAssets(String assetPath) async {
    try {
      final String xmlString = await rootBundle.loadString(assetPath);
      return _parseXmlString(xmlString);
    } catch (e) {
      throw Exception('Ошибка чтения файла sitemap: $e');
    }
  }

  static Future<List<SitemapUrl>> parseSitemapFromFile(String filePath) async {
    try {
      final File file = File(filePath);
      final String xmlString = await file.readAsString();
      return _parseXmlString(xmlString);
    } catch (e) {
      throw Exception('Ошибка чтения файла sitemap: $e');
    }
  }

  static List<SitemapUrl> _parseXmlString(String xmlString) {
    try {
      final XmlDocument document = XmlDocument.parse(xmlString);
      final List<XmlElement> urlElements = document.findAllElements('url').toList();

      return urlElements.map((urlElement) {
        final Map<String, dynamic> urlData = {};

        // Извлекаем данные из каждого элемента url
        for (final child in urlElement.children) {
          if (child is XmlElement) {
            urlData[child.name.local] = child.innerText;
          }
        }

        return SitemapUrl.fromXml(urlData);
      }).toList();
    } catch (e) {
      throw Exception('Ошибка парсинга XML: $e');
    }
  }

  static Future<List<SitemapUrl>> parseSitemapFromUrl(
    String url, {
    Function(int current, int total)? onProgress,
  }) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        // Успешный ответ - парсим XML и проверяем каждый URL
        final xmlString = response.data as String;
        final urls = _parseXmlString(xmlString);

        // Проверяем статус-код каждого URL
        final List<SitemapUrl> checkedUrls = [];
        for (int i = 0; i < urls.length; i++) {
          final url = urls[i];
          final statusCode = await UrlChecker.checkUrlStatus(url.location);
          checkedUrls.add(
            SitemapUrl(
              location: url.location,
              lastModified: url.lastModified,
              changeFrequency: url.changeFrequency,
              priority: url.priority,
              statusCode: statusCode,
            ),
          );

          // Обновляем прогресс
          if (onProgress != null) {
            onProgress(i + 1, urls.length);
          }
        }

        return checkedUrls;
      } else {
        // Неуспешный ответ - возвращаем один URL с соответствующим статус-кодом
        return [
          SitemapUrl(
            location: url,
            statusCode: response.statusCode,
          )
        ];
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse && e.response?.statusCode != null) {
        // Если sitemap возвращает ошибку (404, 500 и т.д.), возвращаем URL с этим статус-кодом
        final statusCode = e.response!.statusCode!;
        return [
          SitemapUrl(
            location: url,
            statusCode: statusCode,
          )
        ];
      } else if (e.type == DioExceptionType.connectionTimeout) {
        // Таймаут подключения - возвращаем URL с кодом 998
        return [
          SitemapUrl(
            location: url,
            statusCode: 998,
          )
        ];
      } else if (e.type == DioExceptionType.receiveTimeout) {
        // Таймаут получения - возвращаем URL с кодом 996
        return [
          SitemapUrl(
            location: url,
            statusCode: 996,
          )
        ];
      } else if (e.type == DioExceptionType.connectionError) {
        // Ошибка подключения - возвращаем URL с кодом 995
        return [
          SitemapUrl(
            location: url,
            statusCode: 995,
          )
        ];
      } else {
        // Другие ошибки - возвращаем URL с кодом 999
        return [
          SitemapUrl(
            location: url,
            statusCode: 999,
          )
        ];
      }
    } on Exception {
      // Неизвестная ошибка - возвращаем URL с кодом 999
      return [
        SitemapUrl(
          location: url,
          statusCode: 999,
        )
      ];
    }
  }
}
