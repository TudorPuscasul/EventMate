import 'package:flutter/material.dart';
import '../../utils/mock_data.dart';
import '../events/event_list_screen.dart';
import '../events/create_event_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    EventListScreen(
      events: MockData.getEventsCreatedByUser(MockData.currentUser.id),
      title: 'My Events',
      emptyMessage: 'You haven\'t created any events yet',
    ),
    EventListScreen(
      events: MockData.getEventsUserInvitedTo(MockData.currentUser.id),
      title: 'Invitations',
      emptyMessage: 'You don\'t have any invitations',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'My Events' : 'Invitations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              _showProfileDialog();
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'My Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Invitations',
          ),
        ],
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEventScreen(),
            ),
          ).then((_) {
            setState(() {});
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                MockData.currentUser.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              MockData.currentUser.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              MockData.currentUser.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Events Created'),
              trailing: Text(
                '${MockData.getEventsCreatedByUser(MockData.currentUser.id).length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Invitations'),
              trailing: Text(
                '${MockData.getEventsUserInvitedTo(MockData.currentUser.id).length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
