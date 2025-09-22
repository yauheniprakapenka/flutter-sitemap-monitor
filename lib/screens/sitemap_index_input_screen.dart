// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sitemap_index_result.dart';
import '../services/sitemap_index_parser.dart';
import 'sitemap_index_results_screen.dart';

class SitemapIndexInputScreen extends StatefulWidget {
  const SitemapIndexInputScreen({super.key});

  @override
  State<SitemapIndexInputScreen> createState() => _SitemapIndexInputScreenState();
}

class _SitemapIndexInputScreenState extends State<SitemapIndexInputScreen> {
  final TextEditingController _urlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите URL';
    }

    final uri = Uri.tryParse(value);
    if (uri == null || (!uri.hasScheme || (!uri.scheme.startsWith('http')))) {
      return 'Пожалуйста, введите корректный URL (начинающийся с http:// или https://)';
    }

    return null;
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
        _urlController.text = clipboardData.text!;
        // Валидируем вставленный текст
        _formKey.currentState?.validate();
      } else {
        _showSnackBar('Буфер обмена пуст');
      }
    } on Exception {
      _showSnackBar('Ошибка при вставке из буфера обмена');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final url = _urlController.text.trim();

        if (mounted) {
          // Получаем и парсим sitemap index с данными страниц
          final List<SitemapIndexResult> results = await SitemapIndexParser.parseSitemapIndexWithPages(url);

          // Переходим на экран результатов
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SitemapIndexResultsScreen(
                results: results,
                originalUrl: url,
              ),
            ),
          );
        }
      } on Exception catch (e) {
        if (mounted) {
          _showSnackBar('Ошибка: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sitemap Index Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.account_tree,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Введите URL sitemap index',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Укажите URL, содержащий sitemap index с вложенными sitemap файлами',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onLongPress: _isLoading ? null : _pasteFromClipboard,
                      child: TextFormField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: 'URL sitemap index',
                          hintText: 'https://example.com/sitemap_index.xml',
                          prefixIcon: const Icon(Icons.link),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        validator: _validateUrl,
                        onFieldSubmitted: (_) => _onContinue(),
                        enabled: !_isLoading,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isLoading ? null : _pasteFromClipboard,
                    icon: const Icon(Icons.paste),
                    tooltip: 'Вставить из буфера обмена',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _onContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Начать анализ sitemap index',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Что такое sitemap index:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sitemap index — это XML файл, который содержит ссылки на другие sitemap файлы. '
                      'Используется для организации больших сайтов с множеством страниц.\n\n'
                      'Примеры URL:\n'
                      '• https://example.com/sitemap_index.xml\n'
                      '• https://site.com/sitemap.xml\n'
                      '• https://blog.com/sitemap-index.xml\n\n'
                      '💡 Совет: Используйте кнопку вставки или длинное нажатие на поле',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
