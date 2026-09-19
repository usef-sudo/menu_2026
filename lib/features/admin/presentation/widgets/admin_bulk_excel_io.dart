import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:path_provider/path_provider.dart";
import "package:share_plus/share_plus.dart";

const String kExcelMime =
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

Future<void> shareExcelTemplate({
  required List<int> bytes,
  required String filename,
}) async {
  final Directory dir = await getTemporaryDirectory();
  final File file = File("${dir.path}/$filename");
  await file.writeAsBytes(bytes, flush: true);
  await SharePlus.instance.share(
    ShareParams(
      files: <XFile>[
        XFile(file.path, mimeType: kExcelMime, name: filename),
      ],
      subject: filename,
    ),
  );
}

Future<({List<int> bytes, String filename})?> pickExcelFile() async {
  final FilePickerResult? result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: <String>["xlsx"],
    withData: true,
  );
  if (result == null || result.files.isEmpty) {
    return null;
  }
  final PlatformFile file = result.files.first;
  final List<int>? bytes = file.bytes;
  if (bytes != null && bytes.isNotEmpty) {
    return (bytes: bytes, filename: file.name);
  }
  final String? path = file.path;
  if (path == null || path.isEmpty) {
    return null;
  }
  final List<int> fromDisk = await File(path).readAsBytes();
  return (bytes: fromDisk, filename: file.name);
}
