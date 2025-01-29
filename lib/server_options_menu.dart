import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/server_overview_page.dart';
import 'pages/server_members_page.dart';
import 'pages/server_roles_page.dart';
import 'pages/server_ban_list_page.dart';

class ServerOptionsMenu extends StatefulWidget {
  final String serverId;
  final String serverName;
  final String ownerId;

  const ServerOptionsMenu({
    super.key,
    required this.serverId,
    required this.serverName,
    required this.ownerId,
  });

  @override
  State<ServerOptionsMenu> createState() => _ServerOptionsMenuState();
}

class _ServerOptionsMenuState extends State<ServerOptionsMenu> {
  bool get isOwner => FirebaseAuth.instance.currentUser?.uid == widget.ownerId;

  Future<void> _deleteServer() async {
    try {
      await FirebaseFirestore.instance
          .collection('servers')
          .doc(widget.serverId)
          .delete();
          
      // Navigate back to home page
      if (mounted) {
        // Pop all routes and go back to home
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error deleting server: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Delete Server',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${widget.serverName}? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog first
              await _deleteServer(); // Then delete and redirect
            },
            child: const Text(
              'Delete Server',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3748),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a202c),
        title: Text(widget.serverName),
      ),
      body: ListView(
        children: [
          if (isOwner) ...[
            const _SectionHeader(title: 'SERVER SETTINGS'),
            _OptionTile(
              icon: Icons.edit,
              title: 'Server Overview',
              onTap: () => _showServerOverview(context),
            ),
            _OptionTile(
              icon: Icons.people,
              title: 'Members',
              onTap: () => _showMembers(context),
            ),
            _OptionTile(
              icon: Icons.settings,
              title: 'Roles',
              onTap: () => _showRoles(context),
            ),
          ],
          const _SectionHeader(title: 'USER MANAGEMENT'),
          _OptionTile(
            icon: Icons.person_add,
            title: 'Invite People',
            onTap: () => _showInviteDialog(context),
          ),
          if (isOwner) ...[
            _OptionTile(
              icon: Icons.block,
              title: 'Ban List',
              onTap: () => _showBanList(context),
            ),
          ],
          const _SectionDivider(),
          if (isOwner) ...[
            _OptionTile(
              icon: Icons.delete_forever,
              title: 'Delete Server',
              textColor: Colors.red,
              onTap: () => _showDeleteConfirmation(widget.serverId),
            ),
          ] else ...[
            _OptionTile(
              icon: Icons.exit_to_app,
              title: 'Leave Server',
              textColor: Colors.red,
              onTap: () => _showLeaveServerDialog(context),
            ),
          ],
        ],
      ),
    );
  }

  void _showServerOverview(BuildContext context) {
    // Implement server overview editing
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServerOverviewPage(serverId: widget.serverId),
      ),
    );
  }

  void _showMembers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServerMembersPage(serverId: widget.serverId),
      ),
    );
  }

  void _showRoles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServerRolesPage(serverId: widget.serverId),
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Invite People',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share this link with others to invite them:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1a202c),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'server-invite-link/${widget.serverId}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white),
                    onPressed: () {
                      // Implement copy to clipboard
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBanList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServerBanListPage(serverId: widget.serverId),
      ),
    );
  }

  void _showLeaveServerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Leave Server',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to leave ${widget.serverName}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _leaveServer();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: const Text(
              'Leave Server',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveServer() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('servers')
            .doc(widget.serverId)
            .update({
          'members': FieldValue.arrayRemove([currentUser.uid]),
        });
      }
    } catch (e) {
      print('Error leaving server: $e');
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Color(0xFF4A5568),
      height: 32,
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.white),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.white),
      ),
      onTap: onTap,
    );
  }
} 