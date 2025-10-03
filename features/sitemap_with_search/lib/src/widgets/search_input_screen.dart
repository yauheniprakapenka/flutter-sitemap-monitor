// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchInputScreen extends StatefulWidget {
  final String? initialUrl;
  final String? initialSearchText;

  const SearchInputScreen({
    super.key,
    this.initialUrl,
    this.initialSearchText,
  });

  @override
  State<SearchInputScreen> createState() => _SearchInputScreenState();
}

class _SearchInputScreenState extends State<SearchInputScreen> {
  late final TextEditingController _urlController;
  late final TextEditingController _searchController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl ?? '');
    _searchController = TextEditingController(text: widget.initialSearchText ?? '');
  }

  @override
  void dispose() {
    _urlController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите URL sitemap';
    }

    final uri = Uri.tryParse(value);
    if (uri == null || (!uri.hasScheme || (!uri.scheme.startsWith('http')))) {
      return 'Пожалуйста, введите корректный URL (начинающийся с http:// или https://)';
    }

    return null;
  }

  String? _validateSearchText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите текст для поиска';
    }

    if (value.trim().length < 2) {
      return 'Текст для поиска должен содержать минимум 2 символа';
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

  Future<void> _onSearch() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final url = _urlController.text.trim();
        final searchText = _searchController.text.trim();

        // Небольшая задержка для демонстрации состояния загрузки
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          final result = await Navigator.of(context).pushNamed(
            '/sitemap-search-results',
            arguments: {
              'url': url,
              'searchText': searchText,
            },
          );

          // Обрабатываем возврат данных
          if (result is Map<String, String>) {
            _urlController.text = result['url'] ?? '';
            _searchController.text = result['searchText'] ?? '';
          }
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
        title: const Text('Sitemap Search'),
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
                Icons.search,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Поиск в sitemap',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Введите URL sitemap и текст для поиска в URL страниц',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Поле для URL sitemap
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onLongPress: _isLoading ? null : _pasteFromClipboard,
                      child: TextFormField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: 'URL sitemap.xml',
                          hintText: 'https://example.com/sitemap.xml',
                          prefixIcon: const Icon(Icons.link),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        validator: _validateUrl,
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

              const SizedBox(height: 24),

              // Поле для поискового текста
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Текст для поиска',
                  hintText: 'Например: "pagen" или "product"',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                textInputAction: TextInputAction.done,
                validator: _validateSearchText,
                onFieldSubmitted: (_) => _onSearch(),
                enabled: !_isLoading,
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _onSearch,
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
                        'Начать поиск',
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
                          'Как это работает:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Введите URL sitemap (может быть индексом с несколькими sitemap)\n'
                      '• Укажите текст для поиска в URL страниц\n'
                      '• Система найдет все страницы, содержащие указанный текст\n\n'
                      '💡 Совет: Поиск не чувствителен к регистру',
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
