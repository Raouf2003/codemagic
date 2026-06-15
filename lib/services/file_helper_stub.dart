import 'dart:html' as html;

void downloadFile(String filename, List<int> bytes) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  html.Url.revokeObjectUrl(url);
}
