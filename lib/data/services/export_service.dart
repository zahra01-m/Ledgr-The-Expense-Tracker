import 'package:csv/csv.dart';
import '../../domain/entities/expense_entity.dart';
import '../../core/utils/date_formatter.dart';
import 'export_service_stub.dart'
    if (dart.library.html) 'export_service_web.dart'
    if (dart.library.io) 'export_service_mobile.dart';

class ExportService {
  static Future<void> exportToCsv(List<ExpenseEntity> expenses) async {
    final List<List<dynamic>> rows = [
      ['Date', 'Title', 'Category', 'Amount', 'Note', 'Recurring']
    ];

    for (final e in expenses) {
      rows.add([
        DateFormatter.formatDate(e.date),
        e.title,
        e.category.displayName,
        e.amount,
        e.note ?? '',
        e.isRecurring ? e.frequency.displayName : 'No'
      ]);
    }

    final String csvData = const ListToCsvConverter().convert(rows);
    final String fileName = 'ledgr_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    
    await saveAndShareFile(csvData, fileName);
  }
}
