import 'dart:io';

import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import '../models/sitemap_url.dart';

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

  static Future<List<SitemapUrl>> parseSitemapFromUrl(String url) async {
    try {
      // Для парсинга с URL можно использовать dio, который уже есть в зависимостях
      // Но пока оставим заглушку
      throw UnimplementedError('Парсинг с URL пока не реализован');
    } catch (e) {
      throw Exception('Ошибка загрузки sitemap с URL: $e');
    }
  }
}
