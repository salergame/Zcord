import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatelessWidget {
  const QRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'QR Код',
          style: TextStyle(color: Colors.red[500]),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: 'https://your-app.com/profile/user123',
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Отсканируйте для добавления в друзья',
              style: TextStyle(color: Colors.red[500]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A5568),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                // Добавить логику сканирования QR-кода
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Сканировать QR код'),
            ),
          ],
        ),
      ),
    );
  }
} 