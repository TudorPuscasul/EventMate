import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../widgets/event_card.dart';
import 'event_detail_screen.dart';

enum EventFilter { all, upcoming, past }
enum EventSort { dateAsc, dateDesc, title }

class EventListScreen extends StatefulWidget {
  final List<EventModel> events;
  final String title;
  final String emptyMessage;

  const EventListScreen({
    super.key,
    required this.events,
    required this.title,
    required this.emptyMessage,
  });

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  EventFilter _currentFilter = EventFilter.all;
  EventSort _currentSort = EventSort.dateAsc;

  List<EventModel> get _filteredAndSortedEvents {
    // Apply filter
    List<EventModel> filtered;
    switch (_currentFilter) {
      case EventFilter.all:
        filtered = widget.events;
        break;
      case EventFilter.upcoming:
        filtered = widget.events.where((e) => !e.isPast).toList();
        break;
      case EventFilter.past:
        filtered = widget.events.where((e) => e.isPast).toList();
        break;
    }

    // Apply sort
    switch (_currentSort) {
      case EventSort.dateAsc:
        filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        break;
      case EventSort.dateDesc:
        filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case EventSort.title:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredAndSortedEvents;

    return Column(
      children: [
        // Filter and Sort Options
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              // Filter dropdown
              Expanded(
                child: _buildFilterChip(),
              ),
              const SizedBox(width: 12),
              // Sort dropdown
              Expanded(
                child: _buildSortChip(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        
        // Event list or empty state
        Expanded(
          child: events.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    // Simulate refresh
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventCard(
                        event: event,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailScreen(
                                event: event,
                              ),
                            ),
                          ).then((_) {
                            // Refresh when coming back
                            setState(() {});
                          });
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip() {
    return InkWell(
      onTap: () => _showFilterMenu(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getFilterText(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip() {
    return InkWell(
      onTap: () => _showSortMenu(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getSortText(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  String _getFilterText() {
    switch (_currentFilter) {
      case EventFilter.all:
        return 'All Events';
      case EventFilter.upcoming:
        return 'Upcoming';
      case EventFilter.past:
        return 'Past';
    }
  }

  String _getSortText() {
    switch (_currentSort) {
      case EventSort.dateAsc:
        return 'Date ↑';
      case EventSort.dateDesc:
        return 'Date ↓';
      case EventSort.title:
        return 'Title';
    }
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Filter Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(),
            _buildFilterOption(EventFilter.all, 'All Events'),
            _buildFilterOption(EventFilter.upcoming, 'Upcoming'),
            _buildFilterOption(EventFilter.past, 'Past'),
          ],
        ),
      ),
    );
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Sort Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(),
            _buildSortOption(EventSort.dateAsc, 'Date (Earliest First)'),
            _buildSortOption(EventSort.dateDesc, 'Date (Latest First)'),
            _buildSortOption(EventSort.title, 'Title (A-Z)'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(EventFilter filter, String label) {
    final isSelected = _currentFilter == filter;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      ),
      title: Text(label),
      onTap: () {
        setState(() {
          _currentFilter = filter;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSortOption(EventSort sort, String label) {
    final isSelected = _currentSort == sort;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      ),
      title: Text(label),
      onTap: () {
        setState(() {
          _currentSort = sort;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              widget.emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
