import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> downloadFile(String filename, List<int> bytes) async {
  final appDir = await getExternalStorageDirectory();
  final dir = Directory('${appDir!.path}/Reports');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes);
  await OpenFile.open(file.path);
}
