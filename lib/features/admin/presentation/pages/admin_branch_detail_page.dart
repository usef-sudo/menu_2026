import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/admin/data/area_dto.dart";
import "package:menu_2026/features/branches/data/models/branch_dto.dart";
import "package:menu_2026/features/facilities/data/models/facility_dto.dart";
import "package:menu_2026/features/restaurants/domain/entities/menu_image_entity.dart";

class AdminBranchDetailPage extends ConsumerStatefulWidget {
  const AdminBranchDetailPage({super.key, required this.branchId});

  final String branchId;

  @override
  ConsumerState<AdminBranchDetailPage> createState() => _AdminBranchDetailPageState();
}

class _AdminBranchDetailPageState extends ConsumerState<AdminBranchDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _loading = true;
  String? _error;
  BranchDto? _branch;
  final TextEditingController _nameEn = TextEditingController();
  final TextEditingController _nameAr = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _lat = TextEditingController();
  final TextEditingController _lng = TextEditingController();
  final TextEditingController _cost = TextEditingController();
  List<AreaDto> _areas = <AreaDto>[];
  String? _areaId;
  List<MenuImageEntity> _images = <MenuImageEntity>[];
  List<FacilityDto> _facilities = <FacilityDto>[];
  Set<String> _facilitySelection = <String>{};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _nameEn.dispose();
    _nameAr.dispose();
    _address.dispose();
    _lat.dispose();
    _lng.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final MenuApi api = ref.read(menuApiProvider);
      final BranchDto b = await api.getBranch(widget.branchId);
      final List<AreaDto> areas = await api.getAreas();
      final List<MenuImageEntity> imgs = await api.getBranchMenuImages(widget.branchId);
      final List<FacilityDto> fac = await api.getFacilities();
      final List<String> assigned = await api.adminGetBranchFacilityIds(widget.branchId);

      if (!mounted) return;
      setState(() {
        _branch = b;
        _nameEn.text = b.nameEn;
        _nameAr.text = b.nameAr;
        _address.text = b.address;
        _lat.text = b.latitude == 0 ? "" : b.latitude.toString();
        _lng.text = b.longitude == 0 ? "" : b.longitude.toString();
        _cost.text = (b.costLevel ?? 1).toString();
        _areaId = b.areaId;
        _areas = areas;
        _images = imgs;
        _facilities = fac;
        _facilitySelection = assigned.toSet();
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
      await ref.read(menuApiProvider).adminUpdateBranch(
            widget.branchId,
            nameEn: _nameEn.text.trim(),
            nameAr: _nameAr.text.trim(),
            address: _address.text.trim(),
            latitude: _lat.text.trim().isEmpty ? null : _lat.text.trim(),
            longitude: _lng.text.trim().isEmpty ? null : _lng.text.trim(),
            costLevel: int.tryParse(_cost.text.trim()),
            areaId: _areaId,
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

  Future<void> _uploadMenuImage() async {
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (!mounted || file == null) return;
    try {
      final List<int> bytes = await file.readAsBytes();
      await ref.read(menuApiProvider).adminUploadMenuImage(
            branchId: widget.branchId,
            imageBytes: bytes,
            filename: file.name,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploaded")));
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?.toString() ?? "Failed")),
      );
    }
  }

  Future<void> _saveFacilities() async {
    try {
      final MenuApi api = ref.read(menuApiProvider);
      final List<String> current = await api.adminGetBranchFacilityIds(widget.branchId);
      for (final String id in current) {
        await api.adminUnassignBranchFacility(widget.branchId, id);
      }
      if (_facilitySelection.isNotEmpty) {
        await api.adminAssignBranchFacilities(
          widget.branchId,
          _facilitySelection.toList(growable: false),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Facilities saved")));
        await _load();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data?.toString() ?? "Failed")),
      );
    }
  }

  Future<void> _deleteBranch() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text("Delete branch"),
        content: const Text("Delete this branch?"),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(menuApiProvider).adminDeleteBranch(widget.branchId);
      if (mounted) {
        context.go("/admin/branches");
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
    if (_error != null || _branch == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Branch")),
        body: Center(child: Text(_error ?? "Not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_nameEn.text),
        bottom: TabBar(
          controller: _tabs,
          tabs: const <Tab>[
            Tab(text: "Info"),
            Tab(text: "Menu images"),
            Tab(text: "Facilities"),
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
              TextField(controller: _address, decoration: const InputDecoration(labelText: "Address")),
              TextField(controller: _lat, decoration: const InputDecoration(labelText: "Latitude")),
              TextField(controller: _lng, decoration: const InputDecoration(labelText: "Longitude")),
              TextField(controller: _cost, decoration: const InputDecoration(labelText: "Cost level (1–5)")),
              DropdownButtonFormField<String?>(
                decoration: const InputDecoration(labelText: "Area"),
                value: _areaId,
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(value: null, child: Text("None")),
                  ..._areas.map(
                    (AreaDto a) => DropdownMenuItem<String?>(
                      value: a.id,
                      child: Text(a.nameEn),
                    ),
                  ),
                ],
                onChanged: (String? v) => setState(() => _areaId = v),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _saveInfo, child: const Text("Save")),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _deleteBranch,
                icon: const Icon(Icons.delete_outline),
                label: const Text("Delete branch"),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: FilledButton.icon(
                  onPressed: _uploadMenuImage,
                  icon: const Icon(Icons.upload),
                  label: const Text("Upload menu image"),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: _images.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, int i) {
                    final MenuImageEntity m = _images[i];
                    return ListTile(
                      title: Text(m.imageUrl, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          try {
                            await ref.read(menuApiProvider).adminDeleteMenuImage(m.id);
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
          Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: _facilities
                      .map(
                        (FacilityDto f) => CheckboxListTile(
                          title: Text(f.nameEn),
                          value: _facilitySelection.contains(f.id),
                          onChanged: (bool? v) {
                            setState(() {
                              if (v == true) {
                                _facilitySelection.add(f.id);
                              } else {
                                _facilitySelection.remove(f.id);
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
                child: FilledButton(onPressed: _saveFacilities, child: const Text("Save facilities")),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
