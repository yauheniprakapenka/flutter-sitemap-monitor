class SitemapUrl {
  final String location;
  final DateTime? lastModified;
  final String? changeFrequency;
  final double? priority;
  final int? statusCode;

  const SitemapUrl({
    required this.location,
    this.lastModified,
    this.changeFrequency,
    this.priority,
    this.statusCode,
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
    return 'SitemapUrl(location: $location, lastModified: $lastModified, changeFrequency: $changeFrequency, priority: $priority, statusCode: $statusCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SitemapUrl &&
        other.location == location &&
        other.lastModified == lastModified &&
        other.changeFrequency == changeFrequency &&
        other.priority == priority &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode {
    return location.hashCode ^
        lastModified.hashCode ^
        changeFrequency.hashCode ^
        priority.hashCode ^
        statusCode.hashCode;
  }
}
