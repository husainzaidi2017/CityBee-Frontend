import '../../domain/models/place.dart';

final mockPlaces = <Place>[
  Place(
    id: 'peetal-bazaar',
    name: 'Peetal Bazaar Artisan Market',
    image: 'https://picsum.photos/seed/localgo-peetalbazaar/1000/640',
    metaLine: '18 min · Free · Must Visit',
    description:
        'Discover centuries-old brass workshops & artisan lanes. Perfect '
        'half-day walk through the heart of Peetal Nagri.',
    ratingText: '4.2 (1.2K)',
    tags: ['Brass Markets', 'Heritage'],
    address: 'Peetal Bazaar, Moradabad, UP 248001',
    timings: '10:00 AM – 8:00 PM (Mon–Sat)',
    entryFee: 'Free',
  ),
  Place(
    id: 'raza-library',
    name: 'Raza Library, Rampur',
    image: 'https://picsum.photos/seed/localgo-raza/1000/640',
    metaLine: '55 min · Free · Heritage',
    description:
        'Rare Indo-Islamic manuscripts, miniature paintings and a stunning '
        'Mughal-era reading hall — an easy day trip from Moradabad.',
    ratingText: '4.7 (860)',
    tags: ['Heritage', 'Day Trip'],
    address: 'Raza Library, Rampur, UP',
    timings: '9:00 AM – 5:00 PM (Mon–Fri)',
    entryFee: 'Free (ID required)',
  ),
  Place(
    id: 'jama-masjid',
    name: 'Jama Masjid, Moradabad',
    image: 'https://picsum.photos/seed/localgo-jama/1000/640',
    metaLine: '12 min · Free · Heritage',
    description:
        'Mughal-era mosque with brass-inlaid doors and peaceful courtyards '
        'minutes from Chowk Bazaar.',
    ratingText: '4.5 (2.1K)',
    tags: ['Heritage', 'Free'],
    address: 'Chowk Bazaar, Moradabad',
    timings: 'Dawn – Dusk',
    entryFee: 'Free',
  ),
  Place(
    id: 'rudra-lake',
    name: 'Rudra Lake & Falhari Siro',
    image: 'https://picsum.photos/seed/localgo-rudra/1000/640',
    metaLine: '25 min · Entry ₹50 · Weekend',
    description:
        'Lakeside picnic spot with boating and food stalls — a favourite '
        'weekend escape for Moradabad families.',
    ratingText: '4.3 (640)',
    tags: ['Outdoors', 'Weekend'],
    address: 'Falhari Siro, Moradabad District',
    timings: '7:00 AM – 7:00 PM',
    entryFee: '₹50 per adult',
  ),
  Place(
    id: 'paras-water',
    name: 'Paras Water Kingdom',
    image: 'https://picsum.photos/seed/localgo-paras/1000/640',
    metaLine: '40 min · From ₹600 · Family',
    description:
        'Water park with slides, wave pool and kids zones — ideal for a '
        'summer family day out.',
    ratingText: '4.1 (980)',
    tags: ['Family', 'Water Park'],
    address: 'Delhi Road, Moradabad',
    timings: '10:00 AM – 7:00 PM',
    entryFee: 'From ₹600',
  ),
];

const mockFoods = <FoodHighlight>[
  FoodHighlight(
    name: 'Moradabadi Biryani',
    description: 'Slow-cooked biryani at Peeli Batti',
    image: 'https://picsum.photos/seed/localgo-food-biryani/600/600',
    rating: '4.6',
  ),
  FoodHighlight(
    name: 'Brass City Kulfi Falooda',
    description: 'Dense rabri kulfi, Chowk lane',
    image: 'https://picsum.photos/seed/localgo-food-kulfi/600/600',
    rating: '4.5',
  ),
  FoodHighlight(
    name: 'Mughlai Seekh Kebabs',
    description: 'Charcoal-grilled, Delhi Road',
    image: 'https://picsum.photos/seed/localgo-food-kebab/600/600',
    rating: '4.7',
  ),
  FoodHighlight(
    name: 'Bedai & Jalebi Breakfast',
    description: 'Morning classic, Budh Bazaar',
    image: 'https://picsum.photos/seed/localgo-food-jalebi/600/600',
    rating: '4.4',
  ),
];

const mockGuide = CityGuide(
  title: 'The Art of Peetal Nagri',
  subtitle: 'Meet the brass karigars keeping a 400-year craft alive.',
  author: 'Artisan Guild of Moradabad',
  image: 'https://picsum.photos/seed/localgo-guide/1000/640',
);

const mockExplorerTips = <ExplorerTip>[
  ExplorerTip(
    title: 'Best Times to Visit',
    text: 'Mornings (8–11 AM) are cooler and workshops are most active.',
  ),
  ExplorerTip(
    title: 'Brass Bargaining',
    text: 'Compare at least three shops in Peetal Bazaar before you buy.',
  ),
  ExplorerTip(
    title: 'Local Phrases',
    text: 'A little Hindi goes a long way — “kitne ka hai?” (how much?).',
  ),
];
