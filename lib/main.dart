// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/sitemap_url.dart';
import 'services/sitemap_parser.dart';
import 'services/url_checker.dart';
import 'services/url_filter.dart';
import 'widgets/report_dialog_widget.dart';
import 'widgets/sitemap_list_widget.dart';
import 'widgets/status_tabs_widget.dart';

void main() {
  runApp(const SitemapApp());
}

class SitemapApp extends StatelessWidget {
  const SitemapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sitemap Parser',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SitemapHomePage(),
    );
  }
}

class SitemapHomePage extends StatefulWidget {
  const SitemapHomePage({super.key});

  @override
  State<SitemapHomePage> createState() => _SitemapHomePageState();
}

class _SitemapHomePageState extends State<SitemapHomePage> {
  List<SitemapUrl> _urls = [];
  bool _isLoading = false;
  bool _isCheckingStatus = false;
  String? _errorMessage;
  int _totalUrls = 0;
  int _checkedUrls = 0;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSitemap();
  }

  Future<void> _loadSitemap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final urls = await SitemapParser.parseSitemapFromAssets('assets/sitemap.xml');
      setState(() {
        _urls = urls;
        _totalUrls = urls.length;
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkUrlsStatus() async {
    if (_urls.isEmpty) return;

    setState(() {
      _isCheckingStatus = true;
      _checkedUrls = 0;
    });

    try {
      final updatedUrls = await UrlChecker.checkUrlsStatusBatch(
        _urls,
        batchSize: 5,
        onProgress: (current, total) {
          setState(() {
            _checkedUrls = current;
          });
        },
      );

      setState(() {
        _urls = updatedUrls;
        _isCheckingStatus = false;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'Ошибка проверки статус-кодов: $e';
        _isCheckingStatus = false;
      });
    }
  }

  void _onTabChanged(int index) {
    // Проверяем, что индекс валидный (у нас 7 вкладок: 0-6)
    if (index >= 0 && index < 7) {
      setState(() {
        _selectedTabIndex = index;
      });
    }
  }

  List<SitemapUrl> get _filteredUrls {
    return UrlFilter.filterByStatus(_urls, _selectedTabIndex);
  }

  void _copyAllUrlsToClipboard() {
    final urls = _filteredUrls.map((url) => url.location).join('\n');
    Clipboard.setData(ClipboardData(text: urls));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Скопировано ${_filteredUrls.length} URL в буфер обмена',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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
        return 'Ошибки подключения и нестандартные коды';
      default:
        return '';
    }
  }

  void _showReport() {
    showDialog(
      context: context,
      builder: (context) => ReportDialogWidget(urls: _urls),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Sitemap Parser'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: _urls.isNotEmpty ? _showReport : null,
            tooltip: 'Показать отчет',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _filteredUrls.isNotEmpty ? _copyAllUrlsToClipboard : null,
            tooltip: 'Копировать все URL',
          ),
          IconButton(
            icon: const Icon(Icons.http),
            onPressed: _isCheckingStatus ? null : _checkUrlsStatus,
            tooltip: 'Проверить статус-коды',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSitemap,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: Column(
        children: [
          // Статистика
          Container(
            width: double.infinity,
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
                if (_isCheckingStatus) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Проверено: $_checkedUrls из $_totalUrls',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: _totalUrls > 0 ? _checkedUrls / _totalUrls : 0,
                  ),
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
              isLoading: _isCheckingStatus,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _isCheckingStatus ? null : _checkUrlsStatus,
        tooltip: 'Проверить статус-коды',
        child: _isCheckingStatus
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.http),
      ),
    );
  }
}
