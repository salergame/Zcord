import 'package:flutter/material.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  final List<Map<String, dynamic>> _friendRequests = [
    {
      'name': 'Александр Иванов',
      'username': '@alex_iv',
      'avatar': 'assets/avatar1.png',
      'mutualFriends': 3,
    },
    {
      'name': 'Мария Петрова',
      'username': '@maria_p',
      'avatar': 'assets/avatar2.png',
      'mutualFriends': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Заявки в друзья',
            style: TextStyle(color: Colors.red[500]),
          ),
          bottom: TabBar(
            indicatorColor: Colors.red[500],
            tabs: const [
              Tab(text: 'Входящие'),
              Tab(text: 'Исходящие'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestsList(_friendRequests),
            _buildRequestsList([]), // Пустой список для исходящих заявок
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(List<Map<String, dynamic>> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          'Нет заявок в друзья',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) => _buildRequestCard(requests[index]),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 25,
                child: Text(
                  request['name'][0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      request['username'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '${request['mutualFriends']} общих друзей',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[500],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _friendRequests.remove(request);
                    });
                  },
                  child: const Text('Принять'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _friendRequests.remove(request);
                    });
                  },
                  child: const Text('Отклонить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 