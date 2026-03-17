import "package:flutter_riverpod/flutter_riverpod.dart";

enum HomePlacesSort { nearby, mostVoted, recommended }

String homePlacesSortToQuery(HomePlacesSort v) {
  return switch (v) {
    HomePlacesSort.nearby => "nearby",
    HomePlacesSort.mostVoted => "most_voted",
    HomePlacesSort.recommended => "recommended",
  };
}

HomePlacesSort homePlacesSortFromQuery(String? v) {
  return switch (v) {
    "most_voted" => HomePlacesSort.mostVoted,
    "recommended" => HomePlacesSort.recommended,
    _ => HomePlacesSort.nearby,
  };
}

final homePlacesSortProvider = StateProvider<HomePlacesSort>(
  (Ref ref) => HomePlacesSort.nearby,
);

