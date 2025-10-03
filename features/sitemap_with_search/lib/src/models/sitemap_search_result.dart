class SitemapSearchResult {
  final String sitemapUrl;
  final List<String> matchingUrls;
  final int totalUrls;
  final int matchingCount;

  const SitemapSearchResult({
    required this.sitemapUrl,
    required this.matchingUrls,
    required this.totalUrls,
    required this.matchingCount,
  });

  @override
  String toString() {
    return 'SitemapSearchResult(sitemapUrl: $sitemapUrl, matchingUrls: $matchingUrls, totalUrls: $totalUrls, matchingCount: $matchingCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SitemapSearchResult &&
        other.sitemapUrl == sitemapUrl &&
        other.matchingUrls == matchingUrls &&
        other.totalUrls == totalUrls &&
        other.matchingCount == matchingCount;
  }

  @override
  int get hashCode {
    return sitemapUrl.hashCode ^
        matchingUrls.hashCode ^
        totalUrls.hashCode ^
        matchingCount.hashCode;
  }
}
