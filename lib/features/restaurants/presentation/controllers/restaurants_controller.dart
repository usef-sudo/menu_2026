import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/network/safe_request.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";

class RestaurantDayHoursFilter {
  const RestaurantDayHoursFilter({
    required this.weekday,
    required this.from,
    required this.to,
  });

  /// 1 = Monday ... 7 = Sunday.
  final int weekday;
  final String from;
  final String to;
}

class RestaurantOpenHoursFilter {
  const RestaurantOpenHoursFilter({this.days = const <RestaurantDayHoursFilter>[]});

  final List<RestaurantDayHoursFilter> days;

  bool get isEmpty => days.isEmpty;
}

class RestaurantsFilter {
  const RestaurantsFilter({
    this.categoryId,
    this.search,
    this.minCostLevel,
    this.maxCostLevel,
    this.openOnly,
    this.sort,
    this.facilityIds = const <String>[],
    this.openHoursFilter,
  });
  final String? categoryId;
  final String? search;
  final int? minCostLevel;
  final int? maxCostLevel;
  final bool? openOnly;
  final String? sort;
  final List<String> facilityIds;
  final RestaurantOpenHoursFilter? openHoursFilter;
}

final restaurantsFilterProvider = StateProvider<RestaurantsFilter>(
  (Ref ref) => const RestaurantsFilter(),
);

class RestaurantsController
    extends AutoDisposeAsyncNotifier<List<RestaurantEntity>> {
  static final RegExp _hm = RegExp(r"^([01]?\d|2[0-3]):([0-5]\d)$");

  int? _toMinutes(String t) {
    final RegExpMatch? m = _hm.firstMatch(t.trim());
    if (m == null) return null;
    final int h = int.parse(m.group(1)!);
    final int min = int.parse(m.group(2)!);
    return h * 60 + min;
  }

  Future<bool> _restaurantMatchesOpenHoursFilter({
    required MenuApi api,
    required String restaurantId,
    required RestaurantOpenHoursFilter hours,
  }) async {
    for (final RestaurantDayHoursFilter day in hours.days) {
      final List<dynamic> atFrom = await api.getBranches(
        restaurantId: restaurantId,
        openAtWeekday: day.weekday,
        openAtTime: day.from,
      );
      if (atFrom.isEmpty) return false;

      // If from == to, it's a point-in-time check only.
      if (day.from == day.to) continue;

      final List<dynamic> atTo = await api.getBranches(
        restaurantId: restaurantId,
        openAtWeekday: day.weekday,
        openAtTime: day.to,
      );
      if (atTo.isEmpty) return false;

      final Set<String> fromIds = atFrom
          .map((b) => (b.id as String?) ?? "")
          .where((id) => id.isNotEmpty)
          .toSet();
      final bool anySameBranch = atTo.any(
        (b) => fromIds.contains((b.id as String?) ?? ""),
      );
      if (!anySameBranch) return false;

      // Basic sanity: require from <= to for same-day ranges in current UI.
      final int? fromM = _toMinutes(day.from);
      final int? toM = _toMinutes(day.to);
      if (fromM == null || toM == null || fromM > toM) return false;
    }
    return true;
  }

  @override
  Future<List<RestaurantEntity>> build() async {
    final filter = ref.watch(restaurantsFilterProvider);
    return _load(filter);
  }

  Future<List<RestaurantEntity>> _load(RestaurantsFilter filter) async {
    final result = await safeRequest<List<RestaurantEntity>>(() async {
      final MenuApi api = ref.read(menuApiProvider);
      final dtos = await api.getRestaurants(
        categoryId: filter.categoryId,
        search: filter.search,
        minCostLevel: filter.minCostLevel,
        maxCostLevel: filter.maxCostLevel,
        openOnly: filter.openOnly,
        sort: filter.sort,
        facilityIds: filter.facilityIds,
      );
      final List<RestaurantEntity> restaurants = dtos
          .map((dto) => dto.toEntity())
          .toList(growable: false);

      final RestaurantOpenHoursFilter? hours = filter.openHoursFilter;
      if (hours == null || hours.isEmpty || filter.openOnly == true) {
        return restaurants;
      }

      final List<RestaurantEntity> filtered = <RestaurantEntity>[];
      for (final RestaurantEntity r in restaurants) {
        final bool ok = await _restaurantMatchesOpenHoursFilter(
          api: api,
          restaurantId: r.id,
          hours: hours,
        );
        if (ok) filtered.add(r);
      }
      return filtered;
    });
    return result.when(
      success: (List<RestaurantEntity> data) => data,
      failure: (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final filter = ref.read(restaurantsFilterProvider);
    state = await AsyncValue.guard(() => _load(filter));
  }
}

final restaurantsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      RestaurantsController,
      List<RestaurantEntity>
    >(RestaurantsController.new);
