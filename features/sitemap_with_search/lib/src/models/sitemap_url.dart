class SitemapUrl {
  final String location;
  final DateTime? lastModified;
  final String? changeFrequency;
  final double? priority;

  const SitemapUrl({
    required this.location,
    this.lastModified,
    this.changeFrequency,
    this.priority,
  });

  factory SitemapUrl.fromXml(Map<String, dynamic> xmlData) {
    return SitemapUrl(
      location: xmlData['loc'] ?? '',
      lastModified: xmlData['lastmod'] != null
          ? DateTime.tryParse(xmlData['lastmod'])
          : null,
      changeFrequency: xmlData['changefreq'],
      priority: xmlData['priority'] != null
          ? double.tryParse(xmlData['priority'])
          : null,
    );
  }

  @override
  String toString() {
    return 'SitemapUrl(location: $location, lastModified: $lastModified, changeFrequency: $changeFrequency, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SitemapUrl &&
        other.location == location &&
        other.lastModified == lastModified &&
        other.changeFrequency == changeFrequency &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return location.hashCode ^
        lastModified.hashCode ^
        changeFrequency.hashCode ^
        priority.hashCode;
  }
}
