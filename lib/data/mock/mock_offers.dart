import '../../domain/models/offer.dart';

final mockOffers = <Offer>[
  const Offer(
    id: 'handicraft-featured',
    businessId: 'trends-n-threads',
    title: 'Feel Handicrafts Emporium',
    badgeText: '25% OFF',
    subtitle: 'on All Boutique',
    description:
        'Handicraft & handloom showroom — now get flat 25% off on your first '
        'online order. Scan the CityBee QR at the counter to redeem.',
    couponCode: 'PINZE129',
    validityText: 'Valid till 30 Sep 2026',
    image: 'https://picsum.photos/seed/localgo-emporium/1000/640',
    categoryTag: 'Fashion',
    rating: 5.0,
    area: 'Subhash Nagar',
    distanceText: '2.7 km',
    remainingText: 'Only Left',
    leftCount: 12,
    featured: true,
  ),
  const Offer(
    id: 'royal-mughal-offer',
    businessId: 'royal-mughal',
    title: 'Royal Mughal Restaurant',
    badgeText: 'Flat 20% OFF',
    subtitle: 'on orders above ₹500',
    description:
        'Mughlai dining with family seating — show the coupon code FIRSTORDER '
        'for 20% off on dine-in and takeaway.',
    couponCode: 'FIRSTORDER',
    validityText: 'Valid till 30 Jun 2026',
    image: 'https://picsum.photos/seed/localgo-royal-offer/800/560',
    categoryTag: 'Dining',
    rating: 4.6,
    area: 'Civil Lines · 350 m',
    distanceText: '1.8 km',
  ),
  const Offer(
    id: 'trends-n-threads-offer',
    businessId: 'trends-n-threads',
    title: 'Trends N Threads Boutique',
    badgeText: 'Up to 50% OFF',
    subtitle: 'on all ethnic wear',
    description:
        'Designer suits and lehengas from local karigars — up to half price '
        'this season with code NEWSTYLE.',
    couponCode: 'NEWSTYLE',
    validityText: 'Valid till 15 Jul 2026',
    image: 'https://picsum.photos/seed/localgo-threads-offer/800/560',
    categoryTag: 'Fashion',
    rating: 4.4,
    area: 'Subhash Nagar · 600 m',
    distanceText: '2.7 km',
  ),
  const Offer(
    id: 'verma-dental-offer',
    businessId: 'verma-dental',
    title: 'Dr. Verma Dental Clinic',
    badgeText: '30% OFF',
    subtitle: 'on first consultation & cleaning',
    description:
        'Painless dentistry in the heart of Moradabad — 30% off for first-time '
        'CityBee patients with code SMILE20.',
    couponCode: 'SMILE20',
    validityText: 'Valid till 31 Aug 2026',
    image: 'https://picsum.photos/seed/localgo-dental-offer/800/560',
    categoryTag: 'Wellness & Health',
    rating: 4.8,
    area: 'Court Road · 280 m',
    distanceText: '1.1 km',
  ),
  const Offer(
    id: 'brassware-offer',
    businessId: 'brassware-corner',
    title: 'Moradabad Brassware Corner',
    badgeText: 'Flat 10% OFF',
    subtitle: 'on brass handicrafts above ₹2,000',
    description:
        'Handcrafted brass from third-generation karigars — 10% off export '
        'quality pieces with code PEETAL10.',
    couponCode: 'PEETAL10',
    validityText: 'Valid till 30 Sep 2026',
    image: 'https://picsum.photos/seed/localgo-brass-offer/800/560',
    categoryTag: 'Fashion',
    rating: 4.9,
    area: 'Peetal Bazaar · 1.2 km',
    distanceText: '1.5 km',
  ),
  const Offer(
    id: 'glow-glam-offer',
    businessId: 'glow-glam',
    title: 'Glow & Glam Bridal Studio',
    badgeText: '25% OFF',
    subtitle: 'on bridal makeup packages',
    description:
        'Look stunning on your big day — 25% off bridal packages booked '
        'through CityBee with code BRIDAL25.',
    couponCode: 'BRIDAL25',
    validityText: 'Valid till 15 Oct 2026',
    image: 'https://picsum.photos/seed/localgo-glam-offer/800/560',
    categoryTag: 'Beauty & Salon',
    rating: 4.5,
    area: 'Kanth Road · 900 m',
    distanceText: '2.9 km',
  ),
];
