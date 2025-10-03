// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sitemap_url.dart';

class ReportScreen extends StatelessWidget {
  final List<SitemapUrl> urls;
  final String sitemapUrl;

  const ReportScreen({required this.urls, required this.sitemapUrl});

  String _formatDate(DateTime date) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final totalUrls = urls.length;
    final successCount = urls
        .where((url) => url.statusCode != null && url.statusCode! >= 200 && url.statusCode! < 300)
        .length;
    final redirectCount = urls
        .where((url) => url.statusCode != null && url.statusCode! >= 300 && url.statusCode! < 400)
        .length;
    final clientErrorCount = urls
        .where((url) => url.statusCode != null && url.statusCode! >= 400 && url.statusCode! < 500)
        .length;
    final serverErrorCount = urls
        .where((url) => url.statusCode != null && url.statusCode! >= 500 && url.statusCode! < 600)
        .length;
    final connectionErrorCount = urls
        .where((url) => url.statusCode != null && url.statusCode! >= 990 && url.statusCode! < 1000)
        .length;
    final otherCount = urls
        .where((url) =>
            url.statusCode == null ||
            url.statusCode! < 100 ||
            (url.statusCode! >= 600 && url.statusCode! < 990) ||
            url.statusCode! >= 1000)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчет по sitemap'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TitleWidget(sitemapUrl: sitemapUrl),
            const SizedBox(height: 24),

