import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class RegStreamsList extends StatelessWidget {
  const RegStreamsList({super.key});

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static const String _serverBaseUrl = 'https://streamoo-backend.onrender.com';
  static const String _cronSecret = 'streamoo-secret';

  Query<Map<String, dynamic>> _queryForUser() {
    final uid = _uid;
    if (uid == null) {
      return FirebaseFirestore.instance
          .collection('users/__none__/streams')
          .orderBy('Cname');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('streams')
        .orderBy('Cname');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _streamData() =>
      _queryForUser().snapshots();

  Future<void> triggerServerUpdate() async {
    final uid = _uid;
    if (uid == null) return;
    final uri = Uri.parse('$_serverBaseUrl/cron/update_user/$uid');
    try {
      await http
          .get(
            uri,
            headers: {if (_cronSecret.isNotEmpty) 'X-Cron-Secret': _cronSecret},
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {}
  }

  Future<void> forceRefresh() async {
    await triggerServerUpdate();
    await _queryForUser().get(const GetOptions(source: Source.server));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _streamData(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snap.data!.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList(growable: false);

        return RefreshIndicator(
          onRefresh: forceRefresh,
          child: items.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 160),
                    Center(child: Text('No registered streams found.')),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final s = items[i];
                    final String docId = s['id'] as String;
                    final cname = s['Cname'] ?? 'Unknown';
                    final streamId = s['StreamID'] ?? 'N/A';
                    final type = s['type'] ?? '—';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child:
                                (s['logoUrl'] is String &&
                                    (s['logoUrl'] as String).isNotEmpty)
                                ? Image.network(
                                    s['logoUrl'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_not_supported_outlined,
                                    ),
                                  )
                                : const Icon(Icons.image_outlined),
                          ),
                        ),
                        title: Text(
                          cname,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'LibertinusSans',
                          ),
                        ),
                        subtitle: Text(
                          'Channel ID: $streamId\nPlatform: $type',
                          style: const TextStyle(fontFamily: 'LibertinusSans'),
                        ),
                        isThreeLine: true,
                        trailing: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: IconButton(
                            onPressed: () =>
                                _confirmAndDelete(context, docId, cname),
                            tooltip: 'delete channel',
                            icon: const Icon(Icons.delete_outline_outlined),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

Future<void> _deleteStream(BuildContext context, String docId) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('You must be signed in.')));
    return;
  }
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('streams')
        .doc(docId)
        .delete();

    Fluttertoast.showToast(msg: "Channel Removed.", timeInSecForIosWeb: 2);
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Error. Please try again later.",
      timeInSecForIosWeb: 2,
    );
  }
}

Future<void> _confirmAndDelete(
  BuildContext context,
  String docId,
  String name,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(5)),
      title: const Text(
        'Remove channel?',
        style: TextStyle(fontFamily: 'AmaticSC'),
      ),
      content: Text(
        'This will remove "$name" from your registered streams.',
        style: TextStyle(fontFamily: 'LibertinusSans'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Cancel',
            style: TextStyle(fontFamily: 'LibertinusSans'),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(
            'Remove',
            style: TextStyle(fontFamily: 'LibertinusSans'),
          ),
        ),
      ],
    ),
  );
  if (ok == true) {
    await _deleteStream(context, docId);
  }
}
