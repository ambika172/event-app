import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/app_theme.dart';
import 'event_details_screen.dart';

class EventListingScreen extends StatefulWidget {
  const EventListingScreen({super.key});

  @override
  State<EventListingScreen> createState() => _EventListingScreenState();
}

class _EventListingScreenState extends State<EventListingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All', 'Music', 'Sports', 'Technology',
    'Business', 'Education', 'Entertainment', 'Free Events', 'Paid Events',
  ];

  List<Event> get filteredEvents {
    return sampleEvents.where((event) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          event.name.toLowerCase().contains(query) ||
          event.category.toLowerCase().contains(query) ||
          event.location.toLowerCase().contains(query) ||
          event.organizer.toLowerCase().contains(query);

      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Free Events' && event.isFree) ||
          (_selectedFilter == 'Paid Events' && !event.isFree) ||
          event.category == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final events = filteredEvents;

    return Scaffold(
      backgroundColor: AppTheme.dark,
      appBar: AppBar(
        title: const Text('All Events'),
        backgroundColor: AppTheme.dark,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: AppTheme.textLight),
              decoration: InputDecoration(
                hintText: 'Search by name, category, location...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.darkCard,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${events.length} event${events.length != 1 ? 's' : ''} found',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Event List
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, color: AppTheme.textMuted, size: 60),
                        SizedBox(height: 12),
                        Text('No events found',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) =>
                        _EventCard(event: events[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailsScreen(event: event),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Hero(
                    tag: 'event_image_${event.id}',
                    child: Image.network(
                      event.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        decoration: BoxDecoration(gradient: AppTheme.heroGradient),
                        child: const Center(
                            child: Icon(Icons.image, color: Colors.white54, size: 40)),
                      ),
                    ),
                  ),
                  // Price Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: event.isFree ? AppTheme.accent : AppTheme.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.isFree ? 'FREE' : '₹${event.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(event.category,
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 3),
                          Text(event.rating.toString(),
                              style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Name
                  Text(
                    event.name,
                    style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Date & Location
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppTheme.textMuted, size: 13),
                      const SizedBox(width: 5),
                      Text(event.date,
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 12)),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on_rounded,
                          color: AppTheme.textMuted, size: 13),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    event.description,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),

                  // View Details Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EventDetailsScreen(event: event)),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('View Details',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
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
