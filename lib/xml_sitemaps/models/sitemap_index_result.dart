class SitemapIndexResult {
  final String sitemapUrl;
  final List<String> pageUrls;
  final DateTime? lastModified;
  final bool isSuccess;
  final String? errorMessage;

  const SitemapIndexResult({
    required this.sitemapUrl,
    required this.pageUrls,
    this.lastModified,
    required this.isSuccess,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'SitemapIndexResult(sitemapUrl: $sitemapUrl, pageUrls: ${pageUrls.length}, lastModified: $lastModified, isSuccess: $isSuccess, errorMessage: $errorMessage)';
  }
}
