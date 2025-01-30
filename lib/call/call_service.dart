import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'incoming_call_screen.dart';

class CallService {
  static void listenForCalls(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    FirebaseFirestore.instance
        .collection('calls')
        .where('to', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          final callerId = data['from'] as String;
          
          // Get caller's name
          final callerDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(callerId)
              .get();
          
          final callerName = callerDoc.data()?['nickname'] ?? 'Unknown';
          
          // Show incoming call screen
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IncomingCallScreen(
                  chatId: change.doc.id,
                  callerName: callerName,
                  isVideo: data['isVideo'] ?? false,
                  callerId: callerId,
                ),
              ),
            );
          }
        }
      }
    });
  }
} 