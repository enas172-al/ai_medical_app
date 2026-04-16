import '../models/analysis_model.dart';
import 'database_service.dart';

/// Time-window queries and chart-oriented lists (Labby tracking layer).
enum TrackingPeriod {
  all,
  week,
  month,
  year,
}

class TrackingService {
  TrackingService({DatabaseService? database}) : _db = database ?? DatabaseService();

  final DatabaseService _db;

  /// Inclusive [start, end] for calendar filtering (end = end of day).
  static ({DateTime start, DateTime end}) rangeFor(TrackingPeriod period, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final end = DateTime(n.year, n.month, n.day, 23, 59, 59, 999);
    switch (period) {
      case TrackingPeriod.all:
        return (start: DateTime(1970), end: end);
      case TrackingPeriod.week:
        final start = n.subtract(const Duration(days: 7));
        return (start: DateTime(start.year, start.month, start.day), end: end);
      case TrackingPeriod.month:
        final start = DateTime(n.year, n.month - 1, n.day);
        return (start: start, end: end);
      case TrackingPeriod.year:
        final start = DateTime(n.year - 1, n.month, n.day);
        return (start: start, end: end);
    }
  }

  static bool isInRange(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  /// Server-backed range query (uses Firestore composite indexes).
  Future<List<AnalysisModel>> getAnalysesForPeriod(
    String userId,
    TrackingPeriod period,
  ) async {
    if (period == TrackingPeriod.all) {
      return _db.getAnalysesOnce(userId);
    }
    final r = rangeFor(period);
    return _db.getAnalysesInDateRange(userId, r.start, r.end);
  }

  /// Filter an in-memory list (e.g. from a stream) by period.
  List<AnalysisModel> filterByPeriod(
    List<AnalysisModel> items,
    TrackingPeriod period,
  ) {
    if (period == TrackingPeriod.all) return items;
    final r = rangeFor(period);
    return items.where((a) => isInRange(a.date, r.start, r.end)).toList();
  }

  /// Points for line chart: x = index, y = value (oldest → newest).
  List<({int index, double value, DateTime date})> seriesForChart(
    List<AnalysisModel> ascendingByDate,
  ) {
    final sorted = [...ascendingByDate]..sort((a, b) => a.date.compareTo(b.date));
    return [
      for (var i = 0; i < sorted.length; i++)
        (index: i, value: sorted[i].value, date: sorted[i].date),
    ];
  }
}
