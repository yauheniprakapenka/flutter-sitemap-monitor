// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sitemap_url.dart';

class ReportDialogWidget extends StatelessWidget {
  final List<SitemapUrl> urls;

  const ReportDialogWidget({
    required this.urls,
  });

  @override
  Widget build(BuildContext context) {
    final report = _generateReport();

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.assessment, color: Colors.blue),
          SizedBox(width: 8),
          Text('Отчет о проверке'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статистика
            _buildStatsSection(report),
            const SizedBox(height: 16),

            // Проблемные URL
            Expanded(
              child: _buildProblematicUrlsSection(report, context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _copyReportToClipboard(context, report),
          icon: const Icon(Icons.copy),
          label: const Text('Копировать отчет'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }

  Widget _buildStatsSection(ReportData report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Общая статистика',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Всего проверено',
                    '${report.totalChecked}',
                    Colors.blue,
                    Icons.list,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Успешных',
                    '${report.successful}',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Ошибок',
                    '${report.errors}',
                    Colors.red,
                    Icons.error,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Процент ошибок',
                    '${report.errorPercentage}%',
                    report.errorPercentage > 10 ? Colors.red : Colors.orange,
                    Icons.pie_chart,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProblematicUrlsSection(ReportData report, BuildContext context) {
    if (report.problematicUrls.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Отлично! Проблемных URL не найдено',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Проблемные URL (${report.problematicUrls.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: report.problematicUrls.length,
            itemBuilder: (context, index) {
              final url = report.problematicUrls[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusCodeColor(url.statusCode ?? 0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${url.statusCode ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    url.location,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _getStatusCodeDescription(url.statusCode ?? 0),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () => _copyUrlToClipboard(context, url.location),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  ReportData _generateReport() {
    final totalChecked = urls.length;
    final successful = urls.where((url) =>
        url.statusCode != null && url.statusCode! >= 200 && url.statusCode! < 300).length;
    final errors = totalChecked - successful;
    final errorPercentage = totalChecked > 0 ? (errors / totalChecked * 100).round() : 0;

    final problematicUrls = urls.where((url) =>
        url.statusCode == null ||
        url.statusCode! < 200 ||
        url.statusCode! >= 300).toList();

    return ReportData(
      totalChecked: totalChecked,
      successful: successful,
      errors: errors,
      errorPercentage: errorPercentage,
      problematicUrls: problematicUrls,
    );
  }

  Color _getStatusCodeColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green;
    } else if (statusCode >= 300 && statusCode < 400) {
      return Colors.orange;
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.red;
    } else if (statusCode >= 500) {
      return Colors.red.shade800;
    } else {
      return Colors.grey;
    }
  }

  String _getStatusCodeDescription(int statusCode) {
    if (statusCode == 0) return 'Ошибка подключения';

    switch (statusCode) {
      case 200: return 'OK';
      case 301: return 'Moved Permanently';
      case 302: return 'Found';
      case 404: return 'Not Found';
      case 500: return 'Internal Server Error';
      default:
        if (statusCode >= 200 && statusCode < 300) return 'Success';
        if (statusCode >= 300 && statusCode < 400) return 'Redirect';
        if (statusCode >= 400 && statusCode < 500) return 'Client Error';
        if (statusCode >= 500) return 'Server Error';
        return 'Unknown';
    }
  }

  void _copyUrlToClipboard(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL скопирован в буфер обмена'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyReportToClipboard(BuildContext context, ReportData report) {
    final reportText = _generateReportText(report);
    Clipboard.setData(ClipboardData(text: reportText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Отчет скопирован в буфер обмена'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  String _generateReportText(ReportData report) {
    final buffer = StringBuffer();
    buffer.writeln('=== ОТЧЕТ О ПРОВЕРКЕ SITEMAP ===');
    buffer.writeln('Дата: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln();
    buffer.writeln('СТАТИСТИКА:');
    buffer.writeln('• Всего проверено: ${report.totalChecked}');
    buffer.writeln('• Успешных: ${report.successful}');
    buffer.writeln('• Ошибок: ${report.errors}');
    buffer.writeln('• Процент ошибок: ${report.errorPercentage}%');
    buffer.writeln();

    if (report.problematicUrls.isNotEmpty) {
      buffer.writeln('ПРОБЛЕМНЫЕ URL:');
      for (final url in report.problematicUrls) {
        buffer.writeln('• [${url.statusCode ?? 'N/A'}] ${url.location}');
      }
    } else {
      buffer.writeln('ПРОБЛЕМНЫХ URL НЕ НАЙДЕНО');
    }

    return buffer.toString();
  }
}

class ReportData {
  final int totalChecked;
  final int successful;
  final int errors;
  final int errorPercentage;
  final List<SitemapUrl> problematicUrls;

  ReportData({
    required this.totalChecked,
    required this.successful,
    required this.errors,
    required this.errorPercentage,
    required this.problematicUrls,
  });
}