            Text('Дата: ${_formatDate(DateTime.now())}', style: const TextStyle(fontSize: 16)),
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
                              _buildStatRow('Всего URL', totalUrls, Colors.blue),
                              _buildStatRow('Успешные (2xx)', successCount, Colors.green),
                              _buildStatRow('Перенаправления (3xx)', redirectCount, Colors.orange),
                              _buildStatRow('Ошибки клиента (4xx)', clientErrorCount, Colors.red),
                              _buildStatRow(
                                  'Ошибки сервера (5xx)', serverErrorCount, Colors.red.shade800),
                              _buildStatRow(
                                  'Ошибки подключения', connectionErrorCount, Colors.purple),
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
                                _buildPercentageRow(
                                    'Успешные', successCount, totalUrls, Colors.green),
                                _buildPercentageRow(
                                    'Перенаправления', redirectCount, totalUrls, Colors.orange),
                                _buildPercentageRow(
                                    'Ошибки клиента', clientErrorCount, totalUrls, Colors.red),
                                _buildPercentageRow('Ошибки сервера', serverErrorCount, totalUrls,
                                    Colors.red.shade800),
                                _buildPercentageRow('Ошибки подключения', connectionErrorCount,
                                    totalUrls, Colors.purple),
                                _buildPercentageRow(
                                    'Остальное', otherCount, totalUrls, Colors.grey),
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
                      ..._buildErrorUrlsList(),
                    ],
                  ),
                ),
              ),
            ],
          ],
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
    for (final url in urls) {
      if (url.statusCode != null) {
        statusCodeCounts[url.statusCode!] = (statusCodeCounts[url.statusCode!] ?? 0) + 1;
      }
    }

    final sortedCodes = statusCodeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedCodes.map((entry) {
      final statusCode = entry.key;
      final count = entry.value;
      final color = _getStatusCodeColor(statusCode);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('HTTP $statusCode', style: const TextStyle(fontSize: 13)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
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

  List<Widget> _buildErrorUrlsList() {
    final errorUrls = urls.where((url) {
      if (url.statusCode == null) return false;
      return (url.statusCode! >= 400 && url.statusCode! < 500) ||
          (url.statusCode! >= 500 && url.statusCode! < 600) ||
          (url.statusCode! >= 990 && url.statusCode! < 1000);
    }).toList()
      ..sort((a, b) => (a.statusCode ?? 0).compareTo(b.statusCode ?? 0));

    // Группируем URL по типам ошибок
    final clientErrors =
        errorUrls.where((url) => url.statusCode! >= 400 && url.statusCode! < 500).toList();
    final serverErrors =
        errorUrls.where((url) => url.statusCode! >= 500 && url.statusCode! < 600).toList();
    final connectionErrors =
        errorUrls.where((url) => url.statusCode! >= 990 && url.statusCode! < 1000).toList();

    final List<Widget> widgets = [];

    // Добавляем группу ошибок клиента (4xx)
    if (clientErrors.isNotEmpty) {
      widgets.add(_buildGroupHeader('Ошибки клиента (4xx)', Colors.red, clientErrors.length));
      widgets.addAll(clientErrors.take(10).map((url) => _buildErrorUrlItem(url)));
      if (clientErrors.length > 10) {
        widgets.add(_buildMoreItemsIndicator(clientErrors.length - 10));
      }
    }

    // Добавляем группу ошибок сервера (5xx)
    if (serverErrors.isNotEmpty) {
      widgets
          .add(_buildGroupHeader('Ошибки сервера (5xx)', Colors.red.shade800, serverErrors.length));
      widgets.addAll(serverErrors.take(10).map((url) => _buildErrorUrlItem(url)));
      if (serverErrors.length > 10) {
        widgets.add(_buildMoreItemsIndicator(serverErrors.length - 10));
      }
    }

    // Добавляем группу ошибок подключения
    if (connectionErrors.isNotEmpty) {
      widgets.add(_buildGroupHeader('Ошибки подключения', Colors.purple, connectionErrors.length));
      widgets.addAll(connectionErrors.take(10).map((url) => _buildErrorUrlItem(url)));
      if (connectionErrors.length > 10) {
        widgets.add(_buildMoreItemsIndicator(connectionErrors.length - 10));
      }
    }

    return widgets;
  }

  Widget _buildGroupHeader(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorUrlItem(SitemapUrl url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: _getStatusCodeColor(url.statusCode!).withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: _getStatusCodeColor(url.statusCode!).withOpacity(0.3)),
            ),
            child: Text(
              '${url.statusCode}',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: _getStatusCodeColor(url.statusCode!),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              url.location,
              style: const TextStyle(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreItemsIndicator(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '... и еще $count',
        style: TextStyle(
          fontSize: 10,
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Color _getStatusCodeColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green;
    } else if (statusCode >= 300 && statusCode < 400) {
      return Colors.orange;
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.red;
    } else if (statusCode >= 500 && statusCode < 600) {
      return Colors.red.shade800;
    } else if (statusCode >= 990 && statusCode < 1000) {
      return Colors.purple;
    } else {
      return Colors.grey;
    }
  }

  void _copyReportToClipboard(BuildContext context) {
    final report = _generateReportText();
    Clipboard.setData(ClipboardData(text: report));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Отчет скопирован в буфер обмена'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyErrorUrlsToClipboard(BuildContext context) {
    final errorUrls = urls.where((url) {
      if (url.statusCode == null) return false;
      return (url.statusCode! >= 400 && url.statusCode! < 500) ||
          (url.statusCode! >= 500 && url.statusCode! < 600) ||
          (url.statusCode! >= 990 && url.statusCode! < 1000);
    }).toList()
      ..sort((a, b) => (a.statusCode ?? 0).compareTo(b.statusCode ?? 0));

    final errorUrlsText = errorUrls.map((url) => url.location).join('\n');

    Clipboard.setData(ClipboardData(text: errorUrlsText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Скопировано ${urls.where((url) {
          if (url.statusCode == null) return false;
          return (url.statusCode! >= 400 && url.statusCode! < 500) ||
              (url.statusCode! >= 500 && url.statusCode! < 600) ||
              (url.statusCode! >= 990 && url.statusCode! < 1000);
        }).length} ошибочных URL'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _generateReportText() {
    final totalUrls = urls.length;
    final successCount = urls
        .where((url) => url.statusCode != null && url.statusCode! >= 200 && url.statusCode! < 300)
        .length;
    final redirectCount = urls
        .where((url) => url.statusCode != null && url.statusCode! >= 300 && url.statusCode! < 400)
        .length;
    final clientErrorCount = urls
        .where((url) => url.statusCode != null && url.statusCode! >= 400 && url.statusCode! < 500)
        .length;
    final serverErrorCount = urls
        .where((url) => url.statusCode != null && url.statusCode! >= 500 && url.statusCode! < 600)
        .length;
    final connectionErrorCount = urls
        .where((url) => url.statusCode != null && url.statusCode! >= 990 && url.statusCode! < 1000)
        .length;
    final otherCount = urls
        .where((url) =>
            url.statusCode == null ||
            url.statusCode! < 100 ||
            (url.statusCode! >= 600 && url.statusCode! < 990) ||
            url.statusCode! >= 1000)
        .length;

    final buffer = StringBuffer();
    buffer.writeln('ОТЧЕТ ПО SITEMAP');
    buffer.writeln('================');
    buffer.writeln();
    buffer.writeln('Общая статистика:');
    buffer.writeln('Всего URL: $totalUrls');
    buffer.writeln('Успешные (2xx): $successCount');
    buffer.writeln('Перенаправления (3xx): $redirectCount');
    buffer.writeln('Ошибки клиента (4xx): $clientErrorCount');
    buffer.writeln('Ошибки сервера (5xx): $serverErrorCount');
    buffer.writeln('Ошибки подключения: $connectionErrorCount');
    buffer.writeln('Остальное: $otherCount');
    buffer.writeln();

    if (totalUrls > 0) {
      buffer.writeln('Процентное соотношение:');
      buffer.writeln('Успешные: ${(successCount / totalUrls * 100).toStringAsFixed(1)}%');
      buffer.writeln('Перенаправления: ${(redirectCount / totalUrls * 100).toStringAsFixed(1)}%');
      buffer.writeln('Ошибки клиента: ${(clientErrorCount / totalUrls * 100).toStringAsFixed(1)}%');
      buffer.writeln('Ошибки сервера: ${(serverErrorCount / totalUrls * 100).toStringAsFixed(1)}%');
      buffer.writeln(
          'Ошибки подключения: ${(connectionErrorCount / totalUrls * 100).toStringAsFixed(1)}%');
      buffer.writeln('Остальное: ${(otherCount / totalUrls * 100).toStringAsFixed(1)}%');
      buffer.writeln();
    }

    final errorUrls = urls.where((url) {
      if (url.statusCode == null) return false;
      return (url.statusCode! >= 400 && url.statusCode! < 500) ||
          (url.statusCode! >= 500 && url.statusCode! < 600) ||
          (url.statusCode! >= 990 && url.statusCode! < 1000);
    }).toList()
      ..sort((a, b) => (a.statusCode ?? 0).compareTo(b.statusCode ?? 0));

    if (errorUrls.isNotEmpty) {
      buffer.writeln('Ошибочные URL:');
      for (final url in errorUrls) {
        buffer.writeln('${url.statusCode} - ${url.location}');
      }
    }

    return buffer.toString();
  }
}

class _TitleWidget extends StatelessWidget {
  final String sitemapUrl;

  const _TitleWidget({
    required this.sitemapUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Отчет по sitemap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(
          sitemapUrl,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
