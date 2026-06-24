// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> saveAndShareFile(String data, String fileName) async {
  final blob = html.Blob([data], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
