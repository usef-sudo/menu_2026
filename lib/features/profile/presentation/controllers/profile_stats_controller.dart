import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

class ProfileStats {
  const ProfileStats({
    required this.visitedCount,
    required this.reviewCount,
  });

  final int visitedCount;
  final int reviewCount;
}

class ProfileStatsController extends AutoDisposeAsyncNotifier<ProfileStats> {
  static const String _visitedKey = "profile_visited_count";
  static const String _reviewKey = "profile_review_count";

  @override
  Future<ProfileStats> build() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int visited = prefs.getInt(_visitedKey) ?? 0;
    final int reviews = prefs.getInt(_reviewKey) ?? 0;
    return ProfileStats(visitedCount: visited, reviewCount: reviews);
  }

  Future<void> incrementVisited() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int current = prefs.getInt(_visitedKey) ?? 0;
    final int next = current + 1;
    await prefs.setInt(_visitedKey, next);
    state = AsyncData(
      ProfileStats(
        visitedCount: next,
        reviewCount: state.valueOrNull?.reviewCount ?? 0,
      ),
    );
  }

  Future<void> incrementReviews() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int current = prefs.getInt(_reviewKey) ?? 0;
    final int next = current + 1;
    await prefs.setInt(_reviewKey, next);
    state = AsyncData(
      ProfileStats(
        visitedCount: state.valueOrNull?.visitedCount ?? 0,
        reviewCount: next,
      ),
    );
  }
}

final profileStatsControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProfileStatsController, ProfileStats>(
  ProfileStatsController.new,
);

