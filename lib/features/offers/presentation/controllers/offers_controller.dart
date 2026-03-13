import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/network/safe_request.dart";
import "package:menu_2026/features/offers/domain/entities/offer_entity.dart";

class OffersController extends AutoDisposeAsyncNotifier<List<OfferEntity>> {
  @override
  Future<List<OfferEntity>> build() async {
    final result = await safeRequest<List<OfferEntity>>(() async {
      final dtos = await ref.read(menuApiProvider).getOffers();
      return dtos.map((dto) => dto.toEntity()).toList(growable: false);
    });
    return result.when(
      success: (List<OfferEntity> data) => data,
      failure: (failure) => throw failure,
    );
  }
}

final offersControllerProvider =
    AutoDisposeAsyncNotifierProvider<OffersController, List<OfferEntity>>(
      OffersController.new,
    );
