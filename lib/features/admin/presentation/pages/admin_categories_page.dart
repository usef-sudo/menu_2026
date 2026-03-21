import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/categories/data/models/category_dto.dart";

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

  Future<void> _editCategory(CategoryDto? existing) async {
    final String? nameEn = await _promptText(
      context,
      title: existing == null ? "New category" : "Edit category",
      label: "Name (English)",
      initial: existing?.nameEn ?? "",
    );
    if (nameEn == null || nameEn.isEmpty) return;
    final String? nameAr = await _promptText(
      context,
      title: "Arabic name",
      label: "Name (Arabic)",
      initial: existing?.nameAr ?? "",
    );
    if (nameAr == null || nameAr.isEmpty) return;

    try {
      final MenuApi api = ref.read(menuApiProvider);
      if (existing == null) {
        final bool? withImage = await showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) => AlertDialog(
            title: const Text("Category image"),
            content: const Text("Add an image now? (Required for image-based categories.)"),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Skip")),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Choose image")),
            ],
          ),
        );
        if (withImage == true) {
          final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (!mounted) return;
          if (file == null) return;
          final List<int> bytes = await file.readAsBytes();
          await api.adminCreateCategoryWithImage(
            nameEn: nameEn,
            nameAr: nameAr,
            imageBytes: bytes,
            filename: file.name,
          );
        } else {
          await api.adminCreateCategory(nameEn: nameEn, nameAr: nameAr);
        }
      } else {
        await api.adminUpdateCategory(
          existing.id,
          nameEn: nameEn,
          nameAr: nameAr,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved")),
        );
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final String msg = e.response?.data is Map
          ? (e.response?.data["message"]?.toString() ?? "Request failed")
          : "Request failed";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _replaceCategoryImage(CategoryDto c) async {
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (!mounted || file == null) return;
    try {
      final List<int> bytes = await file.readAsBytes();
      await ref.read(menuApiProvider).adminUpdateCategoryWithImage(
            c.id,
            imageBytes: bytes,
            imageFilename: file.name,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image updated")));
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?.toString() ?? "Failed")),
      );
    }
  }

  Future<void> _saveReorder() async {
    try {
      await ref.read(menuApiProvider).adminReorderCategories(
            _items.map((CategoryDto e) => e.id).toList(growable: false),
          );
      if (mounted) {
        setState(() => _reorderMode = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order saved")),
        );
        await _load();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _confirmDelete(CategoryDto c) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete category"),
          content: Text("Delete \"${c.nameEn}\"? This cannot be undone."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
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
          const SnackBar(content: Text("Deleted")),
        );
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final String msg = e.response?.data is Map
          ? (e.response?.data["message"]?.toString() ?? "Delete failed")
          : "Delete failed";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
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
            tooltip: _reorderMode ? "Done reordering" : "Reorder",
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
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      floatingActionButton: _reorderMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _editCategory(null),
              icon: const Icon(Icons.add),
              label: const Text("Add"),
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
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Text(
                        "No categories",
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
                            padding: const EdgeInsets.all(16),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
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
                                          "Inactive",
                                          style: theme.textTheme.labelSmall,
                                        ),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.photo_outlined),
                                      tooltip: "Change image",
                                      onPressed: () => _replaceCategoryImage(c),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _editCategory(c),
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

Future<String?> _promptText(
  BuildContext context, {
  required String title,
  required String label,
  String initial = "",
}) async {
  final TextEditingController controller =
      TextEditingController(text: initial);
  final String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          autofocus: true,
          onSubmitted: (String v) => Navigator.pop(context, v),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
  controller.dispose();
  return result;
}
