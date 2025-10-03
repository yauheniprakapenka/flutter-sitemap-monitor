// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../models/sitemap_url.dart';

class StatusTabsWidget extends StatefulWidget {
  final List<SitemapUrl> urls;
  final int selectedIndex;
  final Function(int) onTabChanged;

  const StatusTabsWidget({
    required this.urls,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  State<StatusTabsWidget> createState() => _StatusTabsWidgetState();
}

class _StatusTabsWidgetState extends State<StatusTabsWidget> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _getTabs().length,
      vsync: this,
      initialIndex: widget.selectedIndex,
    );
  }

  @override
  void didUpdateWidget(StatusTabsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newTabsLength = _getTabs().length;
    final oldTabsLength = _tabController.length;

    // Если количество вкладок изменилось, пересоздаем контроллер
    if (newTabsLength != oldTabsLength) {
      _tabController.dispose();
      _tabController = TabController(
        length: newTabsLength,
        vsync: this,
        initialIndex: widget.selectedIndex < newTabsLength ? widget.selectedIndex : 0,
      );
    } else if (oldWidget.selectedIndex != widget.selectedIndex) {
      // Если количество вкладок не изменилось, просто меняем индекс
      if (widget.selectedIndex < _tabController.length) {
        _tabController.animateTo(widget.selectedIndex);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _getTabs();

    return Column(
      children: [
        TabBar(
          isScrollable: true,
          controller: _tabController,
          onTap: widget.onTabChanged,
          tabs: tabs.map((tab) => Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tab.icon != null) ...[
                  Icon(tab.icon, size: 16),
                  const SizedBox(width: 4),
                ],
                Text(tab.label),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tab.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${tab.count}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: tab.color,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  List<StatusTab> _getTabs() {
    final allCount = widget.urls.length;
    final infoCount = widget.urls.where((url) => url.statusCode != null && url.statusCode! >= 100 && url.statusCode! < 200).length;
    final successCount = widget.urls.where((url) => url.statusCode != null && url.statusCode! >= 200 && url.statusCode! < 300).length;
    final redirectCount = widget.urls.where((url) => url.statusCode != null && url.statusCode! >= 300 && url.statusCode! < 400).length;
    final clientErrorCount = widget.urls.where((url) => url.statusCode != null && url.statusCode! >= 400 && url.statusCode! < 500).length;
    final serverErrorCount = widget.urls.where((url) => url.statusCode != null && url.statusCode! >= 500 && url.statusCode! < 600).length;
    final connectionErrorCount = widget.urls.where((url) => url.statusCode != null && url.statusCode! >= 990 && url.statusCode! < 1000).length;
    final otherCount = widget.urls.where((url) => url.statusCode == null || url.statusCode! < 100 || (url.statusCode! >= 600 && url.statusCode! < 990) || url.statusCode! >= 1000).length;

    return [
      StatusTab(
        label: 'Все',
        count: allCount,
        color: Colors.blue,
        icon: Icons.list,
      ),
      StatusTab(
        label: '1xx',
        count: infoCount,
        color: Colors.cyan,
        icon: Icons.info_outline,
      ),
      StatusTab(
        label: '2xx',
        count: successCount,
        color: Colors.green,
        icon: Icons.check_circle,
      ),
      StatusTab(
        label: '3xx',
        count: redirectCount,
        color: Colors.orange,
        icon: Icons.arrow_forward,
      ),
      StatusTab(
        label: '4xx',
        count: clientErrorCount,
        color: Colors.red,
        icon: Icons.cancel,
      ),
      StatusTab(
        label: '5xx',
        count: serverErrorCount,
        color: Colors.red.shade800,
        icon: Icons.error_outline,
      ),
      StatusTab(
        label: 'Ошибки подключения',
        count: connectionErrorCount,
        color: Colors.purple,
        icon: Icons.wifi_off,
      ),
      StatusTab(
        label: 'Остальное',
        count: otherCount,
        color: Colors.grey,
        icon: Icons.help_outline,
      ),
    ];
  }
}

class StatusTab {
  final String label;
  final int count;
  final Color color;
  final IconData? icon;

  StatusTab({
    required this.label,
    required this.count,
    required this.color,
    this.icon,
  });
}
