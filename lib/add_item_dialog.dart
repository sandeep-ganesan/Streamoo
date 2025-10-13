import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddItemDialog extends StatefulWidget {
  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _streamIDTextController = TextEditingController();
  final _channelNameController = TextEditingController();
  String? _selectedOption;

  final List<String> _dropdownOptions = ['Youtube', 'Twitch'];

  bool _isLoading = false;

  Future<void> _submitData() async {
    final user = FirebaseAuth.instance.currentUser;
    final streamID = _streamIDTextController.text.trim();
    final name = _channelNameController.text.trim();
    final platform = _selectedOption;

    if (platform == null || streamID.isEmpty || name.isEmpty || user == null) {
      Fluttertoast.showToast(
        msg: "Please fill all the fields.",
        timeInSecForIosWeb: 2,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final streamsCol = userDoc.collection('streams').doc();
      final streamData = <String, dynamic>{
        'Cname': name,
        'StreamID': streamID,
        'type': platform,
      };

      final batch = FirebaseFirestore.instance.batch();

      batch.set(streamsCol, streamData);

      await batch.commit();

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An unexpected error occurred: ${e.toString()}",
        timeInSecForIosWeb: 2,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(5)),
      title: Text(
        'Add Stream',
        style: TextStyle(fontFamily: 'AmaticSC', fontSize: 24),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedOption,
            hint: Text('Select a Platform'),
            onChanged: (value) => setState(() => _selectedOption = value),
            items: _dropdownOptions
                .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                .toList(),
          ),
          TextField(
            controller: _streamIDTextController,
            decoration: InputDecoration(labelText: 'Enter Channel ID'),
          ),
          TextField(
            controller: _channelNameController,
            decoration: InputDecoration(labelText: 'Name of the channel'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(fontFamily: 'LibertinusSans')),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitData,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Submit', style: TextStyle(fontFamily: 'LibertinusSans')),
        ),
      ],
    );
  }
}
