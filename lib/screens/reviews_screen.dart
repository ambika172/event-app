import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../models/event.dart';
import '../models/review.dart';
import '../services/local_storage_service.dart';

/// Event Review & Rating module (merged from day5_app "Task 1").
/// Lets the user browse, add, edit, and delete reviews for events, with
/// the same validation rules as the original build:
/// - Rating: mandatory, 1-5
/// - Review Title: required, min 5 characters
/// - Review Description: required, min 20 characters
class ReviewsScreen extends StatefulWidget {
  /// If provided, the "Add Review" flow pre-selects this event.
  final Event? initialEvent;

  const ReviewsScreen({super.key, this.initialEvent});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Review> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final reviews = await LocalStorageService.getReviews();
    if (!mounted) return;
    setState(() {
      _reviews = reviews;
      _loading = false;
    });
  }

  Future<void> _openForm({Review? existing}) async {
    final result = await Navigator.push<Review>(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewFormScreen(
          existing: existing,
          initialEvent: widget.initialEvent,
        ),
      ),
    );
    if (result != null) {
      await LocalStorageService.upsertReview(result);
      _load();
    }
  }

  Future<void> _deleteReview(Review review) async {
    await LocalStorageService.deleteReview(review.id);
    _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.darkCard,
        content: Text('Review "${review.title}" deleted',
            style: const TextStyle(color: AppTheme.textLight)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      appBar: AppBar(title: const Text('Reviews & Ratings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _reviews.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No reviews yet.\nTap the + button to write your first review.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    return _ReviewCard(
                      review: review,
                      onEdit: () => _openForm(existing: review),
                      onDelete: () => _deleteReview(review),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.rate_review_rounded),
        label: const Text('Add Review'),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.review,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(review.eventName,
                    style: const TextStyle(
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
              PopupMenuButton<String>(
                color: AppTheme.darkCard,
                icon: const Icon(Icons.more_vert, color: AppTheme.textMuted),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit', style: TextStyle(color: AppTheme.textLight)),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: AppTheme.secondary)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          _StarDisplay(rating: review.rating),
          const SizedBox(height: 10),
          Text(review.title,
              style: const TextStyle(
                  color: AppTheme.textLight, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(review.description,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.5)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: AppTheme.textMuted, size: 14),
              const SizedBox(width: 4),
              Text(review.userName,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const Spacer(),
              Text('${review.date.day}/${review.date.month}/${review.date.year}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Read-only star row used on review cards.
class _StarDisplay extends StatelessWidget {
  final int rating;
  const _StarDisplay({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: Colors.amber,
          size: 18,
        ),
      ),
    );
  }
}

/// Add/Edit form for a single review, with the Day 5 validation rules:
/// - Rating: mandatory, 1-5
/// - Review Title: required, min 5 characters
/// - Review Description: required, min 20 characters
class ReviewFormScreen extends StatefulWidget {
  final Review? existing;
  final Event? initialEvent;
  const ReviewFormScreen({super.key, this.existing, this.initialEvent});

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _bookingIdController;
  late final TextEditingController _userNameController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  String? _selectedEventName;
  int _rating = 0;
  late DateTime _reviewDate;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _bookingIdController = TextEditingController(text: existing?.bookingId ?? '');
    _userNameController = TextEditingController(text: existing?.userName ?? '');
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController =
        TextEditingController(text: existing?.description ?? '');
    _selectedEventName = existing?.eventName ??
        widget.initialEvent?.name ??
        (sampleEvents.isNotEmpty ? sampleEvents.first.name : null);
    _rating = existing?.rating ?? 0;
    _reviewDate = existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _bookingIdController.dispose();
    _userNameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _reviewDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.darkCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _reviewDate = picked);
  }

  void _submit() {
    final formValid = _formKey.currentState!.validate();
    if (!formValid || _rating < 1 || _rating > 5) {
      if (_rating < 1) {
        // Force the rating FormField to show its error too.
        setState(() {});
      }
      return;
    }

    final review = Review(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      bookingId: _bookingIdController.text.trim(),
      eventName: _selectedEventName!,
      userName: _userNameController.text.trim(),
      rating: _rating,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _reviewDate,
    );

    Navigator.pop(context, review);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      appBar: AppBar(title: Text(_isEditing ? 'Edit Review' : 'Add Review')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _bookingIdController,
              style: const TextStyle(color: AppTheme.textLight),
              decoration: const InputDecoration(labelText: 'Booking ID'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Booking ID cannot be empty'
                  : null,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _selectedEventName,
              dropdownColor: AppTheme.darkCard,
              style: const TextStyle(color: AppTheme.textLight),
              decoration: const InputDecoration(labelText: 'Event Name'),
              items: sampleEvents
                  .map((e) => DropdownMenuItem(value: e.name, child: Text(e.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedEventName = v),
              validator: (v) => v == null ? 'Please select an event' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _userNameController,
              style: const TextStyle(color: AppTheme.textLight),
              decoration: const InputDecoration(labelText: 'User Name'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'User name is required'
                  : null,
            ),
            const SizedBox(height: 16),

            // Rating (1-5 stars) — mandatory, validated via FormField<int>.
            FormField<int>(
              initialValue: _rating,
              validator: (value) {
                if (value == null || value < 1 || value > 5) {
                  return 'Please select a rating between 1 and 5';
                }
                return null;
              },
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rating',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: AppTheme.textLight)),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (i) {
                        final filled = i < _rating;
                        return IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            filled ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() => _rating = i + 1);
                            state.didChange(_rating);
                          },
                        );
                      }),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          state.errorText!,
                          style: const TextStyle(color: AppTheme.secondary, fontSize: 12),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: AppTheme.textLight),
              decoration: const InputDecoration(labelText: 'Review Title'),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Review title cannot be empty';
                if (value.length < 5) {
                  return 'Review title must be at least 5 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: AppTheme.textLight),
              decoration: const InputDecoration(labelText: 'Review Description'),
              maxLines: 4,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Review description cannot be empty';
                if (value.length < 20) {
                  return 'Review description must be at least 20 characters '
                      '(${value.length}/20)';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Review Date',
                  suffixIcon: Icon(Icons.calendar_today, color: AppTheme.textMuted),
                ),
                child: Text(
                  '${_reviewDate.day}/${_reviewDate.month}/${_reviewDate.year}',
                  style: const TextStyle(color: AppTheme.textLight),
                ),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _submit,
              child: Text(_isEditing ? 'Update Review' : 'Add Review'),
            ),
          ],
        ),
      ),
    );
  }
}
