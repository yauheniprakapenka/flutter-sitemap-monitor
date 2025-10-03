// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../models/sitemap_search_result.dart';
import '../services/sitemap_search_service.dart';

class SearchResultsScreen extends StatefulWidget {
  final String sitemapUrl;
  final String searchText;

  const SearchResultsScreen({
    required this.sitemapUrl,
    required this.searchText,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<SitemapSearchResult> _results = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    try {
      final results = await SitemapSearchService.searchInSitemaps(
        widget.sitemapUrl,
        widget.searchText,
        onProgress: (current, total) {
          if (mounted) {
            setState(() {
              // Можно добавить индикатор прогресса
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты поиска'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () => _navigateBack(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Назад к поиску',
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _performSearch,
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить поиск',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Поиск в sitemap...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
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
              'Ошибка при поиске',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Ничего не найдено',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'По запросу "${widget.searchText}" ничего не найдено',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Заголовок с информацией о поиске
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Поиск: "${widget.searchText}"',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sitemap: ${widget.sitemapUrl}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Найдено совпадений: ${_getTotalMatches()}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Список результатов
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final result = _results[index];
              return _buildSitemapResult(result);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSitemapResult(SitemapSearchResult result) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text(
          _getSitemapName(result.sitemapUrl),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Найдено: ${result.matchingCount} из ${result.totalUrls}',
          style: TextStyle(
            color: result.matchingCount > 0
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: result.matchingCount > 0
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade400,
          child: Text(
            '${result.matchingCount}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          if (result.matchingUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Найденные URL:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...result.matchingUrls.map((url) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(
                          child: SelectableText(
                            url,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'В этом sitemap совпадений не найдено',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getSitemapName(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      // Извлекаем название sitemap файла из пути
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        // Если это sitemap файл, показываем его название
        if (fileName.contains('sitemap')) {
          return fileName;
        }
        // Иначе показываем последний сегмент пути
        return fileName;
      }
      // Если нет сегментов пути, показываем домен
      return uri.host;
    }
    return url;
  }

  int _getTotalMatches() {
    return _results.fold(0, (sum, result) => sum + result.matchingCount);
  }

  void _navigateBack() {
    Navigator.of(context).pop({
      'url': widget.sitemapUrl,
      'searchText': widget.searchText,
    });
  }
}
