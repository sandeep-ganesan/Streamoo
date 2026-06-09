import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_widget/home_widget.dart';

class LiveWidgetController {
  // Must match your Android Glance receiver class path exactly:
  // android/app/src/main/kotlin/com/sandeep/stream_check/glance/HomeWidgetReceiver.kt
  static const String _androidQualifiedName =
      'com.sandeep.stream_check.glance.HomeWidgetReceiver';

  static const String _kHasLive = 'hasLive';
  static const String _kStatusText = 'statusText';
  static const String _kDetailText = 'detailText';

  static Future<void> updateFromFirestore(String uid) async {
    final summary = await _liveSummary(uid);
    await _saveState(
      hasLive: summary.hasLive,
      statusText: summary.statusText,
      detailText: summary.detailText,
    );
    await _refreshWidget();
  }

  static Future<void> applyDirect({
    required bool hasLive,
    String? statusText,
    String? detailText,
  }) async {
    await _saveState(
      hasLive: hasLive,
      statusText: statusText ?? (hasLive ? 'LIVE NOW' : 'No Live Streams'),
      detailText: detailText ?? (hasLive ? 'Tap to open' : '—'),
    );
    await _refreshWidget();
  }

  static Future<_LiveSummary> _liveSummary(String uid) async {
    final q = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('streams')
        .where('isLive', isEqualTo: true)
        .orderBy('startedAt', descending: true)
        .limit(1)
        .get(const GetOptions(source: Source.serverAndCache));

    if (q.docs.isEmpty) {
      return const _LiveSummary(
        hasLive: false,
        statusText: 'No Live Streams',
        detailText: '—',
      );
    }

    final d = q.docs.first.data();
    final title = (d['liveTitle'] ?? '').toString().trim();
    final cname = (d['Cname'] ?? '').toString().trim();
    final detail = title.isNotEmpty
        ? title
        : (cname.isNotEmpty ? cname : 'Live');

    return _LiveSummary(
      hasLive: true,
      statusText: 'LIVE NOW',
      detailText: detail,
    );
  }

  static Future<void> _saveState({
    required bool hasLive,
    required String statusText,
    required String detailText,
  }) async {
    await HomeWidget.saveWidgetData<bool>(_kHasLive, hasLive);
    await HomeWidget.saveWidgetData<String>(_kStatusText, statusText);
    await HomeWidget.saveWidgetData<String>(_kDetailText, detailText);
  }

  static Future<void> _refreshWidget() async {
    // Glance setup (home_widget 0.8.x): update using the qualified receiver name
    await HomeWidget.updateWidget(qualifiedAndroidName: _androidQualifiedName);
  }
}

class _LiveSummary {
  final bool hasLive;
  final String statusText;
  final String detailText;

  const _LiveSummary({
    required this.hasLive,
    required this.statusText,
    required this.detailText,
  });
}
