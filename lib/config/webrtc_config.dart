class WebRTCConfig {
  static const TWILIO_API_KEY_SID = 'ACfeb3b5e2a5edb30a3c3ab530391387be';
  static const TWILIO_API_KEY_SECRET = '560e85e337a5c64646b257a5d8be8f5e';

  static final Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': 'turn:global.turn.twilio.com:3478',
        'username': TWILIO_API_KEY_SID,
        'credential': TWILIO_API_KEY_SECRET
      },
      // Keeping Google's STUN servers as fallback
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };
} 