import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import '../config/webrtc_config.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends StatefulWidget {
  final String chatId;
  final String remoteUserId;
  final bool isVideo; // true for video call, false for voice call

  const VideoCallScreen({
    super.key,
    required this.chatId,
    required this.remoteUserId,
    required this.isVideo,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  RTCPeerConnection? _peerConnection;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    
    if (await Permission.camera.isGranted && 
        await Permission.microphone.isGranted) {
      _initializeCall();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera and microphone permissions are required'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _initializeCall() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      
      // Create peer connection with Twilio configuration
      _peerConnection = await createPeerConnection(WebRTCConfig.configuration);

      // Get local media stream
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': widget.isVideo ? {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
        } : false,
      });

      // Add local stream to peer connection
      if (_peerConnection != null) {
        _localStream!.getTracks().forEach((track) {
          _peerConnection!.addTrack(track, _localStream!);
        });

        // Set local video
        if (widget.isVideo) {
          _localRenderer.srcObject = _localStream;
        }

        // Set up event handlers
        _peerConnection!.onTrack = (RTCTrackEvent event) {
          if (event.streams.isNotEmpty) {
            _remoteRenderer.srcObject = event.streams[0];
          }
        };

        // Handle signaling through Firestore
        _setupSignaling();

        // Initiate the call
        await _makeCall();
      }
    } catch (e) {
      print('Error initializing call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing call: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _setupSignaling() {
    final callDoc = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.chatId);

    // Listen for remote ICE candidates
    callDoc.collection('candidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          final candidate = RTCIceCandidate(
            change.doc.data()!['candidate'],
            change.doc.data()!['sdpMid'],
            change.doc.data()!['sdpMLineIndex'],
          );
          _peerConnection?.addCandidate(candidate);
        }
      });
    });

    // Listen for remote session description
    callDoc.snapshots().listen((snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      
      if (data['status'] == 'rejected') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Call rejected')),
          );
          Navigator.pop(context);
        }
      } else if (data['answer'] != null && data['type'] == 'answer') {
        final answer = RTCSessionDescription(
          data['answer'],
          data['type'],
        );
        _peerConnection?.setRemoteDescription(answer);
      }
    });

    // Handle ICE candidates
    _peerConnection!.onIceCandidate = (candidate) {
      callDoc.collection('candidates').add({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };
  }

  Future<void> _makeCall() async {
    if (_peerConnection == null) return;

    // Create offer
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    // Save offer to Firestore
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.chatId)
        .set({
      'offer': offer.sdp,
      'type': offer.type,
      'from': FirebaseAuth.instance.currentUser!.uid,
      'to': widget.remoteUserId,
      'isVideo': widget.isVideo,
      'status': 'ringing',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _toggleMute() {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks()[0];
      setState(() {
        _isMuted = !_isMuted;
        audioTrack.enabled = !_isMuted;
      });
    }
  }

  void _toggleCamera() {
    if (_localStream != null && widget.isVideo) {
      final videoTrack = _localStream!.getVideoTracks()[0];
      setState(() {
        _isCameraOff = !_isCameraOff;
        videoTrack.enabled = !_isCameraOff;
      });
    }
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
      // Implement audio output switching logic here
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            if (widget.isVideo) Expanded(
              child: Stack(
                children: [
                  // Remote video
                  RTCVideoView(
                    _remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                  // Local video (picture-in-picture)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    width: 100,
                    height: 150,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                      ),
                      child: RTCVideoView(
                        _localRenderer,
                        mirror: true,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Call controls
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF2F3136),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      _isMuted ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                    ),
                    onPressed: _toggleMute,
                  ),
                  if (widget.isVideo)
                    IconButton(
                      icon: Icon(
                        _isCameraOff ? Icons.videocam_off : Icons.videocam,
                        color: Colors.white,
                      ),
                      onPressed: _toggleCamera,
                    ),
                  IconButton(
                    icon: Icon(
                      _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white,
                    ),
                    onPressed: _toggleSpeaker,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.call_end,
                      color: Colors.red,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 