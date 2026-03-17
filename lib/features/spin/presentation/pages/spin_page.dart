import "dart:async";
import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_fortune_wheel/flutter_fortune_wheel.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/core/widgets/gradient_primary_button.dart";
import "package:menu_2026/features/branches/presentation/controllers/branches_controller.dart";
import "package:menu_2026/features/categories/domain/entities/category_entity.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";
import "package:menu_2026/features/spin/presentation/controllers/spin_controller.dart";
import "package:menu_2026/features/categories/presentation/controllers/categories_controller.dart";
import "package:menu_2026/features/spin/presentation/controllers/spin_filter_controller.dart";

class SpinPage extends ConsumerStatefulWidget {
  const SpinPage({super.key});

  @override
  ConsumerState<SpinPage> createState() => _SpinPageState();
}

class _SpinPageState extends ConsumerState<SpinPage> {
  final StreamController<int> _selectedIndexController =
      StreamController<int>.broadcast();
  final Random _random = Random();

  bool _isSpinning = false;
  int _segments = 8;
  SpinKind _mode = SpinKind.category;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(selectedRestaurantIdProvider.notifier).state = null;
    });
  }

  @override
  void dispose() {
    _selectedIndexController.close();
    super.dispose();
  }

  void _startSpin(List<dynamic> items) {
    if (_isSpinning || items.length < 2) return;

    setState(() => _isSpinning = true);
    final int target = _random.nextInt(items.length);
    _segments = min<int>(_segments, items.length);
    _selectedIndexController.add(target % _segments);

    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _isSpinning = false);
      final int index = target % items.length;
      if (_mode == SpinKind.category) {
        ref.read(spinControllerProvider.notifier).spinCategoryAt(
          items as List<CategoryEntity>,
          index,
        );
      } else {
        ref.read(spinControllerProvider.notifier).spinRestaurantAt(
          items as List<RestaurantEntity>,
          index,
        );
      }
    });
  }

  static String _categoryEmoji(CategoryEntity c) {
    final String name = c.nameEn.toLowerCase();
    if (name.contains("burger")) return "🍔";
    if (name.contains("shawarma")) return "🌯";
    if (name.contains("pizza")) return "🍕";
    if (name.contains("coffee") || name.contains("café")) return "☕";
    if (name.contains("sushi") || name.contains("asian")) return "🍣";
    if (name.contains("dessert")) return "🍰";
    if (name.contains("breakfast") || name.contains("brunch")) return "🥐";
    return "🍽";
  }

  static String _restaurantEmoji(RestaurantEntity r) {
    final String name = r.nameEn.toLowerCase();
    if (name.contains("burger")) return "🍔";
    if (name.contains("java") || name.contains("coffee")) return "☕";
    if (name.contains("sweet")) return "🍰";
    if (name.contains("shawarma")) return "🌯";
    if (name.contains("pizza")) return "🍕";
    if (name.contains("sushi")) return "🍣";
    if (name.contains("sunrise")) return "🥐";
    return "🍽";
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SpinResult? result = ref.watch(spinControllerProvider);
    final categoriesAsync = ref.watch(categoriesControllerProvider);
    final restaurantsAsync = ref.watch(spinFilteredRestaurantsProvider);
    final selectedCategoryIds = ref.watch(spinSelectedCategoryIdsProvider);
    final allCategoriesAsync = ref.watch(categoriesControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Not sure what to eat?",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Spin the wheel for a category (What to eat?) or a restaurant (Where to eat?)",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("What to eat?"),
                            selected: _mode == SpinKind.category,
                            onSelected: (bool value) {
                              if (value) setState(() => _mode = SpinKind.category);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Where to eat?"),
                            selected: _mode == SpinKind.restaurant,
                            onSelected: (bool value) {
                              if (value) setState(() => _mode = SpinKind.restaurant);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_mode == SpinKind.restaurant) ...[
                    const SizedBox(height: 16),
                    Text(
                      "Filter by category (optional)",
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    allCategoriesAsync.when(
                      data: (List<CategoryEntity> categories) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: const Text("All"),
                                  selected: selectedCategoryIds.isEmpty,
                                  onSelected: (_) {
                                    ref.read(spinSelectedCategoryIdsProvider.notifier).state = <String>[];
                                  },
                                ),
                              ),
                              ...categories.map(
                                (CategoryEntity c) {
                                  final bool isSelected =
                                      selectedCategoryIds.contains(c.id);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(c.nameEn),
                                      selected: isSelected,
                                      onSelected: (bool value) {
                                        final List<String> current =
                                            ref.read(spinSelectedCategoryIdsProvider);
                                        if (value) {
                                          ref.read(spinSelectedCategoryIdsProvider.notifier).state =
                                              <String>[...current, c.id];
                                        } else {
                                          ref.read(spinSelectedCategoryIdsProvider.notifier).state =
                                              current.where((String id) => id != c.id).toList(growable: false);
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox(height: 36),
                      error: (Object e, StackTrace s) => const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildWheel(
                  theme: theme,
                  mode: _mode,
                  categoriesAsync: categoriesAsync,
                  restaurantsAsync: restaurantsAsync,
                ),
              ),
            ),
            if (result != null)
              _ResultCard(
                result: result,
                onClearResult: () {
                  ref.read(spinControllerProvider.notifier).clearResult();
                },
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildSpinButton(
                theme: theme,
                categoriesAsync: categoriesAsync,
                restaurantsAsync: restaurantsAsync,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinButton({
    required ThemeData theme,
    required AsyncValue<List<CategoryEntity>> categoriesAsync,
    required AsyncValue<List<RestaurantEntity>> restaurantsAsync,
  }) {
    final int itemsLength = _mode == SpinKind.category
        ? (categoriesAsync.valueOrNull?.length ?? 0)
        : (restaurantsAsync.valueOrNull?.length ?? 0);

    return GradientPrimaryButton(
      label: _isSpinning ? "Spinning..." : "Spin now",
      onPressed: _isSpinning || itemsLength < 2
          ? null
          : () {
              final List<dynamic> items = _mode == SpinKind.category
                  ? (categoriesAsync.valueOrNull ?? <CategoryEntity>[])
                  : (restaurantsAsync.valueOrNull ?? <RestaurantEntity>[]);
              _startSpin(items);
            },
    );
  }

  Widget _buildWheel({
    required ThemeData theme,
    required SpinKind mode,
    required AsyncValue<List<CategoryEntity>> categoriesAsync,
    required AsyncValue<List<RestaurantEntity>> restaurantsAsync,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            height: 300,
            child: mode == SpinKind.category
                ? categoriesAsync.when(
                    data: (List<CategoryEntity> items) => _wheelContent(
                      theme: theme,
                      items: items,
                      getEmoji: _categoryEmoji,
                      emptyMessage: "No categories. Try removing filters.",
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator.adaptive()),
                    error: (Object e, StackTrace s) => _errorContent(theme),
                  )
                : restaurantsAsync.when(
                    data: (List<RestaurantEntity> items) => _wheelContent(
                      theme: theme,
                      items: items,
                      getEmoji: _restaurantEmoji,
                      emptyMessage: "No restaurants. Try different categories.",
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator.adaptive()),
                    error: (Object e, StackTrace s) => _errorContent(theme),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _wheelContent<T>({
    required ThemeData theme,
    required List<T> items,
    required String Function(T) getEmoji,
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: theme.textTheme.bodyMedium),
      );
    }
    if (items.length < 2) {
      return Center(
        child: Text(
          "Need at least 2 options to spin.",
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    _segments = min<int>(_segments, items.length);
    const List<Color> segmentColors = <Color>[
      Color(0xFF8A4DFF),
      Color(0xFF6B3FAF),
      Color(0xFFFF3F8E),
      Color(0xFFE8357A),
      Color(0xFF8A4DFF),
      Color(0xFF6B3FAF),
      Color(0xFFFF3F8E),
      Color(0xFFE8357A),
    ];

    return FortuneWheel(
      selected: _selectedIndexController.stream,
      animateFirst: false,
      indicators: const <FortuneIndicator>[
        FortuneIndicator(
          alignment: Alignment.topCenter,
          child: TriangleIndicator(color: Color(0xFFFFD700)),
        ),
      ],
      items: List.generate(_segments, (int index) {
        final T item = items[index % items.length];
        return FortuneItem(
          child: Center(
            child: Text(
              getEmoji(item),
              style: const TextStyle(fontSize: 32),
            ),
          ),
          style: FortuneItemStyle(
            color: segmentColors[index % segmentColors.length],
            borderColor: Colors.white,
            borderWidth: 2,
          ),
        );
      }),
    );
  }

  Widget _errorContent(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            "Unable to load options.",
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.onClearResult,
  });

  final SpinResult result;
  final VoidCallback onClearResult;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                result.kind == SpinKind.category
                    ? "You should eat..."
                    : "Where to eat...",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (result.distanceKm != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  "${result.distanceKm!.toStringAsFixed(1)} km away",
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (result.reason != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  result.reason!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (result.kind == SpinKind.category &&
                            result.id != null) {
                          context.push(
                            "/categories/${result.id}",
                            extra: result.name,
                          );
                        } else if (result.kind == SpinKind.restaurant &&
                            result.id != null) {
                          context.push("/restaurant/${result.id}");
                        }
                      },
                      child: Text(
                        result.kind == SpinKind.category
                            ? "Explore this category"
                            : "View restaurant",
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onClearResult,
                    child: const Text("Spin again"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
