class SummarizedText {
  final String summary;
  SummarizedText({required this.summary});
  factory SummarizedText.fromJson(Map<String, dynamic> json) {
    return SummarizedText(summary: json['summary'] ?? '');
  }
  Map<String, dynamic> toJson() {
    return {'summary': summary};
  }
}
