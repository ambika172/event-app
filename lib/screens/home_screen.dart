import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/event.dart';
import '../models/app_theme.dart';
import 'event_details_screen.dart';
import 'event_listing_screen.dart';
import 'login_screen.dart';
import 'booking_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _carouselIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All', 'Music', 'Sports', 'Technology',
    'Business', 'Education', 'Entertainment',
  ];

  final Map<String, IconData> _categoryIcons = {
    'All': Icons.apps_rounded,
    'Music': Icons.music_note_rounded,
    'Sports': Icons.sports_soccer_rounded,
    'Technology': Icons.computer_rounded,
    'Business': Icons.business_center_rounded,
    'Education': Icons.school_rounded,
    'Entertainment': Icons.movie_rounded,
  };

  List<Event> get featuredEvents =>
      sampleEvents.where((e) => e.isFeatured).toList();

  List<Event> get displayedEvents {
    if (_selectedCategory == 'All') return sampleEvents;
    return sampleEvents.where((e) => e.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AppBar ──────────────────────────────────────────
            _buildAppBar(context),

            // ── Hero Banner / Carousel ──────────────────────────
            _buildHeroBanner(),

            const SizedBox(height: 28),

            // ── Featured Events ─────────────────────────────────
            _buildSectionHeader('Featured Events', onSeeAll: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EventListingScreen()));
            }),
            const SizedBox(height: 14),
            _buildFeaturedEvents(),

            const SizedBox(height: 28),

            // ── Categories ──────────────────────────────────────
            _buildSectionHeader('Browse Categories'),
            const SizedBox(height: 14),
            _buildCategories(),

            const SizedBox(height: 24),

            // ── Filtered Events ─────────────────────────────────
            _buildEventGrid(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            // Logo + Name
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('E',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EventHub',
                    style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                Text('Discover experiences',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
            const Spacer(),
            // Search Icon
            IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EventListingScreen()));
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.search_rounded, color: AppTheme.textLight, size: 20),
              ),
            ),
            // My Bookings Icon
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingManagementScreen()),
                );
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_seat_rounded,
                    color: AppTheme.textLight, size: 20),
              ),
            ),
            // Notification Icon
            IconButton(
              onPressed: () {},
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_rounded,
                    color: AppTheme.textLight, size: 20),
              ),
            ),
            // Logout Icon
            IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppTheme.textLight, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: featuredEvents.length,
          options: CarouselOptions(
            height: 230,
            viewportFraction: 0.9,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 700),
            enlargeCenterPage: true,
            onPageChanged: (index, _) => setState(() => _carouselIndex = index),
          ),
          itemBuilder: (context, index, _) {
            final event = featuredEvents[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EventDetailsScreen(event: event)),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'event_image_${event.id}',
                        child: Image.network(
                          event.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                                gradient: AppTheme.heroGradient),
                          ),
                        ),
                      ),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      // Event Info
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(event.category,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 6),
                            Text(event.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.white70, size: 12),
                                const SizedBox(width: 4),
                                Text(event.date,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                                const SizedBox(width: 12),
                                const Icon(Icons.location_on,
                                    color: Colors.white70, size: 12),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(event.location,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Page Indicator
        AnimatedSmoothIndicator(
          activeIndex: _carouselIndex,
          count: featuredEvents.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: AppTheme.primary,
            dotColor: AppTheme.darkCard,
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All',
                  style: TextStyle(color: AppTheme.primary, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedEvents() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: featuredEvents.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final event = featuredEvents[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EventDetailsScreen(event: event)),
            ),
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.darkCard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      event.imageUrl,
                      height: 110,
                      width: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 110,
                        decoration:
                            BoxDecoration(gradient: AppTheme.heroGradient),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.name,
                            style: const TextStyle(
                                color: AppTheme.textLight,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: AppTheme.textMuted, size: 11),
                            const SizedBox(width: 4),
                            Text(event.date,
                                style: const TextStyle(
                                    color: AppTheme.textMuted, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.isFree
                              ? 'FREE'
                              : '₹${event.price.toStringAsFixed(0)}',
                          style: TextStyle(
                              color: event.isFree
                                  ? AppTheme.accent
                                  : AppTheme.secondary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 76,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(0.2)
                    : AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _categoryIcons[cat] ?? Icons.category,
                    color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventGrid() {
    final events = displayedEvents;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedCategory == 'All' ? 'All Events' : '$_selectedCategory Events',
            style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          if (events.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('No events in this category',
                    style: TextStyle(color: AppTheme.textMuted)),
              ),
            )
          else
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EventDetailsScreen(event: event)),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Stack(
                            children: [
                              Image.network(
                                event.imageUrl,
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 110,
                                  decoration: BoxDecoration(
                                      gradient: AppTheme.heroGradient),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: event.isFree
                                        ? AppTheme.accent
                                        : AppTheme.secondary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    event.isFree
                                        ? 'FREE'
                                        : '₹${event.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.name,
                                  style: const TextStyle(
                                      color: AppTheme.textLight,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: Colors.amber, size: 12),
                                  const SizedBox(width: 2),
                                  Text(event.rating.toString(),
                                      style: const TextStyle(
                                          color: Colors.amber, fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      color: AppTheme.textMuted, size: 11),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(event.date,
                                        style: const TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: 10),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
