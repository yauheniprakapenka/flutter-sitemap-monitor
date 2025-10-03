// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../models/sitemap_url.dart';
import '../services/sitemap_parser.dart';
import '../services/url_filter.dart';
import 'report_screen.dart';
import 'sitemap_list_widget.dart';
import 'status_tabs_widget.dart';

class SitemapHomeScreen extends StatefulWidget {
  final String sitemapUrl;

  const SitemapHomeScreen({required this.sitemapUrl});

  @override
  State<SitemapHomeScreen> createState() => _SitemapHomeScreenState();
}

class _SitemapHomeScreenState extends State<SitemapHomeScreen> {
  List<SitemapUrl> _urls = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _totalUrls = 0;
  int _selectedTabIndex = 0;
  int _totalUrlsToCheck = 0;
  int _checkedUrlsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSitemap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Column(
          children: [
            const Text('Отчет по sitemap'),
            Text(
              widget.sitemapUrl,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        actions: [
          OutlinedButton(
            onPressed: _urls.isNotEmpty ? _showReport : null,
            child: const Text('Показать отчет'),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Column(
        children: [
          // Статистика
          Container(
            width: double.infinity,
            height: 132,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Статистика',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Всего URL: $_totalUrls',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (_selectedTabIndex > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Показано: ${_filteredUrls.length} (${UrlFilter.getTabTitle(_selectedTabIndex)})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (_selectedTabIndex > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      _getTabDescription(_selectedTabIndex),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ],
                if (_isLoading) ...[
                  const SizedBox(height: 8),
                  if (_totalUrlsToCheck > 0) ...[
                    Text(
                      'Проверено: $_checkedUrlsCount из $_totalUrlsToCheck URL',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _totalUrlsToCheck > 0 ? _checkedUrlsCount / _totalUrlsToCheck : 0,
                    ),
                  ] else ...[
                    Text(
                      'Загрузка sitemap...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    const LinearProgressIndicator(),
                  ],
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Ошибка: $_errorMessage',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Вкладки фильтрации
          if (_urls.isNotEmpty && !_isLoading)
            StatusTabsWidget(
              urls: _urls,
              selectedIndex: _selectedTabIndex,
              onTabChanged: _onTabChanged,
            ),
          // Список URL
          Expanded(
            child: _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ошибка загрузки sitemap',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadSitemap,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Попробовать снова'),
                        ),
                      ],
                    ),
                  )
                : SitemapListWidget(
                    urls: _filteredUrls,
                    isLoading: _isLoading,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSitemap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _totalUrlsToCheck = 0;
      _checkedUrlsCount = 0;
    });

    try {
      final urls = await SitemapParser.parseSitemapFromUrl(
        widget.sitemapUrl,
        onProgress: (current, total) {
          setState(() {
            _totalUrlsToCheck = total;
            _checkedUrlsCount = current;
          });
        },
      );
      setState(() {
        _urls = urls;
        _totalUrls = urls.length;
        _isLoading = false;
      });
    } on Exception catch (e) {
      // Если произошла ошибка парсинга XML, показываем её
      setState(() {
        _errorMessage = 'Ошибка парсинга sitemap: $e';
        _isLoading = false;
      });
    }
  }

  void _onTabChanged(int index) {
    // Проверяем, что индекс валидный (у нас 8 вкладок: 0-7)
    if (index >= 0 && index < 8) {
      setState(() {
        _selectedTabIndex = index;
      });
    }
  }

  List<SitemapUrl> get _filteredUrls {
    return UrlFilter.filterByStatus(_urls, _selectedTabIndex);
  }

  String _getTabDescription(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return 'Информационные ответы (100-199)';
      case 2:
        return 'Успешные запросы (200-299)';
      case 3:
        return 'Перенаправления (300-399)';
      case 4:
        return 'Ошибки клиента (400-499)';
      case 5:
        return 'Ошибки сервера (500-599)';
      case 6:
        return 'Ошибки подключения (990-999)';
      case 7:
        return 'Нестандартные коды и null';
      default:
        return '';
    }
  }

  void _showReport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportScreen(urls: _urls, sitemapUrl: widget.sitemapUrl),
      ),
    );
  }
}
