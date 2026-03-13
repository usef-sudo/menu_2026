import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/network/safe_request.dart";
import "package:menu_2026/features/categories/domain/entities/category_entity.dart";

class CategoriesController
    extends AutoDisposeAsyncNotifier<List<CategoryEntity>> {
  @override
  Future<List<CategoryEntity>> build() async {
    return _load();
  }

  Future<List<CategoryEntity>> _load() async {
    final result = await safeRequest<List<CategoryEntity>>(() async {
      final dtos = await ref.read(menuApiProvider).getCategories();
      return dtos.map((dto) => dto.toEntity()).toList(growable: false);
    });
    return result.when(
      success: (List<CategoryEntity> data) => data,
      failure: (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

final categoriesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      CategoriesController,
      List<CategoryEntity>
    >(CategoriesController.new);
