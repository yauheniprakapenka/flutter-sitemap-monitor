// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../models/sitemap_index_result.dart';
import '../services/sitemap_index_checker.dart';
import 'sitemap_index_report_screen.dart';

class SitemapIndexResultsScreen extends StatelessWidget {
  final List<SitemapIndexResult> results;
  final String originalUrl;

  const SitemapIndexResultsScreen({
    super.key,
    required this.results,
    required this.originalUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Подсчитываем статистику
    int totalPages = 0;
    int successfulSitemaps = 0;
    int failedSitemaps = 0;

    for (final result in results) {
      if (result.isSuccess) {
        successfulSitemaps++;
        totalPages += result.pageUrls.length;
      } else {
        failedSitemaps++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты анализа'),
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => _showSummaryDialog(context, results, totalPages, successfulSitemaps, failedSitemaps),
            icon: const Icon(Icons.info_outline),
            tooltip: 'Сводка',
          ),
          IconButton(
            onPressed: () => _startStatusCheck(context),
            icon: const Icon(Icons.analytics),
            tooltip: 'Проверить статус страниц',
          ),
        ],
      ),
      body: Column(
        children: [
          // Статистическая панель
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Анализ sitemap index',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            originalUrl,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Sitemap файлов',
                        '${results.length}',
                        Icons.folder,
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Успешно',
                        '$successfulSitemaps',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Ошибки',
                        '$failedSitemaps',
                        Icons.error,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Страниц',
                        '$totalPages',
                        Icons.web,
                        colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Список результатов
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return _buildSitemapResultCard(context, result, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSitemapResultCard(
    BuildContext context,
    SitemapIndexResult result,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: result.isSuccess
            ? colorScheme.surface
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isSuccess
              ? colorScheme.outline.withOpacity(0.2)
              : Colors.red.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (result.isSuccess ? Colors.grey : Colors.red).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: result.isSuccess
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            result.isSuccess ? Icons.check_circle : Icons.error,
            color: result.isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          'Sitemap #$index',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              result.sitemapUrl,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  result.isSuccess ? Icons.web : Icons.error_outline,
                  size: 16,
                  color: result.isSuccess ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  result.isSuccess
                      ? '${result.pageUrls.length} страниц'
                      : 'Ошибка: ${result.errorMessage}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: result.isSuccess ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: result.isSuccess && result.pageUrls.isNotEmpty
            ? [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Найденные страницы:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...result.pageUrls.take(10).map((url) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.link,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                url,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      if (result.pageUrls.length > 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '... и еще ${result.pageUrls.length - 10} страниц',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ]
            : [],
      ),
    );
  }

  void _showSummaryDialog(
    BuildContext context,
    List<SitemapIndexResult> results,
    int totalPages,
    int successfulSitemaps,
    int failedSitemaps,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сводка анализа'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('Всего sitemap файлов:', '${results.length}'),
            _buildSummaryRow('Успешно обработано:', '$successfulSitemaps'),
            _buildSummaryRow('Ошибок:', '$failedSitemaps'),
            _buildSummaryRow('Всего страниц:', '$totalPages'),
            if (failedSitemaps > 0) ...[
              const SizedBox(height: 16),
              const Text(
                'Ошибки:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...results
                  .where((r) => !r.isSuccess)
                  .map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${r.sitemapUrl}: ${r.errorMessage}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _startStatusCheck(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _StatusCheckDialog(
        results: results,
        originalUrl: originalUrl,
      ),
    );
  }
}

class _StatusCheckDialog extends StatefulWidget {
  final List<SitemapIndexResult> results;
  final String originalUrl;

  const _StatusCheckDialog({
    required this.results,
    required this.originalUrl,
  });

  @override
  State<_StatusCheckDialog> createState() => _StatusCheckDialogState();
}

class _StatusCheckDialogState extends State<_StatusCheckDialog> {
  bool _isChecking = false;
  int _currentProgress = 0;
  int _totalProgress = 0;
  String _currentStatus = '';

  @override
  void initState() {
    super.initState();
    _startCheck();
  }

  Future<void> _startCheck() async {
    setState(() {
      _isChecking = true;
      _currentStatus = 'Подготовка к проверке...';
    });

    try {
      // Подсчитываем общее количество страниц для проверки
      int totalPages = 0;
      for (final result in widget.results) {
        if (result.isSuccess) {
          totalPages += result.pageUrls.length;
        }
      }

      setState(() {
        _totalProgress = totalPages;
        _currentStatus = 'Начинаем проверку $totalPages страниц...';
      });

      // Запускаем проверку
      final report = await SitemapIndexChecker.checkAllPagesStatus(
        widget.results,
        widget.originalUrl,
        onProgress: (current, total) {
          if (mounted) {
            setState(() {
              _currentProgress = current;
              _currentStatus = 'Проверено $current из $total страниц...';
            });
          }
        },
      );

      if (mounted) {
        // Закрываем диалог и переходим на экран отчета
        Navigator.of(context).pop();
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SitemapIndexReportScreen(report: report),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _currentStatus = 'Ошибка: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Проверка статуса страниц'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isChecking) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_currentStatus),
            const SizedBox(height: 16),
            if (_totalProgress > 0) ...[
              LinearProgressIndicator(
                value: _currentProgress / _totalProgress,
              ),
              const SizedBox(height: 8),
              Text('$_currentProgress / $_totalProgress'),
            ],
          ] else ...[
            Text(_currentStatus),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        ],
      ),
    );
  }
}
