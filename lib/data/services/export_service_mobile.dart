import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveAndShareFile(String data, String fileName) async {
  final Directory directory = await getTemporaryDirectory();
  final String path = '${directory.path}/$fileName';
  final File file = File(path);
  await file.writeAsString(data);

  await Share.shareXFiles([XFile(path)], text: 'My Ledgr Expense Report');
}
