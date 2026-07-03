import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../models/event.dart';
import '../models/favorite.dart';
import '../services/local_storage_service.dart';
import 'event_details_screen.dart';

/// Favorites module (merged from day5_app "Task 2: Event Favorites Module").
/// Lets the user browse all events, toggle favorites, and review their
/// favorite history log — all backed by [LocalStorageService].
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Set<String> _favoriteIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final ids = await LocalStorageService.getFavoriteIds();
    if (!mounted) return;
    setState(() {
      _favoriteIds = ids;
      _loading = false;
    });
  }

  Future<void> _toggleFavorite(Event event) async {
    final isFavorite = _favoriteIds.contains(event.id);
    final updated = isFavorite
        ? await LocalStorageService.removeFavorite(event.id, event.name)
        : await LocalStorageService.addFavorite(event.id, event.name);
    if (!mounted) return;
    setState(() => _favoriteIds = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.darkCard,
        content: Text(
          isFavorite
              ? '${event.name} removed from favorites'
              : '${event.name} added to favorites',
          style: const TextStyle(color: AppTheme.textLight),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      appBar: AppBar(
        title: const Text('Favorites'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.textLight,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'All Events'),
            Tab(text: 'My Favorites'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _AllEventsTab(
                  favoriteIds: _favoriteIds,
                  onToggleFavorite: _toggleFavorite,
                ),
                _FavoritesListTab(
                  favoriteIds: _favoriteIds,
                  onRemoveFavorite: _toggleFavorite,
                ),
                _FavoriteHistoryTab(favoriteIds: _favoriteIds),
              ],
            ),
    );
  }
}

class _AllEventsTab extends StatelessWidget {
  final Set<String> favoriteIds;
  final ValueChanged<Event> onToggleFavorite;

  const _AllEventsTab({
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sampleEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final event = sampleEvents[index];
        final isFavorite = favoriteIds.contains(event.id);
        return _EventFavoriteCard(
          event: event,
          isFavorite: isFavorite,
          onToggleFavorite: () => onToggleFavorite(event),
        );
      },
    );
  }
}

class _FavoritesListTab extends StatelessWidget {
  final Set<String> favoriteIds;
  final ValueChanged<Event> onRemoveFavorite;

  const _FavoritesListTab({
    required this.favoriteIds,
    required this.onRemoveFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteEvents =
        sampleEvents.where((e) => favoriteIds.contains(e.id)).toList();

    if (favoriteEvents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No favorites yet.\nTap the heart icon on any event to add it here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final event = favoriteEvents[index];
        return _EventFavoriteCard(
          event: event,
          isFavorite: true,
          onToggleFavorite: () => onRemoveFavorite(event),
        );
      },
    );
  }
}

class _EventFavoriteCard extends StatelessWidget {
  final Event event;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _EventFavoriteCard({
    required this.event,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            event.imageUrl,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(gradient: AppTheme.heroGradient),
            ),
          ),
        ),
        title: Text(event.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppTheme.textLight, fontWeight: FontWeight.bold)),
        subtitle: Text('${event.category} • ${event.date}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? AppTheme.secondary : AppTheme.textMuted,
          ),
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          onPressed: onToggleFavorite,
        ),
      ),
    );
  }
}

class _FavoriteHistoryTab extends StatefulWidget {
  final Set<String> favoriteIds;
  const _FavoriteHistoryTab({required this.favoriteIds});

  @override
  State<_FavoriteHistoryTab> createState() => _FavoriteHistoryTabState();
}

class _FavoriteHistoryTabState extends State<_FavoriteHistoryTab> {
  List<FavoriteHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _FavoriteHistoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favoriteIds != widget.favoriteIds) _load();
  }

  Future<void> _load() async {
    final history = await LocalStorageService.getFavoriteHistory();
    if (!mounted) return;
    setState(() => _history = history);
  }

  String _formatTimestamp(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    if (_history.isEmpty) {
      return const Center(
        child: Text('No favorite activity yet.',
            style: TextStyle(color: AppTheme.textMuted)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = _history[index];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            dense: true,
            leading: Icon(
              entry.action == 'added' ? Icons.add_circle : Icons.remove_circle,
              color: entry.action == 'added' ? AppTheme.accent : AppTheme.textMuted,
            ),
            title: Text(entry.eventName,
                style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
            subtitle: Text(
              entry.action == 'added' ? 'Added to favorites' : 'Removed from favorites',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            trailing: Text(
              _formatTimestamp(entry.timestamp),
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ),
        );
      },
    );
  }
}
