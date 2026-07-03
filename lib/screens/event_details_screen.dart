import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/app_theme.dart';
import '../services/local_storage_service.dart';
import 'booking_management_screen.dart';
import 'reviews_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Event get event => widget.event;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final ids = await LocalStorageService.getFavoriteIds();
    if (!mounted) return;
    setState(() => _isFavorite = ids.contains(event.id));
  }

  Future<void> _toggleFavorite() async {
    final updated = _isFavorite
        ? await LocalStorageService.removeFavorite(event.id, event.name)
        : await LocalStorageService.addFavorite(event.id, event.name);
    if (!mounted) return;
    setState(() => _isFavorite = updated.contains(event.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.darkCard,
        duration: const Duration(seconds: 1),
        content: Text(
          _isFavorite
              ? '${event.name} added to favorites'
              : '${event.name} removed from favorites',
          style: const TextStyle(color: AppTheme.textLight),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      body: CustomScrollView(
        slivers: [
          // Hero Banner + AppBar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.dark,
            actions: [
              IconButton(
                onPressed: _toggleFavorite,
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _isFavorite ? AppTheme.secondary : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'event_image_${event.id}',
                    child: Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(gradient: AppTheme.heroGradient),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(gradient: AppTheme.cardOverlayGradient),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge + Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CategoryBadge(category: event.category),
                      _RatingBadge(rating: event.rating),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Event Name
                  Text(
                    event.name,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today_rounded,
                          label: 'Date',
                          value: event.date,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.access_time_rounded,
                          label: 'Time',
                          value: event.time,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.location_on_rounded,
                          label: 'Location',
                          value: event.location,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.event_seat_rounded,
                          label: 'Seats Left',
                          value: '${event.availableSeats}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Venue
                  _SectionTitle('Venue'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place_rounded, color: AppTheme.secondary, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.venue,
                                style: const TextStyle(
                                    color: AppTheme.textLight,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Text(event.location,
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Organizer
                  _SectionTitle('Organizer'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primary.withOpacity(0.2),
                          child: const Icon(Icons.business_rounded, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.organizer,
                                style: const TextStyle(
                                    color: AppTheme.textLight,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            const Text('Event Organizer',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  _SectionTitle('About this Event'),
                  const SizedBox(height: 8),
                  Text(
                    event.fullDescription,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Schedule
                  _SectionTitle('Event Schedule'),
                  const SizedBox(height: 8),
                  ...event.schedule.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ),
                              ),
                              if (i < event.schedule.length - 1)
                                Container(
                                    width: 2,
                                    height: 24,
                                    color: AppTheme.primary.withOpacity(0.2)),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                item,
                                style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Photo Gallery
                  if (event.galleryImages.length > 1) ...[
                    _SectionTitle('Photo Gallery'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: event.galleryImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              event.galleryImages[index],
                              width: 150,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 150,
                                height: 110,
                                color: AppTheme.darkCard,
                                child: const Icon(Icons.image, color: AppTheme.textMuted),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Reviews & Ratings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionTitle('Reviews & Ratings'),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewFormScreen(initialEvent: event),
                            ),
                          );
                        },
                        icon: const Icon(Icons.rate_review_rounded,
                            color: AppTheme.primary, size: 18),
                        label: const Text('Write a review',
                            style: TextStyle(color: AppTheme.primary)),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewsScreen(initialEvent: event),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('See all reviews for this event →',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location Map Placeholder
                  _SectionTitle('Location Map'),
                  const SizedBox(height: 8),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Opacity(
                            opacity: 0.3,
                            child: Image.network(
                              'https://maps.googleapis.com/maps/api/staticmap?center=${Uri.encodeComponent(event.location)}&zoom=13&size=600x300&maptype=roadmap',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: AppTheme.secondary, size: 40),
                            const SizedBox(height: 8),
                            Text(event.venue,
                                style: const TextStyle(
                                    color: AppTheme.textLight, fontWeight: FontWeight.bold)),
                            Text(event.location,
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),

      // Book Now Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: AppTheme.dark,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ticket Price', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                Text(
                  event.isFree ? 'FREE' : '₹${event.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: AppTheme.accent, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BookingManagementScreen(initialEventName: event.name),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Book Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                Text(value,
                    style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
      ),
      child: Text(category,
          style: const TextStyle(
              color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(rating.toString(),
              style: const TextStyle(
                  color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
