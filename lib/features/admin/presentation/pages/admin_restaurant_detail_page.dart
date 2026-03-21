import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/categories/data/models/category_dto.dart";
import "package:menu_2026/features/offers/data/models/offer_dto.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_photo_entity.dart";

class AdminRestaurantDetailPage extends ConsumerStatefulWidget {
  const AdminRestaurantDetailPage({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  ConsumerState<AdminRestaurantDetailPage> createState() =>
      _AdminRestaurantDetailPageState();
}

class _AdminRestaurantDetailPageState extends ConsumerState<AdminRestaurantDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _loading = true;
  String? _error;
  final TextEditingController _nameEn = TextEditingController();
  final TextEditingController _nameAr = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _logo = TextEditingController();
  final TextEditingController _descEn = TextEditingController();
  final TextEditingController _descAr = TextEditingController();

  List<CategoryDto> _allCategories = <CategoryDto>[];
  Set<String> _selectedCats = <String>{};
  List<RestaurantPhotoEntity> _photos = <RestaurantPhotoEntity>[];
  List<OfferDto> _offers = <OfferDto>[];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _nameEn.dispose();
    _nameAr.dispose();
    _phone.dispose();
    _logo.dispose();
    _descEn.dispose();
    _descAr.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final MenuApi api = ref.read(menuApiProvider);
      final Map<String, dynamic> d = await api.getRestaurantDetails(widget.restaurantId);
      final List<CategoryDto> cats = await api.getCategories(activeOnly: false);
      final List<RestaurantPhotoEntity> ph =
          await api.getRestaurantPhotos(widget.restaurantId);
      final List<OfferDto> allOff = await api.adminGetAllOffers();
      final List<OfferDto> mine = allOff
          .where((OfferDto o) => o.restaurantId == widget.restaurantId)
          .toList(growable: false);

      final List<dynamic> assigned =
          (d["categories"] as List<dynamic>?) ?? <dynamic>[];
      final Set<String> sel = <String>{
        for (final dynamic x in assigned)
          (x is Map ? (x["id"] ?? x["categoryId"]) : x).toString(),
      };

      if (!mounted) return;
      setState(() {
        _nameEn.text = (d["nameEn"] ?? d["name_en"] ?? "").toString();
        _nameAr.text = (d["nameAr"] ?? d["name_ar"] ?? "").toString();
        _phone.text = (d["phone"] ?? "").toString();
        _logo.text = (d["logoUrl"] ?? d["logo_url"] ?? "").toString();
        _descEn.text = (d["descriptionEn"] ?? d["description_en"] ?? "").toString();
        _descAr.text = (d["descriptionAr"] ?? d["description_ar"] ?? "").toString();
        _allCategories = cats;
        _selectedCats = sel;
        _photos = ph;
        _offers = mine;
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

  Future<void> _saveInfo() async {
    try {
      await ref.read(menuApiProvider).adminUpdateRestaurant(
            widget.restaurantId,
            nameEn: _nameEn.text.trim(),
            nameAr: _nameAr.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            logoUrl: _logo.text.trim().isEmpty ? null : _logo.text.trim(),
            descriptionEn: _descEn.text.trim().isEmpty ? null : _descEn.text.trim(),
            descriptionAr: _descAr.text.trim().isEmpty ? null : _descAr.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved")));
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?.toString() ?? "Failed")),
      );
    }
  }

  Future<void> _saveCategories() async {
    try {
      await ref.read(menuApiProvider).adminUpdateRestaurant(
            widget.restaurantId,
            categoryIds: _selectedCats.toList(growable: false),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Categories updated")));
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?.toString() ?? "Failed")),
      );
    }
  }

  Future<void> _addPhotoUrl() async {
    final String? url = await _promptSimple(context, "Image URL");
    if (url == null || url.isEmpty) return;
    try {
      await ref.read(menuApiProvider).adminCreateRestaurantPhoto(
            restaurantId: widget.restaurantId,
            imageUrl: url,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Photo added")));
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?.toString() ?? "Failed")),
      );
    }
  }

  Future<void> _deletePhoto(RestaurantPhotoEntity p) async {
    try {
      await ref.read(menuApiProvider).adminDeleteRestaurantPhoto(p.id);
      if (mounted) await _load();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?.toString() ?? "Failed")),
      );
    }
  }

  Future<void> _addOffer() async {
    final String? title = await _promptSimple(context, "Offer title");
    if (title == null || title.isEmpty) return;
    try {
      await ref.read(menuApiProvider).adminCreateOffer(
            restaurantId: widget.restaurantId,
            title: title,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Offer created")));
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?.toString() ?? "Failed")),
      );
    }
  }

  Future<void> _deleteRestaurant() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text("Delete restaurant"),
        content: const Text("This removes the restaurant and related data. Continue?"),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(menuApiProvider).adminDeleteRestaurant(widget.restaurantId);
      if (mounted) {
        context.go("/admin/restaurants");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted")));
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?.toString() ?? "Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Restaurant")),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_nameEn.text.isEmpty ? "Restaurant" : _nameEn.text),
        bottom: TabBar(
          controller: _tabs,
          tabs: const <Tab>[
            Tab(text: "Info"),
            Tab(text: "Categories"),
            Tab(text: "Photos"),
            Tab(text: "Offers"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextField(controller: _nameEn, decoration: const InputDecoration(labelText: "Name EN")),
              TextField(controller: _nameAr, decoration: const InputDecoration(labelText: "Name AR")),
              TextField(controller: _phone, decoration: const InputDecoration(labelText: "Phone")),
              TextField(controller: _logo, decoration: const InputDecoration(labelText: "Logo URL")),
              TextField(controller: _descEn, decoration: const InputDecoration(labelText: "Description EN"), maxLines: 3),
              TextField(controller: _descAr, decoration: const InputDecoration(labelText: "Description AR"), maxLines: 3),
              const SizedBox(height: 16),
              FilledButton(onPressed: _saveInfo, child: const Text("Save")),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _deleteRestaurant,
                icon: const Icon(Icons.delete_outline),
                label: const Text("Delete restaurant"),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: _allCategories
                      .map(
                        (CategoryDto c) => CheckboxListTile(
                          title: Text(c.nameEn),
                          value: _selectedCats.contains(c.id),
                          onChanged: (bool? v) {
                            setState(() {
                              if (v == true) {
                                _selectedCats.add(c.id);
                              } else {
                                _selectedCats.remove(c.id);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(onPressed: _saveCategories, child: const Text("Save categories")),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: FilledButton.icon(
                  onPressed: _addPhotoUrl,
                  icon: const Icon(Icons.add_link),
                  label: const Text("Add photo by URL"),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: _photos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, int i) {
                    final RestaurantPhotoEntity p = _photos[i];
                    return ListTile(
                      title: Text(p.imageUrl, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deletePhoto(p),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: FilledButton.icon(
                  onPressed: _addOffer,
                  icon: const Icon(Icons.add),
                  label: const Text("New offer"),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: _offers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, int i) {
                    final OfferDto o = _offers[i];
                    return ListTile(
                      title: Text(o.title),
                      subtitle: Text(o.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          try {
                            await ref.read(menuApiProvider).adminDeleteOffer(o.id);
                            if (mounted) await _load();
                          } catch (_) {}
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<String?> _promptSimple(BuildContext context, String label) async {
  final TextEditingController c = TextEditingController();
  final String? r = await showDialog<String>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: Text(label),
      content: TextField(controller: c, autofocus: true),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text("OK")),
      ],
    ),
  );
  c.dispose();
  return r;
}
