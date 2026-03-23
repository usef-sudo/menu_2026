import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";
import "package:menu_2026/core/network/dio_error_message.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_restaurant_offer_sheet.dart";
import "package:menu_2026/features/categories/data/models/category_dto.dart";
import "package:menu_2026/features/offers/data/models/offer_dto.dart";
import "package:menu_2026/features/restaurants/domain/entities/restaurant_photo_entity.dart";
import "package:menu_2026/l10n/app_localizations.dart";

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
      final List<OfferDto> offers =
          await api.adminListOffers(restaurantId: widget.restaurantId);

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
        _offers = offers;
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
    final AppLocalizations l10n = AppLocalizations.of(context);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonSaved)),
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

  Future<void> _saveCategories() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    try {
      await ref.read(menuApiProvider).adminUpdateRestaurant(
            widget.restaurantId,
            categoryIds: _selectedCats.toList(growable: false),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminCategoriesUpdated)),
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

  Future<void> _addPhotoUrl() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? url = await _promptSimple(context, l10n.adminImageUrlPrompt);
    if (url == null || url.isEmpty) return;
    try {
      await ref.read(menuApiProvider).adminCreateRestaurantPhoto(
            restaurantId: widget.restaurantId,
            imageUrl: url,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminPhotoAdded)),
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

  Future<void> _addPhotoFromGallery() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (!mounted || file == null) return;
    try {
      final List<int> bytes = await file.readAsBytes();
      await ref.read(menuApiProvider).adminUploadRestaurantPhoto(
            restaurantId: widget.restaurantId,
            imageBytes: bytes,
            filename: file.name,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminPhotoAdded)),
        );
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(e))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
        SnackBar(content: Text(dioErrorMessage(e))),
      );
    }
  }

  Future<void> _addOffer() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool created = await showAdminRestaurantOfferSheet(
      context: context,
      l10n: l10n,
      api: ref.read(menuApiProvider),
      restaurantId: widget.restaurantId,
    );
    if (!mounted || !created) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.adminOfferCreated)),
    );
    await _load();
  }

  Future<void> _deleteRestaurant() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.adminDeleteRestaurantTitle),
        content: Text(l10n.adminDeleteRestaurantBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(menuApiProvider).adminDeleteRestaurant(widget.restaurantId);
      if (mounted) {
        context.go("/admin/restaurants");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonDeleted)),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(e))),
      );
    }
  }

  Future<void> _deleteOffer(OfferDto o) async {
    try {
      await ref.read(menuApiProvider).adminDeleteOffer(o.id);
      if (mounted) await _load();
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adminRestaurantFallback)),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_nameEn.text.isEmpty ? l10n.adminRestaurantFallback : _nameEn.text),
        bottom: TabBar(
          controller: _tabs,
          tabs: <Tab>[
            Tab(text: l10n.adminTabInfo),
            Tab(text: l10n.adminTabCategories),
            Tab(text: l10n.adminTabPhotos),
            Tab(text: l10n.adminTabOffers),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextField(controller: _nameEn, decoration: InputDecoration(labelText: l10n.adminNameEnPrompt)),
              const SizedBox(height: 8),
              TextField(controller: _nameAr, decoration: InputDecoration(labelText: l10n.adminNameArPrompt)),
              const SizedBox(height: 8),
              TextField(controller: _phone, decoration: InputDecoration(labelText: l10n.adminLabelPhone)),
              const SizedBox(height: 8),
              TextField(controller: _logo, decoration: InputDecoration(labelText: l10n.adminLabelLogoUrl)),
              const SizedBox(height: 8),
              TextField(
                controller: _descEn,
                decoration: InputDecoration(labelText: l10n.adminLabelDescEn),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descAr,
                decoration: InputDecoration(labelText: l10n.adminLabelDescAr),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _saveInfo, child: Text(l10n.commonSave)),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _deleteRestaurant,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.adminDeleteRestaurantTitle),
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
                child: FilledButton(
                  onPressed: _saveCategories,
                  child: Text(l10n.adminSaveCategories),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: _addPhotoFromGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l10n.adminAddPhotoFromGallery),
                    ),
                    OutlinedButton.icon(
                      onPressed: _addPhotoUrl,
                      icon: const Icon(Icons.add_link),
                      label: Text(l10n.adminAddPhotoByUrl),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _photos.isEmpty
                    ? Center(child: Text(l10n.adminNoPhotosPlaceholder))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _photos.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(height: 1),
                        itemBuilder: (BuildContext context, int i) {
                          final RestaurantPhotoEntity p = _photos[i];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                p.imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                            title: Text(
                              p.imageUrl,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                  label: Text(l10n.adminNewOffer),
                ),
              ),
              Expanded(
                child: _offers.isEmpty
                    ? Center(child: Text(l10n.adminNoOffersPlaceholder))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _offers.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(height: 1),
                        itemBuilder: (BuildContext context, int i) {
                          final OfferDto o = _offers[i];
                          return ListTile(
                            leading: o.imageUrl.isEmpty
                                ? const Icon(Icons.local_offer_outlined)
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      o.imageUrl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          const Icon(Icons.local_offer_outlined),
                                    ),
                                  ),
                            title: Text(o.title),
                            subtitle: Text(
                              <String>[
                                if (o.description.isNotEmpty) o.description,
                                if (o.startDate != null && o.startDate!.isNotEmpty)
                                  "${o.startDate} → ${o.endDate ?? ""}",
                              ].join("\n"),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteOffer(o),
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
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String? r = await showDialog<String>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: Text(label),
      content: TextField(controller: c, autofocus: true),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: Text(l10n.commonOk)),
      ],
    ),
  );
  c.dispose();
  return r;
}
