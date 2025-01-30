import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'video_call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  final String chatId;
  final String callerName;
  final bool isVideo;
  final String callerId;

  const IncomingCallScreen({
    super.key,
    required this.chatId,
    required this.callerName,
    required this.isVideo,
    required this.callerId,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _playRingtone();
  }

  Future<void> _playRingtone() async {
    try {
      // Using a bundled asset
      await _audioPlayer.setAsset('assets/sounds/ringtone.mp3');
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
      setState(() => _isPlaying = true);
    } catch (e) {
      print('Error playing ringtone: $e');
    }
  }

  void _stopRingtone() {
    if (_isPlaying) {
      _audioPlayer.stop();
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _acceptCall() async {
    _stopRingtone();
    
    // Update call status in Firestore
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.chatId)
        .update({'status': 'accepted'});

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            chatId: widget.chatId,
            remoteUserId: widget.callerId,
            isVideo: widget.isVideo,
          ),
        ),
      );
    }
  }

  Future<void> _rejectCall() async {
    _stopRingtone();
    
    // Update call status in Firestore
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.chatId)
        .update({'status': 'rejected'});

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _stopRingtone();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              child: Icon(
                widget.isVideo ? Icons.videocam : Icons.phone,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.callerName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isVideo ? 'Incoming video call...' : 'Incoming voice call...',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    onPressed: _rejectCall,
                  ),
                  _CallButton(
                    icon: Icons.call,
                    color: Colors.green,
                    onPressed: _acceptCall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CallButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 36,
          color: Colors.white,
        ),
      ),
    );
  }
} 