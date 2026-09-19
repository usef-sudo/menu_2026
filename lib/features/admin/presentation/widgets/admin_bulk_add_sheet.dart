import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:menu_2026/core/network/dio_error_message.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_bulk_excel_io.dart";
import "package:menu_2026/features/admin/presentation/widgets/admin_editor_header.dart";
import "package:menu_2026/l10n/app_localizations.dart";

Future<bool> showAdminBulkAreasSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required MenuApi api,
}) {
  return _showBulkSheet(
    context: context,
    title: l10n.adminBulkAddAreas,
    instructions: l10n.adminBulkInstructions,
    templatePath: "/areas/bulk/template",
    templateFilename: "areas_template.xlsx",
    uploadPath: "/areas/bulk/upload",
    api: api,
    l10n: l10n,
  );
}

Future<bool> showAdminBulkRestaurantsSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required MenuApi api,
}) {
  return _showBulkSheet(
    context: context,
    title: l10n.adminBulkAddRestaurants,
    instructions: l10n.adminBulkInstructions,
    templatePath: "/restaurants/bulk/template",
    templateFilename: "restaurants_template.xlsx",
    uploadPath: "/restaurants/bulk/upload",
    api: api,
    l10n: l10n,
  );
}

Future<bool> showAdminBulkBranchesSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required MenuApi api,
  required List<dynamic> restaurants,
  required List<dynamic> areas,
  String? initialRestaurantId,
}) {
  if (restaurants.isEmpty) return Future<bool>.value(false);
  return _showBulkSheet(
    context: context,
    title: l10n.adminBulkAddBranches,
    instructions: l10n.adminBulkBranchesHint,
    templatePath: "/branches/bulk/template",
    templateFilename: "branches_template.xlsx",
    uploadPath: "/branches/bulk/upload",
    api: api,
    l10n: l10n,
  );
}

Future<bool> _showBulkSheet({
  required BuildContext context,
  required String title,
  required String instructions,
  required String templatePath,
  required String templateFilename,
  required String uploadPath,
  required MenuApi api,
  required AppLocalizations l10n,
}) async {
  final bool? ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (BuildContext ctx) => _BulkExcelBody(
      title: title,
      instructions: instructions,
      templatePath: templatePath,
      templateFilename: templateFilename,
      uploadPath: uploadPath,
      api: api,
      l10n: l10n,
    ),
  );
  return ok == true;
}

class _BulkExcelBody extends StatefulWidget {
  const _BulkExcelBody({
    required this.title,
    required this.instructions,
    required this.templatePath,
    required this.templateFilename,
    required this.uploadPath,
    required this.api,
    required this.l10n,
  });

  final String title;
  final String instructions;
  final String templatePath;
  final String templateFilename;
  final String uploadPath;
  final MenuApi api;
  final AppLocalizations l10n;

  @override
  State<_BulkExcelBody> createState() => _BulkExcelBodyState();
}

class _BulkExcelBodyState extends State<_BulkExcelBody> {
  bool _busy = false;

  Future<void> _download() async {
    setState(() => _busy = true);
    try {
      final List<int> bytes =
          await widget.api.adminDownloadBulkTemplate(widget.templatePath);
      if (!mounted) return;
      await shareExcelTemplate(
        bytes: bytes,
        filename: widget.templateFilename,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.adminBulkTemplateReady)),
      );
    } on DioException catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(err))),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _upload() async {
    final ({List<int> bytes, String filename})? picked = await pickExcelFile();
    if (picked == null) return;
    setState(() => _busy = true);
    try {
      final Map<String, dynamic> result = await widget.api.adminUploadBulkExcel(
        path: widget.uploadPath,
        bytes: picked.bytes,
        filename: picked.filename,
      );
      if (!mounted) return;
      final int created =
          int.tryParse(result["created"]?.toString() ?? "0") ?? 0;
      final int failed =
          int.tryParse(result["failed"]?.toString() ?? "0") ?? 0;
      final String message = failed > 0
          ? "${widget.l10n.adminBulkCreatedCount(created)} · ${widget.l10n.adminBulkFailedCount(failed)}"
          : widget.l10n.adminBulkCreatedCount(created);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.of(context).pop(created > 0);
    } on DioException catch (err) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dioErrorMessage(err))),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AdminEditorHeader(
              title: widget.title,
              submitting: _busy,
              onClose: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 8),
            Text(
              widget.instructions,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _busy ? null : _download,
              icon: const Icon(Icons.download_rounded),
              label: Text(widget.l10n.adminBulkDownloadTemplate),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _busy ? null : _upload,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file_rounded),
              label: Text(widget.l10n.adminBulkUploadSheet),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
