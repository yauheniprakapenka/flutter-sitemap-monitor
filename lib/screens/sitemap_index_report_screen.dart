// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sitemap_index_report.dart';
import '../models/sitemap_url.dart';

class SitemapIndexReportScreen extends StatelessWidget {
  final SitemapIndexReport report;

  const SitemapIndexReportScreen({super.key, required this.report});

  String _formatDate(DateTime date) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final totalUrls = report.totalUrls;
    final successCount = report.successfulUrls;
    final redirectCount = _getRedirectCount();
    final clientErrorCount = _getClientErrorCount();
    final serverErrorCount = _getServerErrorCount();
    final connectionErrorCount = _getConnectionErrorCount();
    final otherCount = totalUrls - successCount - redirectCount - clientErrorCount - serverErrorCount - connectionErrorCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчет по sitemap index'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Text('Копировать отчет'),
            onPressed: () => _copyReportToClipboard(context),
            tooltip: 'Копировать отчет',
          ),
        ],
      ),
      body: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 8,
        radius: const Radius.circular(4),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TitleWidget(originalUrl: report.originalUrl),
            const SizedBox(height: 24),

            Text('Дата: ${_formatDate(report.generatedAt)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            // Горизонтальный ряд с тремя блоками статистики
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Общая статистика
                    SizedBox(
                      width: 280,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Общая статистика',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              _buildStatRow('Sitemap файлов', report.totalSitemaps, Colors.blue),
                              _buildStatRow('Успешных sitemap', report.successfulSitemaps, Colors.green),
                              _buildStatRow('Ошибок sitemap', report.failedSitemaps, Colors.red),
                              const Divider(),
                              _buildStatRow('Всего страниц', totalUrls, Colors.blue),
                              _buildStatRow('Успешные (2xx)', successCount, Colors.green),
                              _buildStatRow('Перенаправления (3xx)', redirectCount, Colors.orange),
                              _buildStatRow('Ошибки клиента (4xx)', clientErrorCount, Colors.red),
                              _buildStatRow('Ошибки сервера (5xx)', serverErrorCount, Colors.red.shade800),
                              _buildStatRow('Ошибки подключения', connectionErrorCount, Colors.purple),
                              _buildStatRow('Остальное', otherCount, Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Процентное соотношение
                    SizedBox(
                      width: 360,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Процентное соотношение',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              if (totalUrls > 0) ...[
                                _buildPercentageRow('Успешные', successCount, totalUrls, Colors.green),
                                _buildPercentageRow('Перенаправления', redirectCount, totalUrls, Colors.orange),
                                _buildPercentageRow('Ошибки клиента', clientErrorCount, totalUrls, Colors.red),
                                _buildPercentageRow('Ошибки сервера', serverErrorCount, totalUrls, Colors.red.shade800),
                                _buildPercentageRow('Ошибки подключения', connectionErrorCount, totalUrls, Colors.purple),
                                _buildPercentageRow('Остальное', otherCount, totalUrls, Colors.grey),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Детальная статистика по статус-кодам
                    SizedBox(
                      width: 280,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Детальная статистика',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              ..._buildDetailedStats(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Список ошибочных URL
            if (clientErrorCount + serverErrorCount + connectionErrorCount > 0) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ошибочные URL',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton.icon(
                            onPressed: () => _copyErrorUrlsToClipboard(context),
                            icon: const Icon(Icons.copy, size: 14),
                            label: const Text('Копировать ссылки', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._buildErrorUrlsByCategory(context),
                    ],
                  ),
                ),
              ),
            ],

            // Список sitemap файлов
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Детали по sitemap файлам',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildSitemapDetailsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageRow(String label, int count, int total, Color color) {
    final percentage = (count / total * 100).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 80,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: count / total,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDetailedStats() {
    final statusCodeCounts = <int, int>{};
    for (final item in report.items) {
      for (final url in item.pageUrls) {
        if (url.statusCode != null) {
          statusCodeCounts[url.statusCode!] = (statusCodeCounts[url.statusCode!] ?? 0) + 1;
        }
      }
    }

    final sortedStatusCodes = statusCodeCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedStatusCodes.take(10).map((entry) {
      final statusCode = entry.key;
      final count = entry.value;
      final color = _getStatusCodeColor(statusCode);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$statusCode', style: const TextStyle(fontSize: 14, fontFamily: 'monospace')),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildErrorUrlsByCategory(BuildContext context) {
    final errorCategories = <String, List<Map<String, dynamic>>>{};

    // Группируем ошибки по sitemap файлам
    for (final item in report.items) {
      final errorUrls = <Map<String, dynamic>>[];

      for (final url in item.pageUrls) {
        if (url.statusCode != null && (url.statusCode! >= 400 || url.statusCode! >= 990)) {
          errorUrls.add({
            'url': url,
            'statusCode': url.statusCode!,
          });
        }
      }

      if (errorUrls.isNotEmpty) {
        errorCategories[item.sitemapUrl] = errorUrls;
      }
    }

    if (errorCategories.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Ошибочных URL не найдено',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    final widgets = <Widget>[];

    errorCategories.forEach((sitemapUrl, errorUrls) {
      // Заголовок sitemap файла
      widgets.add(
        Tooltip(
          message: 'Нажмите для копирования URL sitemap файла',
          child: GestureDetector(
            onTap: () => _copySitemapUrlToClipboard(context, sitemapUrl),
            child: Container(
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sitemapUrl,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${errorUrls.length} ошибок',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.copy,
                    size: 14,
                    color: Colors.red.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Группируем ошибки по типам
      final errorsByType = <String, List<Map<String, dynamic>>>{};
      for (final error in errorUrls) {
        final statusCode = error['statusCode'] as int;
        final type = _getErrorType(statusCode);
        errorsByType.putIfAbsent(type, () => []).add(error);
      }

      // Показываем ошибки по типам
      errorsByType.forEach((type, errors) {
        widgets.add(
          Container(
            margin: const EdgeInsets.only(left: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getErrorTypeIcon(type),
                      size: 14,
                      color: _getErrorTypeColor(type),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getErrorTypeColor(type),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${errors.length})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ...errors.take(10).map((error) {
                  final url = error['url'] as SitemapUrl;
                  final statusCode = error['statusCode'] as int;
                  final color = _getStatusCodeColor(statusCode);

                  return Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 2),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Text(
                            '$statusCode',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            url.location,
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (errors.length > 10)
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 2),
                    child: Text(
                      '... и еще ${errors.length - 10} ошибок',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      });
    });

    return widgets;
  }

  List<Widget> _buildSitemapDetailsList() {
    return report.items.map((item) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isSuccess ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: item.isSuccess ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.isSuccess ? Icons.check_circle : Icons.error,
                  color: item.isSuccess ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.sitemapUrl,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (item.isSuccess) ...[
              Text(
                'Страниц: ${item.pageUrls.length} | Успешных: ${item.successfulUrls} | Ошибок: ${item.errorUrls}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ] else ...[
              Text(
                'Ошибка: ${item.errorMessage}',
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  Color _getStatusCodeColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return Colors.green;
    if (statusCode >= 300 && statusCode < 400) return Colors.orange;
    if (statusCode >= 400 && statusCode < 500) return Colors.red;
    if (statusCode >= 500 && statusCode < 600) return Colors.red.shade800;
    if (statusCode >= 990 && statusCode < 1000) return Colors.purple;
    return Colors.grey;
  }

  String _getErrorType(int statusCode) {
    if (statusCode >= 400 && statusCode < 500) {
      if (statusCode == 404) return 'Не найдено (404)';
      if (statusCode == 403) return 'Доступ запрещен (403)';
      if (statusCode == 401) return 'Не авторизован (401)';
      return 'Ошибки клиента (4xx)';
    }
    if (statusCode >= 500 && statusCode < 600) {
      if (statusCode == 500) return 'Внутренняя ошибка сервера (500)';
      if (statusCode == 502) return 'Плохой шлюз (502)';
      if (statusCode == 503) return 'Сервис недоступен (503)';
      return 'Ошибки сервера (5xx)';
    }
    if (statusCode >= 990 && statusCode < 1000) {
      if (statusCode == 995) return 'Ошибка подключения';
      if (statusCode == 996) return 'Таймаут получения';
      if (statusCode == 998) return 'Таймаут подключения';
      if (statusCode == 999) return 'Неизвестная ошибка';
      return 'Ошибки подключения';
    }
    return 'Другие ошибки';
  }

  IconData _getErrorTypeIcon(String type) {
    if (type.contains('404')) return Icons.search_off;
    if (type.contains('403')) return Icons.block;
    if (type.contains('401')) return Icons.lock;
    if (type.contains('4xx')) return Icons.error_outline;
    if (type.contains('500')) return Icons.dns;
    if (type.contains('502')) return Icons.router;
    if (type.contains('503')) return Icons.build;
    if (type.contains('5xx')) return Icons.dns;
    if (type.contains('подключения')) return Icons.wifi_off;
    if (type.contains('таймаут')) return Icons.timer_off;
    if (type.contains('неизвестная')) return Icons.help_outline;
    return Icons.error;
  }

  Color _getErrorTypeColor(String type) {
    if (type.contains('404')) return Colors.orange;
    if (type.contains('403')) return Colors.red;
    if (type.contains('401')) return Colors.red;
    if (type.contains('4xx')) return Colors.red;
    if (type.contains('500')) return Colors.red.shade800;
    if (type.contains('502')) return Colors.red.shade800;
    if (type.contains('503')) return Colors.red.shade800;
    if (type.contains('5xx')) return Colors.red.shade800;
    if (type.contains('подключения')) return Colors.purple;
    if (type.contains('таймаут')) return Colors.purple;
    if (type.contains('неизвестная')) return Colors.grey;
    return Colors.red;
  }

  int _getRedirectCount() {
    int count = 0;
    for (final item in report.items) {
      for (final url in item.pageUrls) {
        if (url.statusCode != null && url.statusCode! >= 300 && url.statusCode! < 400) {
          count++;
        }
      }
    }
    return count;
  }

  int _getClientErrorCount() {
    int count = 0;
    for (final item in report.items) {
      for (final url in item.pageUrls) {
        if (url.statusCode != null && url.statusCode! >= 400 && url.statusCode! < 500) {
          count++;
        }
      }
    }
    return count;
  }

  int _getServerErrorCount() {
    int count = 0;
    for (final item in report.items) {
      for (final url in item.pageUrls) {
        if (url.statusCode != null && url.statusCode! >= 500 && url.statusCode! < 600) {
          count++;
        }
      }
    }
    return count;
  }

  int _getConnectionErrorCount() {
    int count = 0;
    for (final item in report.items) {
      for (final url in item.pageUrls) {
        if (url.statusCode != null && url.statusCode! >= 990 && url.statusCode! < 1000) {
          count++;
        }
      }
    }
    return count;
  }

  void _copyReportToClipboard(BuildContext context) {
    final reportText = _generateReportText();
    Clipboard.setData(ClipboardData(text: reportText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Отчет скопирован в буфер обмена')),
    );
  }

  void _copySitemapUrlToClipboard(BuildContext context, String sitemapUrl) {
    Clipboard.setData(ClipboardData(text: sitemapUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('URL sitemap файла скопирован в буфер обмена'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _copyErrorUrlsToClipboard(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('ОШИБОЧНЫЕ URL ПО SITEMAP ФАЙЛАМ');
    buffer.writeln('=' * 50);
    buffer.writeln();

    int totalErrors = 0;

    for (final item in report.items) {
      final errorUrls = <SitemapUrl>[];

      for (final url in item.pageUrls) {
        if (url.statusCode != null && (url.statusCode! >= 400 || url.statusCode! >= 990)) {
          errorUrls.add(url);
        }
      }

      if (errorUrls.isNotEmpty) {
        buffer.writeln('SITEMAP: ${item.sitemapUrl}');
        buffer.writeln('Ошибок: ${errorUrls.length}');
        buffer.writeln();

        // Группируем по типам ошибок
        final errorsByType = <String, List<SitemapUrl>>{};
        for (final url in errorUrls) {
          final type = _getErrorType(url.statusCode!);
          errorsByType.putIfAbsent(type, () => []).add(url);
        }

        errorsByType.forEach((type, urls) {
          buffer.writeln('  $type (${urls.length}):');
          for (final url in urls) {
            buffer.writeln('    ${url.statusCode} - ${url.location}');
          }
          buffer.writeln();
        });

        buffer.writeln('-' * 40);
        buffer.writeln();
        totalErrors += errorUrls.length;
      }
    }

    buffer.writeln('ИТОГО: $totalErrors ошибочных URL');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Скопировано $totalErrors ошибочных URL с группировкой по sitemap файлам')),
    );
  }

  String _generateReportText() {
    final buffer = StringBuffer();
    buffer.writeln('ОТЧЕТ ПО SITEMAP INDEX');
    buffer.writeln('=' * 50);
    buffer.writeln('URL: ${report.originalUrl}');
    buffer.writeln('Дата: ${_formatDate(report.generatedAt)}');
    buffer.writeln();

    buffer.writeln('ОБЩАЯ СТАТИСТИКА:');
    buffer.writeln('Sitemap файлов: ${report.totalSitemaps}');
    buffer.writeln('Успешных sitemap: ${report.successfulSitemaps}');
    buffer.writeln('Ошибок sitemap: ${report.failedSitemaps}');
    buffer.writeln('Всего страниц: ${report.totalUrls}');
    buffer.writeln('Успешных страниц: ${report.successfulUrls}');
    buffer.writeln('Ошибочных страниц: ${report.errorUrls}');
    buffer.writeln();

    buffer.writeln('ДЕТАЛИ ПО SITEMAP ФАЙЛАМ:');
    for (final item in report.items) {
      buffer.writeln('- ${item.sitemapUrl}');
      if (item.isSuccess) {
        buffer.writeln('  Страниц: ${item.pageUrls.length}');
        buffer.writeln('  Успешных: ${item.successfulUrls}');
        buffer.writeln('  Ошибок: ${item.errorUrls}');
      } else {
        buffer.writeln('  Ошибка: ${item.errorMessage}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}

class _TitleWidget extends StatelessWidget {
  final String originalUrl;

  const _TitleWidget({required this.originalUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Отчет по sitemap index',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            originalUrl,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
