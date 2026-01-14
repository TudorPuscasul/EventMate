import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../events/event_list_screen.dart';
import '../events/create_event_screen.dart';
import '../../services/event_service.dart';
import '../../services/profile_cache_service.dart';
import '../../bloc/connectivity/connectivity.dart';
import '../../bloc/auth/auth.dart';
import '../../bloc/sync/sync.dart';
import '../../models/event_model.dart';
import '../../widgets/offline_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final EventService _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'My Events' : 'Invitations'),
        actions: [
          BlocBuilder<SyncCubit, SyncState>(
            builder: (context, syncState) {
              return IconButton(
                icon: syncState.isSyncing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh),
                onPressed: syncState.isSyncing
                    ? null
                    : () async {
                        await context.read<SyncCubit>().triggerSync();
                        if (mounted) setState(() {}); // Refresh streams
                      },
                tooltip: syncState.lastSyncText,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              _showProfileDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: _currentIndex == 0
                ? _buildMyEventsTab()
                : _buildInvitationsTab(),
          ),
        ],
      ),
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEventScreen(),
            ),
          );
          // Trigger rebuild to refresh stream data
          if (mounted) {
            setState(() {});
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }

  Widget _buildMyEventsTab() {
    return StreamBuilder<List<EventModel>>(
      stream: _eventService.getMyEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data ?? [];
        return EventListScreen(
          events: events,
          title: 'My Events',
          emptyMessage: 'You haven\'t created any events yet',
        );
      },
    );
  }

  Widget _buildInvitationsTab() {
    return StreamBuilder<List<EventModel>>(
      stream: _eventService.getInvitedEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data ?? [];
        return EventListScreen(
          events: events,
          title: 'Invitations',
          emptyMessage: 'You don\'t have any invitations',
        );
      },
    );
  }

  void _showProfileDialog() async {
    final authBloc = context.read<AuthBloc>();
    final isOnline = context.read<ConnectivityCubit>().state.isOnline;

    final user = authBloc.currentUser;
    String userName = user?.displayName ?? 'User';
    String userEmail = user?.email ?? '';

    // If offline and Firebase user data is incomplete, try cached data
    if (!isOnline || userName == 'User' || userEmail.isEmpty) {
      final cacheService = ProfileCacheService();
      final cachedProfile = await cacheService.getCachedProfile();

      userName = cachedProfile['displayName'] ?? userName;
      userEmail = cachedProfile['email'] ?? userEmail;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Text('Profile'),
            const Spacer(),
            if (!isOnline)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Cached',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(dialogContext).primaryColor,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userEmail,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.red)),
              contentPadding: EdgeInsets.zero,
              enabled: isOnline,
              onTap: isOnline
                  ? () {
                      Navigator.pop(dialogContext); // Close dialog
                      context.read<AuthBloc>().add(const AuthSignOutRequested());
                      // Navigation handled by AuthWrapper
                    }
                  : null,
            ),
            if (!isOnline)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Logout disabled while offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
