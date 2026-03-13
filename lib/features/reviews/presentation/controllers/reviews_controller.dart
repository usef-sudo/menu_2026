import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/reviews/domain/entities/review_entity.dart";

class ReviewsController
    extends AutoDisposeFamilyAsyncNotifier<ReviewsState, String> {
  @override
  Future<ReviewsState> build(String arg) async {
    return _load(arg);
  }

  Future<ReviewsState> _load(String branchId) async {
    final ReviewsState data =
        await ref.read(menuApiProvider).getBranchReviews(branchId);
    return data;
  }

  Future<void> refresh(String branchId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(branchId));
  }

  Future<bool> submitReview({
    required String branchId,
    required int rating,
    String? comment,
  }) async {
    try {
      await ref.read(menuApiProvider).submitReview(
            branchId: branchId,
            rating: rating,
            comment: comment,
          );
      await refresh(branchId);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final reviewsControllerProvider =
    AutoDisposeAsyncNotifierProviderFamily<ReviewsController, ReviewsState,
        String>(ReviewsController.new);

