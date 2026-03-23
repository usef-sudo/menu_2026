import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";
import "package:menu_2026/core/network/dio_error_message.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_category_editor_sheet.dart";
import "package:menu_2026/features/categories/data/models/category_dto.dart";
import "package:menu_2026/l10n/app_localizations.dart";

class AdminCategoriesPage extends ConsumerStatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  ConsumerState<AdminCategoriesPage> createState() =>
      _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends ConsumerState<AdminCategoriesPage> {
  bool _loading = true;
  String? _error;
  List<CategoryDto> _items = <CategoryDto>[];
  bool _reorderMode = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<CategoryDto> list =
          await ref.read(menuApiProvider).getCategories(activeOnly: false);
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openEditor(CategoryDto? existing) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MenuApi api = ref.read(menuApiProvider);
    final bool saved = await showAdminCategoryEditor(
      context: context,
      l10n: l10n,
      api: api,
      existing: existing,
    );
    if (!mounted || !saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.commonSaved)),
    );
    await _load();
  }

  Future<void> _replaceCategoryImage(CategoryDto c) async {
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (!mounted || file == null) return;
    final AppLocalizations l10n = AppLocalizations.of(context);
    try {
      final List<int> bytes = await file.readAsBytes();
      await ref.read(menuApiProvider).adminUpdateCategoryWithImage(
            c.id,
            imageBytes: bytes,
            imageFilename: file.name,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminImageUpdated)),
        );
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(e))),
      );
    }
  }

  Future<void> _saveReorder() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    try {
      await ref.read(menuApiProvider).adminReorderCategories(
            _items.map((CategoryDto e) => e.id).toList(growable: false),
          );
      if (mounted) {
        setState(() => _reorderMode = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminOrderSaved)),
        );
        await _load();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _confirmDelete(CategoryDto c) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.adminDeleteCategoryTitle),
          content: Text(l10n.adminDeleteCategoryMessage(c.nameEn)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    try {
      await ref.read(menuApiProvider).adminDeleteCategory(c.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonDeleted)),
        );
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminCategoriesTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go("/admin");
            }
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(_reorderMode ? Icons.check : Icons.swap_vert),
            tooltip: _reorderMode ? l10n.adminReorderDoneTooltip : l10n.adminReorderTooltip,
            onPressed: _loading
                ? null
                : () {
                    if (_reorderMode) {
                      _saveReorder();
                    } else {
                      setState(() => _reorderMode = true);
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.adminTooltipRefresh,
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      floatingActionButton: _reorderMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openEditor(null),
              icon: const Icon(Icons.add),
              label: Text(l10n.commonAdd),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Text(
                        l10n.adminNoCategories,
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : _reorderMode
                      ? ReorderableListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final CategoryDto x = _items.removeAt(oldIndex);
                              _items.insert(newIndex, x);
                            });
                          },
                          itemBuilder: (BuildContext context, int index) {
                            final CategoryDto c = _items[index];
                            return ListTile(
                              key: ValueKey<String>(c.id),
                              leading: const Icon(Icons.drag_handle),
                              title: Text(c.nameEn),
                              subtitle: Text(c.nameAr),
                            );
                          },
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: _items.length,
                            separatorBuilder: (BuildContext context, int index) =>
                                const Divider(height: 1),
                            itemBuilder: (BuildContext context, int index) {
                              final CategoryDto c = _items[index];
                              return ListTile(
                                title: Text(c.nameEn),
                                subtitle: Text(
                                  c.nameAr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    if (!c.isActive)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Text(
                                          l10n.adminInactive,
                                          style: theme.textTheme.labelSmall,
                                        ),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.photo_outlined),
                                      tooltip: l10n.adminChangeImageTooltip,
                                      onPressed: () => _replaceCategoryImage(c),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _openEditor(c),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: theme.colorScheme.error,
                                      ),
                                      onPressed: () => _confirmDelete(c),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
    );
  }
}
