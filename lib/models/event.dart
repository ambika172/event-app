class Event {
  final String id;
  final String name;
  final String category;
  final String date;
  final String time;
  final String location;
  final String venue;
  final double price;
  final double rating;
  final String description;
  final String fullDescription;
  final String imageUrl;
  final List<String> galleryImages;
  final String organizer;
  final int availableSeats;
  final List<String> schedule;
  final bool isFeatured;

  Event({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.venue,
    required this.price,
    required this.rating,
    required this.description,
    required this.fullDescription,
    required this.imageUrl,
    required this.galleryImages,
    required this.organizer,
    required this.availableSeats,
    required this.schedule,
    required this.isFeatured,
  });

  bool get isFree => price == 0;
}

final List<Event> sampleEvents = [
  Event(
    id: '1',
    name: 'Global Tech Summit 2025',
    category: 'Technology',
    date: 'Jul 15, 2025',
    time: '9:00 AM',
    location: 'San Francisco, CA',
    venue: 'Moscone Center',
    price: 299,
    rating: 4.8,
    description: 'The biggest tech conference of the year featuring top innovators.',
    fullDescription:
        'Join thousands of tech enthusiasts, developers, and industry leaders at the Global Tech Summit 2025. Explore cutting-edge innovations, attend hands-on workshops, and network with the brightest minds in technology. Featuring keynotes from CEOs of leading tech companies, breakout sessions on AI, blockchain, and cloud computing.',
    imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
    galleryImages: [
      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
      'https://images.unsplash.com/photo-1591115765373-5207764f72e7?w=400',
      'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=400',
    ],
    organizer: 'TechWorld Inc.',
    availableSeats: 250,
    schedule: [
      '9:00 AM - Opening Keynote',
      '11:00 AM - AI Panel Discussion',
      '1:00 PM - Lunch Break',
      '2:00 PM - Workshop Sessions',
      '5:00 PM - Networking Mixer',
    ],
    isFeatured: true,
  ),
  Event(
    id: '2',
    name: 'Summer Music Festival',
    category: 'Music',
    date: 'Aug 3, 2025',
    time: '4:00 PM',
    location: 'Austin, TX',
    venue: 'Zilker Park',
    price: 150,
    rating: 4.9,
    description: 'Three days of live music across multiple stages with top artists.',
    fullDescription:
        'The Summer Music Festival returns bigger than ever! Enjoy three days of non-stop live performances across 5 stages featuring over 50 artists. From indie rock to electronic, jazz to country — there\'s something for everyone. Plus, amazing food vendors, art installations, and activities for the whole family.',
    imageUrl: 'https://images.unsplash.com/photo-1501386761578-eaa54b7cb82c?w=800',
    galleryImages: [
      'https://images.unsplash.com/photo-1501386761578-eaa54b7cb82c?w=400',
      'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400',
      'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400',
    ],
    organizer: 'Live Nation Events',
    availableSeats: 5000,
    schedule: [
      '4:00 PM - Gates Open',
      '5:00 PM - Opening Acts',
      '7:00 PM - Main Stage Performances',
      '10:00 PM - Headline Act',
      '11:59 PM - Finale',
    ],
    isFeatured: true,
  ),
  Event(
    id: '3',
    name: 'City Marathon 2025',
    category: 'Sports',
    date: 'Sep 21, 2025',
    time: '6:00 AM',
    location: 'New York, NY',
    venue: 'Central Park',
    price: 75,
    rating: 4.7,
    description: 'Annual city marathon through iconic New York streets.',
    fullDescription:
        'Challenge yourself at the City Marathon 2025! Run through the iconic streets of New York, from the Brooklyn Bridge to Central Park. This world-class event welcomes runners of all levels — from elite athletes to first-time marathoners. All finishers receive a medal and commemorative t-shirt.',
    imageUrl: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800',
    galleryImages: [
      'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=400',
      'https://images.unsplash.com/photo-1568196290758-5c38034d539e?w=400',
    ],
    organizer: 'NYC Road Runners',
    availableSeats: 500,
    schedule: [
      '6:00 AM - Start Line Opens',
      '7:00 AM - Race Begins',
      '12:00 PM - Awards Ceremony',
      '2:00 PM - Closing',
    ],
    isFeatured: true,
  ),
  Event(
    id: '4',
    name: 'Business Leadership Forum',
    category: 'Business',
    date: 'Oct 5, 2025',
    time: '8:30 AM',
    location: 'Chicago, IL',
    venue: 'McCormick Place',
    price: 499,
    rating: 4.6,
    description: 'Connect with top executives and learn future business strategies.',
    fullDescription:
        'The Business Leadership Forum brings together C-suite executives, entrepreneurs, and business leaders from around the globe. Learn about the latest trends in management, sustainability, digital transformation, and global markets. Exclusive networking dinners and one-on-one mentorship sessions included.',
    imageUrl: 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=800',
    galleryImages: [
      'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=400',
      'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=400',
    ],
    organizer: 'Forbes Events',
    availableSeats: 120,
    schedule: [
      '8:30 AM - Registration & Breakfast',
      '9:30 AM - Keynote Address',
      '11:00 AM - Panel: Future of Work',
      '1:00 PM - Lunch & Networking',
      '3:00 PM - Breakout Sessions',
    ],
    isFeatured: false,
  ),
  Event(
    id: '5',
    name: 'Flutter Dev Workshop',
    category: 'Education',
    date: 'Jul 28, 2025',
    time: '10:00 AM',
    location: 'Remote / Online',
    venue: 'Virtual Event',
    price: 0,
    rating: 4.5,
    description: 'Free hands-on workshop to master Flutter development.',
    fullDescription:
        'Join this free intensive Flutter workshop designed for beginners and intermediate developers. Learn to build beautiful cross-platform apps from scratch. Topics include widgets, state management, navigation, API integration, and deployment to both Android and iOS. Certificate of completion provided.',
    imageUrl: 'https://images.unsplash.com/photo-1517180102446-f3ece451e9d8?w=800',
    galleryImages: [
      'https://images.unsplash.com/photo-1517180102446-f3ece451e9d8?w=400',
    ],
    organizer: 'Google Developers',
    availableSeats: 1000,
    schedule: [
      '10:00 AM - Intro to Flutter',
      '11:30 AM - Building Your First App',
      '1:00 PM - Break',
      '2:00 PM - State Management',
      '4:00 PM - Q&A Session',
    ],
    isFeatured: false,
  ),
  Event(
    id: '6',
    name: 'Comedy Night Live',
    category: 'Entertainment',
    date: 'Jul 20, 2025',
    time: '7:30 PM',
    location: 'Los Angeles, CA',
    venue: 'The Laugh Factory',
    price: 45,
    rating: 4.8,
    description: 'An unforgettable evening with top stand-up comedians.',
    fullDescription:
        'Get ready to laugh all night! Comedy Night Live brings together five of the hottest stand-up comedians for an unforgettable evening of humor, wit, and entertainment. Enjoy two hours of non-stop laughs followed by a meet-and-greet with the performers. Drinks and snacks available at the venue.',
    imageUrl: 'https://images.unsplash.com/photo-1585699324551-f6c309eedeca?w=800',
    galleryImages: [
      'https://images.unsplash.com/photo-1585699324551-f6c309eedeca?w=400',
    ],
    organizer: 'Laugh Factory Productions',
    availableSeats: 200,
    schedule: [
      '7:30 PM - Doors Open',
      '8:00 PM - Opening Act',
      '8:30 PM - Main Show',
      '10:00 PM - Meet & Greet',
    ],
    isFeatured: false,
  ),
];
