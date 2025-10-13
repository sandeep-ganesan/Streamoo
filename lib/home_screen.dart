import 'package:flutter/material.dart';
import 'package:stream_check/profile_page.dart';
import 'package:stream_check/reg_streams_list.dart';
import 'package:stream_check/registered_streams.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String? _liveDurationSince(String? startedAtIso) {
    if (startedAtIso == null || startedAtIso.isEmpty) return null;
    try {
      var dt = DateTime.parse(startedAtIso);
      if (!dt.isUtc) dt = dt.toUtc();
      final diff = DateTime.now().toUtc().difference(dt);
      if (diff.isNegative) return null;
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      final s = diff.inSeconds % 60;

      String core;
      if (h > 0) {
        core = '${h}h ${m}m';
      } else if (m > 0) {
        core = '${m}m';
      } else {
        core = '${s}s';
      }
      return '$core';
    } catch (_) {
      return null;
    }
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Query<Map<String, dynamic>> _queryForUser() {
    final uid = _uid;
    if (uid == null) {
      return FirebaseFirestore.instance
          .collection('users/__none__/streams')
          .where('isLive', isEqualTo: true)
          .orderBy('startedAt', descending: true);
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('streams')
        .where('isLive', isEqualTo: true)
        .orderBy('startedAt', descending: true);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _streamData() =>
      _queryForUser().snapshots();

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _fallbackChannelUrl(Map<String, dynamic> s) {
    final type = (s['type'] ?? '').toString();
    final sid = (s['StreamID'] ?? '').toString();
    if (type == 'Twitch' && sid.isNotEmpty) {
      return 'https://www.twitch.tv/${sid.toLowerCase()}';
    }
    if (type == 'Youtube' && sid.isNotEmpty) {
      if (sid.startsWith('UC')) return 'https://www.youtube.com/channel/$sid';
      if (sid.startsWith('@')) return 'https://www.youtube.com/$sid';
      return 'https://www.youtube.com/$sid';
    }
    return 'https://www.youtube.com/';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Current Streams",
          style: TextStyle(fontFamily: 'LibertinusSans', fontSize: 26),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              alignment: Alignment.bottomLeft,
              height: 180,
              child: const Text(
                'Menu',
                style: TextStyle(fontFamily: 'AmaticSC', fontSize: 80),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow_outlined),
              title: const Text(
                'Current Streams',
                style: TextStyle(fontFamily: 'LibertinusSans', fontSize: 20),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.stop_outlined),
              title: const Text(
                'Registered Streams',
                style: TextStyle(fontFamily: 'LibertinusSans', fontSize: 20),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const RegisteredStreams();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
              onRefresh: () => const RegStreamsList().forceRefresh(),
              child: items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 160),
                        Center(child: Text('No live streams right now.')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final s = items[i];
                        final cname = (s['Cname'] ?? 'Unknown').toString();
                        final title = (s['liveTitle'] ?? '').toString();
                        final thumb = (s['liveThumbnail'] ?? '').toString();
                        final logo = (s['logoUrl'] ?? '').toString();
                        final liveUrl = (s['liveUrl'] ?? '').toString();
                        final startedAt = (s['startedAt'] ?? '').toString();
                        final liveFor = _liveDurationSince(startedAt);
                        final targetUrl = liveUrl.isNotEmpty
                            ? liveUrl
                            : _fallbackChannelUrl(s);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    (thumb.isNotEmpty)
                                        ? Image.network(
                                            thumb,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Center(
                                                  child: Icon(
                                                    Icons
                                                        .image_not_supported_outlined,
                                                  ),
                                                ),
                                          )
                                        : Container(
                                            color: Colors.black12,
                                            child: const Center(
                                              child: Icon(
                                                Icons.ondemand_video_outlined,
                                              ),
                                            ),
                                          ),

                                    if (liveFor != null)
                                      Positioned(
                                        right: 8,
                                        bottom: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.75,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              1,
                                            ),
                                          ),
                                          child: Text(
                                            liveFor,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontFamily: 'UbuntuMedium',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  12,
                                  12,
                                  4,
                                ),
                                child: Text(
                                  title.isNotEmpty ? title : 'Live stream',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'LibertinusSans',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(
                                  8,
                                  4,
                                  8,
                                  8,
                                ),

                                leading: IconButton(
                                  tooltip: 'Open channel',
                                  onPressed: () =>
                                      _openUrl(_fallbackChannelUrl(s)),
                                  icon: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: (logo.isNotEmpty)
                                        ? Image.network(
                                            logo,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                  Icons.person_outline,
                                                ),
                                          )
                                        : const Icon(Icons.person_outline),
                                  ),
                                ),

                                title: Text(
                                  cname,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'LibertinusSans',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: ElevatedButton.icon(
                                  onPressed: () => _openUrl(targetUrl),
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 20,
                                  ),
                                  label: const Text('Watch'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
