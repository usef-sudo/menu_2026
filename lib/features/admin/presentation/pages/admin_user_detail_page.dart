import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/features/admin/data/admin_user_dto.dart";

class AdminUserDetailPage extends ConsumerStatefulWidget {
  const AdminUserDetailPage({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends ConsumerState<AdminUserDetailPage> {
  bool _loading = true;
  String? _error;
  AdminUserDto? _user;

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
      final AdminUserDto u =
          await ref.read(menuApiProvider).adminGetUser(widget.userId);
      if (!mounted) return;
      setState(() {
        _user = u;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go("/admin/users");
            }
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _error != null
              ? Center(child: Text(_error!))
              : _user == null
                  ? const Center(child: Text("Not found"))
                  : ListView(
                      padding: const EdgeInsets.all(24),
                      children: <Widget>[
                        ListTile(
                          title: const Text("Email"),
                          subtitle: Text(_user!.email),
                        ),
                        ListTile(
                          title: const Text("Name"),
                          subtitle: Text(_user!.name ?? "—"),
                        ),
                        ListTile(
                          title: const Text("Role"),
                          subtitle: Text(_user!.role ?? "—"),
                        ),
                        ListTile(
                          title: const Text("Phone"),
                          subtitle: Text(_user!.phoneNumber ?? "—"),
                        ),
                        ListTile(
                          title: const Text("Gender"),
                          subtitle: Text(_user!.gender ?? "—"),
                        ),
                        ListTile(
                          title: const Text("Birth date"),
                          subtitle: Text(_user!.birthDate ?? "—"),
                        ),
                        ListTile(
                          title: const Text("Created"),
                          subtitle: Text(_user!.createdAt ?? "—"),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Role changes and bans require new API endpoints.",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
    );
  }
}
