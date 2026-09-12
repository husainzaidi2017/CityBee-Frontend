import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/states_view.dart';
import '../../../domain/models/listing_submission.dart';
import '../../../providers/app_providers.dart';
import '../../../core/widgets/app_icons.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

/// Submission Status screen — every listing the signed-in user submitted,
/// with live status (Pending / Approved / Needs Changes) and resubmit.
class SubmissionStatusScreen extends ConsumerWidget {
  const SubmissionStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissions = ref.watch(mySubmissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Submission Status', style: AppTypography.title),
        leading: IconButton(
          icon: AppUiIcons.show(AppUiIcons.back, size: 15),
          // When there is no page to pop (opened via go()), fall back to
          // the More tab so the button always works.
          onPressed: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.maybePop();
            } else {
              context.go('/more');
            }
          },
        ),
      ),
      body: SafeArea(
        child: submissions.when(
          data: (list) {
            if (list.isEmpty) {
              return StatesView.empty(
                icon: AppUiIcons.store_plus,
                message:
                    'You have not submitted any business yet. Use "List Your Business" to get started.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: list.length,
              itemBuilder: (context, index) =>
                  _SubmissionCard(submission: list[index]),
            );
          },
          loading: () => StatesView.loading(message: 'Loading your submissions…'),
          error: (e, _) => StatesView.error(
            message: 'Could not load your submissions. Check your connection.',
            onRetry: () => ref.invalidate(mySubmissionsProvider),
          ),
        ),
      ),
    );
  }
}

class _SubmissionCard extends ConsumerWidget {
  const _SubmissionCard({required this.submission});

  final ListingSubmission submission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = submission.status;
    final rejected = status == 'rejected';
    final (label, color, icon) = switch (status) {
      'pending' => ('Pending Review', AppColors.starAmber, AppUiIcons.hourglass_empty),
      'approved' => ('Live on CityBee', AppColors.openGreen, AppUiIcons.check_circle),
      'rejected' => ('Needs Changes', AppColors.brandRed, AppUiIcons.alert_circle_outline),
      _ => (status, AppColors.textSecondary, AppUiIcons.information_outline),
    };
    final submitted = DateTime.tryParse(submission.submittedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Iconify(icon, size: 19, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  submission.businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSm,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (submitted != null)
                Text(
                  'Submitted ${submitted.day}/${submitted.month}/${submitted.year}',
                  style: AppTypography.label,
                ),
            ],
          ),
          if (rejected) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reason', style: AppTypography.label),
                  const SizedBox(height: 3),
                  Text(
                    submission.rejectionReason.isNotEmpty
                        ? submission.rejectionReason
                        : 'Your listing needs some changes before it can go live.',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                // Opens the wizard PREFILLED with this submission — the
                // user fixes the issues, then Save & Resubmit flips it
                // back to pending.
                onPressed: () =>
                    context.push('/list-business?edit=${submission.id}'),
                icon: Iconify(AppUiIcons.pencil, size: 14),
                label: const Text('Edit & Resubmit'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
