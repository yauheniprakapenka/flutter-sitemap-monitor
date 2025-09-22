import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sitemap_url.dart';

class SitemapListWidget extends StatelessWidget {
  final List<SitemapUrl> urls;
  final bool isLoading;

  const SitemapListWidget({
    super.key,
    required this.urls,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (urls.isEmpty) {
      return const Center(
        child: Text(
          'Нет данных для отображения',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: urls.length,
      itemBuilder: (context, index) {
        final url = urls[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusCodeColor(url.statusCode!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${url.statusCode}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              url.location,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (url.lastModified != null)
                  Text(
                    'Последнее изменение: ${_formatDate(url.lastModified!)}',
                    style: const TextStyle(fontSize: 11),
                  ),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              _copyUrlToClipboard(context, url.location);
            },
            onLongPress: () {
              _showUrlDetails(context, url);
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  void _copyUrlToClipboard(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));

    // Показываем уведомление о копировании
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'URL скопирован в буфер обмена',
                style: TextStyle(fontSize: 14),
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

  Color _getStatusCodeColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green; // Успешные запросы
    } else if (statusCode >= 300 && statusCode < 400) {
      return Colors.orange; // Перенаправления
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.red; // Ошибки клиента
    } else if (statusCode >= 500 && statusCode < 600) {
      return Colors.red.shade800; // Ошибки сервера
    } else if (statusCode >= 990 && statusCode < 1000) {
      return Colors.purple; // Ошибки подключения
    } else {
      return Colors.grey; // Неизвестные коды
    }
  }

  String _getStatusCodeDescription(int statusCode) {
    switch (statusCode) {
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 204:
        return 'No Content';
      case 301:
        return 'Moved Permanently';
      case 302:
        return 'Found';
      case 304:
        return 'Not Modified';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 500:
        return 'Internal Server Error';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      // Коды ошибок подключения
      case 991:
        return 'Другая ошибка';
      case 992:
        return 'Неизвестная ошибка';
      case 993:
        return 'Запрос отменен';
      case 994:
        return 'Ошибка ответа сервера';
      case 995:
        return 'Ошибка подключения';
      case 996:
        return 'Таймаут получения';
      case 997:
        return 'Таймаут отправки';
      case 998:
        return 'Таймаут подключения';
      case 999:
        return 'Неизвестная ошибка';
      default:
        if (statusCode >= 200 && statusCode < 300) {
          return 'Success';
        } else if (statusCode >= 300 && statusCode < 400) {
          return 'Redirect';
        } else if (statusCode >= 400 && statusCode < 500) {
          return 'Client Error';
        } else if (statusCode >= 500 && statusCode < 600) {
          return 'Server Error';
        } else if (statusCode >= 990 && statusCode < 1000) {
          return 'Connection Error';
        } else {
          return 'Unknown';
        }
    }
  }

  void _showUrlDetails(BuildContext context, SitemapUrl url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Детали URL'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'URL:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              SelectableText(
                url.location,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              if (url.statusCode != null) ...[
                Text(
                  'Статус код:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusCodeColor(url.statusCode!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${url.statusCode}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusCodeDescription(url.statusCode!),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              if (url.lastModified != null) ...[
                Text(
                  'Последнее изменение:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(_formatDate(url.lastModified!)),
                const SizedBox(height: 16),
              ],
              if (url.changeFrequency != null) ...[
                Text(
                  'Частота изменений:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(url.changeFrequency!),
                const SizedBox(height: 16),
              ],
              if (url.priority != null) ...[
                Text(
                  'Приоритет:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(url.priority.toString()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              _copyUrlToClipboard(context, url.location);
            },
            icon: const Icon(Icons.copy),
            label: const Text('Копировать'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
