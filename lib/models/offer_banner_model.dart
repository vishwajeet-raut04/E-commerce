class OfferBanner {
  final String id;
  final String title;
  final String imageUrl;

  OfferBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory OfferBanner.fromJson(Map<String, dynamic> json) => OfferBanner(
        id: json['id'],
        title: json['title'],
        imageUrl: json['imageUrl'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "imageUrl": imageUrl,
      };
}