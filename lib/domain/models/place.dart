/// A place to explore: tourist spot, market, heritage site, park, …
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.image,
    required this.metaLine,
    required this.description,
    required this.ratingText,
    required this.tags,
    this.address = '',
    this.timings = '',
    this.entryFee = '',
  });

  final String id;
  final String name;
  final String image;

  /// Compact meta strip, e.g. "18 min · Free · Must Visit".
  final String metaLine;
  final String description;

  /// e.g. "4.2 (1.2K)".
  final String ratingText;
  final List<String> tags;
  final String address;
  final String timings;
  final String entryFee;
}

/// A famous local food item shown on the Explore screen.
class FoodHighlight {
  const FoodHighlight({
    required this.name,
    required this.description,
    required this.image,
    required this.rating,
  });

  final String name;
  final String description;
  final String image;
  final String rating;
}

/// Editorial guide card on Explore.
class CityGuide {
  const CityGuide({
    required this.title,
    required this.subtitle,
    required this.author,
    required this.image,
  });

  final String title;
  final String subtitle;
  final String author;
  final String image;
}

/// "Tips for Smart Explorers" row.
class ExplorerTip {
  const ExplorerTip({required this.title, required this.text});

  final String title;
  final String text;
}
