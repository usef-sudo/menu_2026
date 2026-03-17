import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/categories/domain/entities/category_entity.dart";
import "package:menu_2026/features/categories/presentation/controllers/categories_controller.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurants_controller.dart";

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryEntity> _filterCategories(List<CategoryEntity> categories) {
    if (_searchQuery.isEmpty) return categories;
    return categories
        .where(
          (CategoryEntity c) =>
              c.nameEn.toLowerCase().contains(_searchQuery) ||
              c.nameAr.contains(_searchQuery),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CategoryEntity>> categoriesAsync = ref.watch(
      categoriesControllerProvider,
    );

    return Scaffold(
      body: SafeArea(
        child: categoriesAsync.when(
          data: (List<CategoryEntity> categories) {
            final List<CategoryEntity> filtered = _filterCategories(categories);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                const _Header(),
                const SizedBox(height: 16),
                _SearchBar(controller: _searchController),
                const SizedBox(height: 24),
                filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Text(
                          _searchQuery.isEmpty
                              ? "No categories yet"
                              : "No categories match \"$_searchQuery\"",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      )
                    : _CategoriesGrid(categories: filtered),
              ],
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (Object error, StackTrace stack) =>
              const Center(child: Text("Unable to load categories")),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: "Search categories...",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, TextEditingValue value, __) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => controller.clear(),
            );
          },
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: theme.textTheme.bodyLarge,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF8A4DFF), Color(0xFFFF3F8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Categories",
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Explore restaurants by category",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesGrid extends ConsumerWidget {
  const _CategoriesGrid({required this.categories});

  final List<CategoryEntity> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 24),
        child: Text("No categories yet"),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: categories.length,
      itemBuilder: (BuildContext context, int index) {
        final CategoryEntity category = categories[index];
        return _CategoryTile(
          category: category,
          onTap: () {
            ref.read(restaurantsFilterProvider.notifier).state =
                RestaurantsFilter(categoryId: category.id);
            ref.read(restaurantsControllerProvider.notifier).refresh();
            context.push("/categories/${category.id}", extra: category.nameEn);
          },
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final CategoryEntity category;
  final VoidCallback onTap;

  String get _emoji {
    final String name = category.nameEn.toLowerCase();
    if (name.contains("burger")) return "🍔";
    if (name.contains("shawarma")) return "🌯";
    if (name.contains("pizza")) return "🍕";
    if (name.contains("café") || name.contains("cafe")) return "☕️";
    if (name.contains("sushi")) return "🍣";
    if (name.contains("dessert")) return "🍰";
    if (name.contains("breakfast")) return "🥐";
    return "🍽️";
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          color: Colors.grey.shade900,
          image: category.imageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(category.imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.45),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(_emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  category.nameEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
