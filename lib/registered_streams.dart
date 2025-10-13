import 'package:flutter/material.dart';
import 'package:stream_check/home_screen.dart';
import 'package:stream_check/profile_page.dart';
import 'package:stream_check/add_item_dialog.dart';
import 'package:stream_check/reg_streams_list.dart';

class RegisteredStreams extends StatefulWidget {
  const RegisteredStreams({super.key});

  @override
  State<RegisteredStreams> createState() => _RegisteredStreamsState();
}

class _RegisteredStreamsState extends State<RegisteredStreams> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registered Streams",
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
                  MaterialPageRoute(builder: (_) => ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.black),
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
              padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
              alignment: Alignment.bottomLeft,
              height: 180,
              child: Text(
                'Menu',
                style: TextStyle(fontFamily: 'AmaticSC', fontSize: 80),
              ),
            ),
            ListTile(
              leading: Icon(Icons.stop_outlined),
              title: Text(
                'Current Streams',
                style: TextStyle(fontFamily: 'LibertinusSans', fontSize: 20),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return HomeScreen();
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.play_arrow_outlined),
              title: Text(
                'Registered Streams',
                style: TextStyle(fontFamily: 'LibertinusSans', fontSize: 20),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 14, 20),
        child: FloatingActionButton(
          backgroundColor: Colors.grey[300],
          onPressed: () {
            showDialog(context: context, builder: (context) => AddItemDialog());
          },
          child: Icon(Icons.add),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.fromLTRB(10, 50, 10, 0),
        child: RegStreamsList(),
      ),
    );
  }
}
