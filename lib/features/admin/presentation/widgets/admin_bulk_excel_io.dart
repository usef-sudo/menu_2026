import "dart:typed_data";

import "package:file_picker/file_picker.dart";
import "package:share_plus/share_plus.dart";

const String kExcelMime =
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

Future<void> shareExcelTemplate({
  required List<int> bytes,
  required String filename,
}) async {
  await SharePlus.instance.share(
    ShareParams(
      files: <XFile>[
        XFile.fromData(
          Uint8List.fromList(bytes),
          mimeType: kExcelMime,
          name: filename,
        ),
      ],
      fileNameOverrides: <String>[filename],
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
  final Uint8List? bytes = file.bytes;
  if (bytes == null || bytes.isEmpty) {
    return null;
  }
  return (bytes: bytes, filename: file.name);
}
