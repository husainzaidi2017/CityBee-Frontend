import '../../domain/models/app_category.dart';
import '../../domain/models/city.dart';
import '../../domain/models/user_profile.dart';

/// Deterministic placeholder image URLs for the mock-data phase.
/// Swapped for Supabase Storage URLs when the backend is connected.
String mockImage(String seed, {int w = 800, int h = 560}) =>
    'https://picsum.photos/seed/$seed/$w/$h';

/// Preset avatars offered in the Edit Profile screen.
const mockAvatarChoices = <String>[
  'https://picsum.photos/seed/localgo-avatar/200/200',
  'https://picsum.photos/seed/citybee-avatar-2/200/200',
  'https://picsum.photos/seed/citybee-avatar-3/200/200',
  'https://picsum.photos/seed/citybee-avatar-4/200/200',
  'https://picsum.photos/seed/citybee-avatar-5/200/200',
  'https://picsum.photos/seed/citybee-avatar-6/200/200',
];

/// ── Cities ───────────────────────────────────────────────────────────────
const mockCities = <City>[
  City(
    id: 'moradabad',
    name: 'Moradabad',
    state: 'Uttar Pradesh',
    nickname: 'Peetal Nagri',
    defaultArea: 'Civil Lines, Moradabad',
    latitude: 28.8386,
    longitude: 78.7733,
  ),
  City(
    id: 'bareilly',
    name: 'Bareilly',
    state: 'Uttar Pradesh',
    nickname: 'Nath Nagri',
    defaultArea: 'Cantt, Bareilly',
    latitude: 28.3670,
    longitude: 79.4304,
  ),
  City(
    id: 'rampur',
    name: 'Rampur',
    state: 'Uttar Pradesh',
    nickname: 'City of Libraries',
    defaultArea: 'Civil Lines, Rampur',
    latitude: 28.8082,
    longitude: 79.0253,
  ),
];

/// ── Categories (Explore Near You grid) ───────────────────────────────────
const mockCategories = <AppCategory>[
  AppCategory(id: 'fashion', name: 'Fashion', listingTitle: 'Fashion & Shopping'),
  AppCategory(id: 'shops', name: 'Shops', listingTitle: 'Shops & Stores'),
  AppCategory(id: 'dining', name: 'Food & Dining', listingTitle: 'Restaurants & Dining'),
  AppCategory(id: 'doctors', name: 'Doctors', listingTitle: 'Doctors & Clinics'),
  AppCategory(id: 'hotels', name: 'Hotels', listingTitle: 'Hotels & Stays'),
  AppCategory(id: 'barbers', name: 'Barbers', listingTitle: 'Barbers & Grooming'),
  AppCategory(id: 'heritage', name: 'Heritage', listingTitle: 'Heritage & Culture'),
  AppCategory(id: 'salons', name: 'Salons', listingTitle: 'Beauty & Salons'),
  AppCategory(id: 'malls', name: 'Malls', listingTitle: 'Malls & Markets'),
  AppCategory(id: 'cinemas', name: 'Cinemas', listingTitle: 'Cinemas Open Now'),
];

/// ── Home quick chips under the search bar ────────────────────────────────
const homeQuickChips = <String>[
  '⚡ Lightning Deals',
  'Cinemas Open',
  'Biryani & Food',
];

/// ── Signed-in profile (mock until Supabase Auth is wired) ───────────────
const mockProfile = UserProfile(
  name: 'Amit Sharma',
  handle: '@amit.moradabad',
  email: 'amit.sharma@example.com',
  phone: '+91 98765 43210',
  levelTitle: 'Level 3 Pioneer',
  topPercent: 'Top 5% Saver',
  savedAmount: '₹2,450',
  bookmarkCount: 12,
  reviewsGiven: 5,
  avatarImage: 'https://picsum.photos/seed/localgo-avatar/200/200',
);

/// ── City savings footer on the Offers screen ────────────────────────────
const mockCommunityStats = (
  saved: '₹6.8 Lakhs',
  headline: 'Moradabad Saved',
  subline: 'Join CityBee to unlock deals & city savings.',
  cta: 'Claim Your First Deal',
);
