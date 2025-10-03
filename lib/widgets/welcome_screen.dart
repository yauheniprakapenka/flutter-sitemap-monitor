// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sitemap_with_sitemap/sitemap_with_sitemap.dart';
import 'package:sitemap_with_url/sitemap_with_url.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: _buildActionCard(
                  context: context,
                  icon: Icons.web,
                  title: 'Анализ sitemap с страницами',
                  subtitle: 'Sitemap содержит URL конкретные страницы',
                  onTap: () => _navigateToUrlInput(context),
                  isPrimary: false,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: _buildActionCard(
                  context: context,
                  icon: Icons.account_tree,
                  title: 'Анализ sitemap с вложенными sitemap',
                  subtitle: 'Sitemap содержит URL на другие sitemap',
                  onTap: () => _navigateToSitemapIndexInput(context),
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isPrimary ? colorScheme.primaryContainer : colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary
                  ? colorScheme.primary.withOpacity(0.3)
                  : colorScheme.outline.withOpacity(0.2),
              width: isPrimary ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isPrimary ? colorScheme.primary : Colors.grey).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary ? colorScheme.primary : colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isPrimary ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isPrimary ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPrimary
                            ? colorScheme.onPrimaryContainer.withOpacity(0.8)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isPrimary ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUrlInput(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UrlInputScreen(),
      ),
    );
  }

  void _navigateToSitemapIndexInput(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SitemapIndexInputScreen(),
      ),
    );
  }
}
