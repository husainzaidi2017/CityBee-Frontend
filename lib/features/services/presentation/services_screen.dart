import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_launcher.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/search_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/states_view.dart';
import '../../../data/mock/mock_services.dart';
import '../../../domain/models/service_item.dart';
import '../../../providers/app_providers.dart';

/// Services tab: "City Services Hub" — urgent helplines, verified
/// specialists by section, events and legal aid.
class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(selectedLocationProvider);
    final helplines = ref.watch(helplinesProvider);
    final services = ref.watch(servicesProvider);
    final events = ref.watch(eventServicesProvider);
    final legal = ref.watch(legalServiceProvider);
    final specialistCount = ref.watch(specialistCountProvider).valueOrNull ?? 340;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${location.displayName} Services Hub',
                      style: AppTypography.headline),
                  const SizedBox(height: 3),
                  Text(
                    'Everything you need in $specialistCount+ verified experts',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AppSearchBar(hint: 'Search service, expert, helpline…'),
            ),
            const SizedBox(height: 12),

            // ── Scroll body ────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  // Urgent & City Helplines
                  helplines.when(
                    data: (list) => _HelplinesCard(helplines: list),
                    loading: () => const _SectionSkeleton(),
                    error: (e, _) => _InlineError(
                        onRetry: () => ref.invalidate(helplinesProvider)),
                  ),
                  const SizedBox(height: 14),

                  // Brass Shield banner
                  const _BrassShieldBanner(),
                  const SizedBox(height: 18),

                  // Specialist sections
                  services.when(
                    data: (list) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < serviceSectionTitles.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ServiceSectionCard(
                              title: serviceSectionTitles[i],
                              services: _servicesForSection(list, i),
                            ),
                          ),
                      ],
                    ),
                    loading: () => const _SectionSkeleton(),
                    error: (e, _) => _InlineError(
                        onRetry: () => ref.invalidate(servicesProvider)),
                  ),
                  const SizedBox(height: 8),

                  // Events, weddings & religious
                  SectionHeader(
                    title: 'Events, Weddings & Religious',
                    subtitle: 'Pandits, mehndi artists & decorators',
                  ),
                  const SizedBox(height: 10),
                  events.when(
                    data: (list) => Row(
                      children: [
                        for (var i = 0; i < list.length; i++) ...[
                          Expanded(child: _EventCard(service: list[i])),
                          if (i < list.length - 1) const SizedBox(width: 10),
                        ],
                      ],
                    ),
                    loading: () => const _SectionSkeleton(),
                    error: (e, _) => _InlineError(
                        onRetry: () => ref.invalidate(eventServicesProvider)),
                  ),
                  const SizedBox(height: 18),

                  // Legal aid
                  legal.when(
                    data: (service) => _LegalAidCard(service: service),
                    loading: () => const _SectionSkeleton(),
                    error: (e, _) => _InlineError(
                        onRetry: () => ref.invalidate(legalServiceProvider)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ServiceItem> _servicesForSection(List<ServiceItem> all, int section) =>
      switch (section) {
        0 => all.where((s) => s.id == 'ac-care' || s.id == 'plumbing').toList(),
        1 => all.where((s) => s.id == 'brass-guild').toList(),
        2 => all.where((s) => s.id == 'homecare').toList(),
        _ => all.where((s) => s.id == 'roadside').toList(),
      };
}

/// ── Helplines card ─────────────────────────────────────────────────────
class _HelplinesCard extends StatelessWidget {
  const _HelplinesCard({required this.helplines});

  final List<Helpline> helplines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_rounded, size: 17, color: AppColors.brandRed),
              const SizedBox(width: 6),
              Expanded(child: Text('Urgent & City Helplines', style: AppTypography.titleSm)),
              Text('Tap to dial', style: AppTypography.label.copyWith(fontSize: 9.5)),
            ],
          ),
          const SizedBox(height: 11),
          ...helplines.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: _HelplineRow(helpline: h),
              )),
        ],
      ),
    );
  }
}

class _HelplineRow extends StatelessWidget {
  const _HelplineRow({required this.helpline});

  final Helpline helpline;

  @override
  Widget build(BuildContext context) {
    final color = Color(helpline.colorValue);
    return GestureDetector(
      onTap: () => AppLauncher.call(helpline.number),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(_iconFor(helpline.number), color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(helpline.label, style: AppTypography.bodyStrong),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                helpline.number,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String number) => switch (number) {
        '108' => Icons.medical_services,
        '112' => Icons.local_police_outlined,
        '1912' => Icons.bolt_rounded,
        '155213' => Icons.apartment,
        _ => Icons.local_pharmacy_outlined,
      };
}

/// ── Brass Shield banner ────────────────────────────────────────────────
class _BrassShieldBanner extends StatelessWidget {
  const _BrassShieldBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bannerOrangeTop, AppColors.bannerOrangeBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brass Shield Protection',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                SizedBox(height: 3),
                Text(
                  'Every specialist is ID-verified & background-checked.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white70),
        ],
      ),
    );
  }
}

/// ── Specialist section card ────────────────────────────────────────────
class _ServiceSectionCard extends StatelessWidget {
  const _ServiceSectionCard({required this.title, required this.services});

  final String title;
  final List<ServiceItem> services;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: 10),
        ...services.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SpecialistCard(service: s),
            )),
      ],
    );
  }
}

class _SpecialistCard extends StatelessWidget {
  const _SpecialistCard({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            height: 92,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppImage(url: service.image, width: 74, height: 92),
                ),
                Positioned(
                  top: 5,
                  left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: service.citySpecialty ? const Color(0xFF8A5A00) : AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      service.badge,
                      style: const TextStyle(
                          fontSize: 8.5, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSm,
                      ),
                    ),
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.starAmber),
                    const SizedBox(width: 2),
                    Text(service.rating, style: AppTypography.bodyStrong.copyWith(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  service.servicesSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(service.priceText,
                        style: AppTypography.bodyStrong
                            .copyWith(color: AppColors.primaryDark, fontSize: 12)),
                    const SizedBox(width: 8),
                    Text(service.etaText,
                        style: AppTypography.label.copyWith(fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${service.statsText} · ${service.trustNote}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label.copyWith(fontSize: 9.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => AppLauncher.call(service.phone),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          service.actionLabel,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Event mini card (2-column grid) ────────────────────────────────────
class _EventCard extends StatelessWidget {
  const _EventCard({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 76,
            width: double.infinity,
            child: AppImage(url: service.image, fallbackIcon: Icons.celebration_outlined),
          ),
          Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSm.copyWith(fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '${service.priceText} · ${service.etaText}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(fontSize: 9.5),
                ),
                const SizedBox(height: 7),
                GestureDetector(
                  onTap: () => AppLauncher.call(service.phone),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      service.actionLabel,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Legal aid wide card ────────────────────────────────────────────────
class _LegalAidCard extends StatelessWidget {
  const _LegalAidCard({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE7EEFD),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.gavel_outlined, color: AppColors.catDoctor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: AppTypography.titleSm.copyWith(fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(service.servicesSummary, style: AppTypography.caption),
                const SizedBox(height: 3),
                Text(
                  '${service.priceText} · ${service.etaText}',
                  style: AppTypography.label.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => AppLauncher.call(service.phone),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                service.actionLabel,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: StatesView.error(message: 'Could not load this section.', onRetry: onRetry),
    );
  }
}
