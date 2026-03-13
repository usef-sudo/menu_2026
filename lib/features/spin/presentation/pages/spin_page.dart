import "dart:async";
import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_fortune_wheel/flutter_fortune_wheel.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/core/widgets/gradient_primary_button.dart";
import "package:menu_2026/features/categories/domain/entities/category_entity.dart";
import "package:menu_2026/features/categories/presentation/controllers/categories_controller.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurants_controller.dart";
import "package:menu_2026/features/spin/presentation/controllers/spin_controller.dart";

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
  int _currentIndex = 0;
  SpinKind _mode = SpinKind.category;

  @override
  void dispose() {
    _selectedIndexController.close();
    super.dispose();
  }

  void _startSpin(int itemsLength) {
    if (_isSpinning || itemsLength <= 0) {
      return;
    }
    setState(() {
      _isSpinning = true;
    });
    final int target = _random.nextInt(itemsLength);
    _selectedIndexController.add(target % _segments);
    Future<void>.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isSpinning = false;
      });
      if (_mode == SpinKind.category) {
        ref.read(spinControllerProvider.notifier).spinCategory();
      } else {
        ref.read(spinControllerProvider.notifier).spinRestaurant();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SpinResult? result = ref.watch(spinControllerProvider);
    final AsyncValue<List<CategoryEntity>> categoriesAsync =
        ref.watch(categoriesControllerProvider);
    final AsyncValue<List<RestaurantEntity>> restaurantsAsync =
        ref.watch(restaurantsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Spin to Decide"),
        centerTitle: true,
      ),
      body: Column(
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
                const SizedBox(height: 8),
                Text(
                  "Use the wheel to pick a category or a nearby place and let Menu decide for you.",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("What to eat?"),
                          selected: _mode == SpinKind.category,
                          onSelected: (bool value) {
                            if (value) {
                              setState(() {
                                _mode = SpinKind.category;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Where to eat?"),
                          selected: _mode == SpinKind.restaurant,
                          onSelected: (bool value) {
                            if (value) {
                              setState(() {
                                _mode = SpinKind.restaurant;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildWheel(
                context,
                mode: _mode,
                categoriesAsync: categoriesAsync,
                restaurantsAsync: restaurantsAsync,
              ),
            ),
          ),
          if (result != null) _ResultCard(result: result),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: GradientPrimaryButton(
              label: _isSpinning ? "Spinning..." : "Spin now",
              onPressed: _isSpinning
                  ? null
                  : () {
                      final int itemsLength = _mode == SpinKind.category
                          ? (categoriesAsync.valueOrNull?.length ?? 0)
                          : (restaurantsAsync.valueOrNull?.length ?? 0);
                      _startSpin(itemsLength);
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel(
    BuildContext context, {
    required SpinKind mode,
    required AsyncValue<List<CategoryEntity>> categoriesAsync,
    required AsyncValue<List<RestaurantEntity>> restaurantsAsync,
  }) {
    final ThemeData theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
            child: Center(
          child: SizedBox(
            height: 280,
            child: categoriesAsync.when(
              data: (List<CategoryEntity> categories) {
                final List<dynamic> items = mode == SpinKind.category
                    ? categories
                    : (restaurantsAsync.valueOrNull ?? <RestaurantEntity>[]);
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      mode == SpinKind.category
                          ? "No categories to spin yet."
                          : "No restaurants to spin yet.",
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }
                _segments = min<int>(_segments, items.length);
                return FortuneWheel(
                  selected: _selectedIndexController.stream,
                  animateFirst: false,
                  indicators: const <FortuneIndicator>[
                    FortuneIndicator(
                      alignment: Alignment.topCenter,
                      child: TriangleIndicator(
                        color: Colors.amber,
                      ),
                    ),
                  ],
                  items: List.generate(_segments, (int index) {
                    final item = items[index % items.length];
                    final String label = mode == SpinKind.category
                        ? item.nameEn as String
                        : item.nameEn as String;
                    return FortuneItem(
                      child: Transform.rotate(
                        angle: pi / 2,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      style: FortuneItemStyle(
                        color: index.isEven
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                        borderColor: Colors.white,
                        borderWidth: 2,
                      ),
                    );
                  }),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (_, __) => Center(
                child: Text(
                  "Unable to load options to spin.",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final SpinResult result;

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
                  style: theme.textTheme.bodySmall,
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
                            : "View restaurant details",
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      // Trigger a new spin via the page button.
                    },
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

