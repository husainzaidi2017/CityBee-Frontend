import 'package:flutter/material.dart';

import '../../../core/theme/app_animation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/sub_page_scaffold.dart';

/// Help & FAQ with expandable question cards.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = <(String, String)>[
    (
      'How do I redeem a coupon?',
      'Open the offer, tap “Copy Code” and show the code at billing — or just show '
          'the offer screen to the shopkeeper. The discount is applied instantly.'
    ),
    (
      'Are all businesses verified?',
      'Every listing with the “CityBee Verified” badge is ID-checked by our team. '
          'Unverified listings are clearly shown without the badge.'
    ),
    (
      'Why is my city not listed?',
      'CityBee is expanding city by city. Pick the nearest available city for now, '
          'or tap “Contact Support” to request yours.'
    ),
    (
      'How do I list my business?',
      'Tap “List Your Business” on the Home or More screen and complete the '
          'registration. Listings go live after a quick verification.'
    ),
    (
      'Do coupons cost anything?',
      'No. All coupons on CityBee are free to claim — you only pay the business '
          'for what you buy, with the discount applied.'
    ),
    (
      'How do favorites work?',
      'Tap the heart or bookmark icon on any business or place to save it. Find '
          'everything under More → My Favorites.'
    ),
    (
      'A listing has wrong information. What do I do?',
      'Use “Contact Support” and mention the business name — we correct verified '
          'listings within 48 hours.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Help & FAQ',
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _faqs.length,
        itemBuilder: (context, index) => _FaqTile(
          question: _faqs[index].$1,
          answer: _faqs[index].$2,
          initiallyExpanded: index == 0,
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
    this.initiallyExpanded = false,
  });

  final String question;
  final String answer;
  final bool initiallyExpanded;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => setState(() => _expanded = !_expanded),
      pressedScale: 0.99,
      ripple: true,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: AppTypography.bodyStrong.copyWith(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: AppAnimation.normal,
                    curve: AppAnimation.curve,
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: AppAnimation.normal,
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(13, 0, 13, 13),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.answer, style: AppTypography.caption),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
