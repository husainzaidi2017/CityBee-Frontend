import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/states_view.dart';
import '../../../domain/models/owner_business.dart';
import '../../../providers/app_providers.dart';

/// ── shared bits ─────────────────────────────────────────────────────────

class OwnerScaffold extends StatelessWidget {
  const OwnerScaffold({
    super.key,
    required this.title,
    required this.body,
    this.fab,
  });

  final String title;
  final Widget body;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(title, style: AppTypography.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      floatingActionButton: fab,
      body: body,
    );
  }
}

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.hint,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hint;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint, suffix: suffix),
        ),
      ],
    );
  }
}

/// Marks the owning dashboard refresh on return.
void _changed(WidgetRef ref) {
  ref.invalidate(myBusinessesProvider);
}

Future<bool> _saveWithFeedback(
  BuildContext context,
  Future<void> Function() action, {
  String successMessage = 'Saved',
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    await action();
    messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    navigator.pop(true);
    return true;
  } catch (e) {
    final text = e.toString();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          text.contains('already pending')
              ? 'A change request is already pending approval.'
              : 'Could not save. Please check and try again.',
        ),
      ),
    );
    return false;
  }
}

// ── Edit business profile ────────────────────────────────────────────────

class EditBusinessProfileScreen extends ConsumerStatefulWidget {
  const EditBusinessProfileScreen({super.key, required this.details});

  final OwnerBusinessDetails details;

  @override
  ConsumerState<EditBusinessProfileScreen> createState() =>
      _EditBusinessProfileScreenState();
}

class _EditBusinessProfileScreenState
    extends ConsumerState<EditBusinessProfileScreen> {
  late final _name = TextEditingController(text: widget.details.name);
  late final _tagline = TextEditingController(text: widget.details.tagline);
  late final _description = TextEditingController(
    text: widget.details.description,
  );
  late final _phone = TextEditingController(text: widget.details.phone);
  late final _whatsapp = TextEditingController(text: widget.details.whatsapp);
  late final _email = TextEditingController(text: widget.details.email);
  late final _website = TextEditingController(text: widget.details.website);
  late final _address = TextEditingController(text: widget.details.address);
  late final _locality = TextEditingController(text: widget.details.locality);
  late final _postal = TextEditingController(text: widget.details.postalCode);
  bool _saving = false;

  bool get _isDirty =>
      _name.text.trim() != widget.details.name ||
      _tagline.text.trim() != widget.details.tagline ||
      _description.text.trim() != widget.details.description ||
      _phone.text.trim() != widget.details.phone ||
      _whatsapp.text.trim() != widget.details.whatsapp ||
      _email.text.trim() != widget.details.email ||
      _website.text.trim() != widget.details.website ||
      _address.text.trim() != widget.details.address ||
      _locality.text.trim() != widget.details.locality ||
      _postal.text.trim() != widget.details.postalCode;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _name,
      _tagline,
      _description,
      _phone,
      _whatsapp,
      _email,
      _website,
      _address,
      _locality,
      _postal,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _tagline,
      _description,
      _phone,
      _whatsapp,
      _email,
      _website,
      _address,
      _locality,
      _postal,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business name is too short.')),
      );
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(ownerRepositoryProvider);
    final ok = await _saveWithFeedback(
      context,
      () => repo.requestBusinessUpdate(
        widget.details.id,
        name: _name.text.trim(),
        tagline: _tagline.text.trim(),
        description: _description.text.trim(),
        phone: _phone.text.trim(),
        whatsapp: _whatsapp.text.trim(),
        email: _email.text.trim(),
        website: _website.text.trim(),
        address: _address.text.trim(),
        locality: _locality.text.trim(),
        postalCode: _postal.text.trim(),
      ),
      successMessage: 'Sent for admin approval',
    );
    if (ok) _changed(ref);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return OwnerScaffold(
      title: 'Business Information',
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                children: [
                  LabeledField(label: 'Business name', controller: _name),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'Tagline (short line under the name)',
                    controller: _tagline,
                  ),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'Description',
                    controller: _description,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  Text('Contact', style: AppTypography.titleSm),
                  const SizedBox(height: 10),
                  LabeledField(
                    label: 'Phone',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'WhatsApp',
                    controller: _whatsapp,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'Email',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'Website',
                    controller: _website,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  Text('Location', style: AppTypography.titleSm),
                  const SizedBox(height: 10),
                  LabeledField(
                    label: 'Address',
                    controller: _address,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  LabeledField(label: 'Locality / Area', controller: _locality),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'Postal code',
                    controller: _postal,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: _saving || !_isDirty ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Send for Approval'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Business hours ───────────────────────────────────────────────────────

const _dayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

class BusinessHoursScreen extends ConsumerStatefulWidget {
  const BusinessHoursScreen({super.key, required this.details});

  final OwnerBusinessDetails details;

  @override
  ConsumerState<BusinessHoursScreen> createState() =>
      _BusinessHoursScreenState();
}

class _BusinessHoursScreenState extends ConsumerState<BusinessHoursScreen> {
  late List<BusinessHour> _hours;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _hours = List.generate(7, (i) {
      final existing = widget.details.hours
          .where((h) => h.dayOfWeek == i)
          .firstOrNull;
      return existing ??
          BusinessHour(
            dayOfWeek: i,
            isClosed: false,
            openTime: '09:00',
            closeTime: '21:00',
          );
    });
  }

  Future<void> _pickTime(int index, bool open) async {
    final current = _hours[index];
    final initial = open ? current.openTime : current.closeTime;
    final parts = initial.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts[1]) ?? 0,
      ),
    );
    if (picked == null) return;
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      _hours[index] = (open
          ? current.copyWith(openTime: value)
          : current.copyWith(closeTime: value));
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(ownerRepositoryProvider);
    final ok = await _saveWithFeedback(
      context,
      () => repo.updateHours(widget.details.id, _hours),
    );
    if (ok) _changed(ref);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return OwnerScaffold(
      title: 'Business Hours',
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                itemCount: 7,
                itemBuilder: (context, i) {
                  final h = _hours[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _dayNames[i],
                                style: AppTypography.bodyStrong,
                              ),
                            ),
                            Text('Closed', style: AppTypography.label),
                            Switch(
                              value: h.isClosed,
                              activeThumbColor: AppColors.brandRed,
                              onChanged: (v) => setState(
                                () => _hours[i] = h.copyWith(isClosed: v),
                              ),
                            ),
                          ],
                        ),
                        if (!h.isClosed)
                          Row(
                            children: [
                              _TimeChip(
                                label: h.openTime,
                                onTap: () => _pickTime(i, true),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              _TimeChip(
                                label: h.closeTime,
                                onTap: () => _pickTime(i, false),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Hours'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 13,
              color: AppColors.primary,
            ),
            const SizedBox(width: 5),
            Text(label, style: AppTypography.bodyStrong),
          ],
        ),
      ),
    );
  }
}

// ── Photos ───────────────────────────────────────────────────────────────

class BusinessPhotosScreen extends ConsumerStatefulWidget {
  const BusinessPhotosScreen({super.key, required this.details});

  final OwnerBusinessDetails details;

  @override
  ConsumerState<BusinessPhotosScreen> createState() =>
      _BusinessPhotosScreenState();
}

class _BusinessPhotosScreenState extends ConsumerState<BusinessPhotosScreen> {
  bool _uploading = false;

  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      await ref
          .read(ownerRepositoryProvider)
          .addPhoto(widget.details.id, File(picked.path));
      _changed(ref);
      ref.invalidate(ownerBusinessDetailsProvider(widget.details.id));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Photo added')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('IMAGE_LIMIT')
                  ? 'Maximum 5 photos allowed.'
                  : 'Upload failed. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _onImageTap(OwnerBusinessImage image) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!image.isPrimary)
              ListTile(
                leading: const Icon(
                  Icons.star_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Set as main photo'),
                onTap: () => Navigator.pop(sheetContext, 'primary'),
              ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.brandRed,
              ),
              title: const Text('Delete photo'),
              onTap: () => Navigator.pop(sheetContext, 'delete'),
            ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
    if (action == null) return;
    final repo = ref.read(ownerRepositoryProvider);
    try {
      if (action == 'primary') {
        await repo.setImagePrimary(widget.details.id, image.id);
      } else {
        await repo.deleteImage(image.id);
      }
      _changed(ref);
      ref.invalidate(ownerBusinessDetailsProvider(widget.details.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.details.images;
    return OwnerScaffold(
      title: 'Photos',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${images.length} of 5 photos', style: AppTypography.caption),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: images.length + 1,
            itemBuilder: (context, index) {
              if (index == images.length) {
                final canAdd = images.length < 5;
                return Pressable(
                  onTap: canAdd && !_uploading ? _addPhoto : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _uploading
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Icon(
                            canAdd
                                ? Icons.add_photo_alternate_outlined
                                : Icons.block_rounded,
                            size: 26,
                            color: AppColors.primary,
                          ),
                  ),
                );
              }
              final image = images[index];
              return GestureDetector(
                onTap: () => _onImageTap(image),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AppImage(url: image.url),
                    ),
                    if (image.isPrimary)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'MAIN',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Offers ───────────────────────────────────────────────────────────────

class ManageOffersScreen extends ConsumerWidget {
  const ManageOffersScreen({super.key, required this.details});

  final OwnerBusinessDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = details.offers;
    return OwnerScaffold(
      title: 'Offers',
      fab: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => CreateOfferScreen(businessId: details.id),
            ),
          );
          if (created == true) _changed(ref);
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: offers.isEmpty
          ? StatesView.empty(
              icon: Icons.local_offer_outlined,
              message:
                  'No offers yet — create your first offer to attract nearby customers.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final offer in offers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OfferRow(
                      offer: offer,
                      onDelete: () async {
                        try {
                          await ref
                              .read(ownerRepositoryProvider)
                              .deleteOffer(details.id, offer.id);
                          _changed(ref);
                          ref.invalidate(
                            ownerBusinessDetailsProvider(details.id),
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not delete. Try again.'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({required this.offer, required this.onDelete});

  final OwnerOffer offer;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final phaseColor = switch (offer.phase) {
      'active' => AppColors.openGreen,
      'scheduled' => AppColors.starAmber,
      'expired' => AppColors.textMuted,
      _ => AppColors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong,
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    offer.badgeText,
                    if (offer.validUntil != null) 'Till ${offer.validUntil}',
                  ].join(' · '),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: phaseColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              offer.phase.toUpperCase(),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: phaseColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.brandRed,
            ),
            onPressed: () => onDelete(),
          ),
        ],
      ),
    );
  }
}

class CreateOfferScreen extends ConsumerStatefulWidget {
  const CreateOfferScreen({super.key, required this.businessId});

  final String businessId;

  @override
  ConsumerState<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends ConsumerState<CreateOfferScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _badge = TextEditingController();
  final _terms = TextEditingController();
  String _discountType = 'percent';
  final _discountValue = TextEditingController();
  DateTime? _validFrom;
  DateTime? _validUntil;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_title, _description, _badge, _terms, _discountValue]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(bool from) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => from ? _validFrom = picked : _validUntil = picked);
  }

  Future<void> _publish() async {
    if (_title.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an offer title (3+ letters).')),
      );
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(ownerRepositoryProvider);
    final ok = await _saveWithFeedback(
      context,
      () => repo.createOffer(widget.businessId, {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'badgeText': _badge.text.trim(),
        'terms': _terms.text.trim(),
        'discountType': _discountType,
        if (_discountValue.text.trim().isNotEmpty)
          'discountValue': double.tryParse(_discountValue.text.trim()) ?? 0,
        if (_validFrom != null)
          'validFrom':
              '${_validFrom!.year}-${_validFrom!.month.toString().padLeft(2, '0')}-${_validFrom!.day.toString().padLeft(2, '0')}',
        if (_validUntil != null)
          'validUntil':
              '${_validUntil!.year}-${_validUntil!.month.toString().padLeft(2, '0')}-${_validUntil!.day.toString().padLeft(2, '0')}',
        'status': 'active',
      }),
      successMessage: 'Offer published',
    );
    if (ok) _changed(ref);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return OwnerScaffold(
      title: 'Create Offer',
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                children: [
                  LabeledField(
                    label: 'Offer title',
                    controller: _title,
                    hint: 'e.g. Weekend Special — 20% Off',
                  ),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'Description',
                    controller: _description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'Badge text',
                    controller: _badge,
                    hint: 'e.g. 20% OFF',
                  ),
                  const SizedBox(height: 12),
                  Text('Discount', style: AppTypography.titleSm),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final type in ['percent', 'flat', 'other']) ...[
                        ChoiceChip(
                          label: Text(
                            type == 'percent'
                                ? '%'
                                : type == 'flat'
                                ? '₹ Flat'
                                : 'Other',
                          ),
                          selected: _discountType == type,
                          onSelected: (v) =>
                              setState(() => _discountType = type),
                          selectedColor: AppColors.primarySoft,
                          labelStyle: TextStyle(
                            color: _discountType == type
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: TextField(
                          controller: _discountValue,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Value'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Validity', style: AppTypography.titleSm),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'From',
                          date: _validFrom,
                          onTap: () => _pickDate(true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateField(
                          label: 'Until',
                          date: _validUntil,
                          onTap: () => _pickDate(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'Terms (optional)',
                    controller: _terms,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: _saving ? null : _publish,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Publish Offer'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.label),
                  Text(
                    date == null
                        ? 'Select date'
                        : '${date!.day}/${date!.month}/${date!.year}',
                    style: AppTypography.bodyStrong,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reviews (read-only) ──────────────────────────────────────────────────

class BusinessReviewsScreen extends ConsumerWidget {
  const BusinessReviewsScreen({super.key, required this.details});

  final OwnerBusinessDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OwnerScaffold(
      title: 'Reviews',
      body: FutureBuilder<List<OwnerReview>>(
        future: ref.read(ownerRepositoryProvider).reviews(details.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return StatesView.loading();
          }
          final reviews = snapshot.data ?? const [];
          if (reviews.isEmpty) {
            return StatesView.empty(
              icon: Icons.rate_review_outlined,
              message: 'No reviews yet. Great service brings the first one!',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final review in reviews)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: AppColors.starAmber,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            review.rating.toStringAsFixed(1),
                            style: AppTypography.bodyStrong,
                          ),
                          const Spacer(),
                          Text(review.author, style: AppTypography.label),
                        ],
                      ),
                      if (review.comment.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(review.comment, style: AppTypography.caption),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Doctor details ───────────────────────────────────────────────────────

class DoctorDetailsScreen extends ConsumerStatefulWidget {
  const DoctorDetailsScreen({super.key, required this.details});

  final OwnerBusinessDetails details;

  @override
  ConsumerState<DoctorDetailsScreen> createState() =>
      _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends ConsumerState<DoctorDetailsScreen> {
  late final _name = TextEditingController(
    text: widget.details.doctor?['name'] as String? ?? '',
  );
  late final _specialization = TextEditingController(
    text: widget.details.doctor?['specialization'] as String? ?? '',
  );
  late final _qualification = TextEditingController(
    text: widget.details.doctor?['qualification'] as String? ?? '',
  );
  late final _experience = TextEditingController(
    text: (widget.details.doctor?['experienceYears'] ?? '').toString() == 'null'
        ? ''
        : (widget.details.doctor?['experienceYears'] ?? '').toString(),
  );
  late final _fee = TextEditingController(
    text: widget.details.doctor?['consultationFee'] as String? ?? '',
  );
  late final _bio = TextEditingController(
    text: widget.details.doctor?['bio'] as String? ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _specialization,
      _qualification,
      _experience,
      _fee,
      _bio,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(ownerRepositoryProvider);
    final ok = await _saveWithFeedback(
      context,
      () => repo.updateDoctor(widget.details.id, {
        'name': _name.text.trim(),
        'specialization': _specialization.text.trim(),
        'qualification': _qualification.text.trim(),
        if (_experience.text.trim().isNotEmpty)
          'experienceYears': int.tryParse(_experience.text.trim()) ?? 0,
        'consultationFee': _fee.text.trim(),
        'bio': _bio.text.trim(),
      }),
    );
    if (ok) _changed(ref);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return OwnerScaffold(
      title: 'Professional Details',
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                children: [
                  LabeledField(label: 'Doctor name', controller: _name),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'Specialization',
                    controller: _specialization,
                    hint: 'e.g. Dentist, Orthopaedist',
                  ),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'Qualification',
                    controller: _qualification,
                    hint: 'e.g. MBBS, MS (Orthopaedics)',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: 'Experience (years)',
                          controller: _experience,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LabeledField(
                          label: 'Consultation fee',
                          controller: _fee,
                          hint: '₹300',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LabeledField(label: 'Bio', controller: _bio, maxLines: 3),
                ],
              ),
            ),
            _SaveBar(label: 'Save Details', saving: _saving, onSave: _save),
          ],
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.label,
    required this.saving,
    required this.onSave,
  });

  final String label;
  final bool saving;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: saving ? null : onSave,
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(label),
          ),
        ),
      ),
    );
  }
}

// ── Hotel details + amenities ────────────────────────────────────────────

class HotelDetailsScreen extends ConsumerStatefulWidget {
  const HotelDetailsScreen({super.key, required this.details});

  final OwnerBusinessDetails details;

  @override
  ConsumerState<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends ConsumerState<HotelDetailsScreen> {
  late final _type = TextEditingController(
    text: widget.details.hotel?['hotelType'] as String? ?? '',
  );
  late final _price = TextEditingController(
    text: widget.details.hotel?['priceRange'] as String? ?? '',
  );
  late final _checkIn = TextEditingController(
    text: (widget.details.hotel?['checkIn'] ?? '').toString() == 'null'
        ? ''
        : (widget.details.hotel?['checkIn'] ?? '').toString(),
  );
  late final _checkOut = TextEditingController(
    text: (widget.details.hotel?['checkOut'] ?? '').toString() == 'null'
        ? ''
        : (widget.details.hotel?['checkOut'] ?? '').toString(),
  );
  late final Set<String> _amenities = {...widget.details.hotelAmenities};
  bool _saving = false;

  static const _amenityOptions = [
    'Wi-Fi',
    'Parking',
    'Restaurant',
    'Room Service',
    'AC Rooms',
    'Power Backup',
    'Banquet Hall',
    'Conference Room',
    'Airport Pickup',
    'Laundry',
    'Gym',
    'Breakfast Included',
  ];

  @override
  void dispose() {
    for (final c in [_type, _price, _checkIn, _checkOut]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(ownerRepositoryProvider);
    final ok = await _saveWithFeedback(context, () async {
      await repo.updateHotel(widget.details.id, {
        'hotelType': _type.text.trim(),
        'priceRange': _price.text.trim(),
        if (_checkIn.text.isNotEmpty) 'checkIn': _checkIn.text,
        if (_checkOut.text.isNotEmpty) 'checkOut': _checkOut.text,
      });
      await repo.updateAmenities(widget.details.id, _amenities.toList());
    });
    if (ok) _changed(ref);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return OwnerScaffold(
      title: 'Hotel Details',
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                children: [
                  LabeledField(
                    label: 'Hotel type',
                    controller: _type,
                    hint: 'e.g. 3-Star, Boutique, Budget',
                  ),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'Price range',
                    controller: _price,
                    hint: 'e.g. ₹1,400–₹2,800 / night',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: 'Check-in (HH:MM)',
                          controller: _checkIn,
                          hint: '12:00',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LabeledField(
                          label: 'Check-out (HH:MM)',
                          controller: _checkOut,
                          hint: '11:00',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Amenities', style: AppTypography.titleSm),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final amenity in _amenityOptions)
                        FilterChip(
                          label: Text(amenity),
                          selected: _amenities.contains(amenity),
                          onSelected: (v) => setState(
                            () => v
                                ? _amenities.add(amenity)
                                : _amenities.remove(amenity),
                          ),
                          selectedColor: AppColors.primarySoft,
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _amenities.contains(amenity)
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            _SaveBar(label: 'Save Details', saving: _saving, onSave: _save),
          ],
        ),
      ),
    );
  }
}

// ── Business services (salon/barber/repair) ──────────────────────────────

class BusinessServicesScreen extends ConsumerStatefulWidget {
  const BusinessServicesScreen({super.key, required this.details});

  final OwnerBusinessDetails details;

  @override
  ConsumerState<BusinessServicesScreen> createState() =>
      _BusinessServicesScreenState();
}

class _BusinessServicesScreenState
    extends ConsumerState<BusinessServicesScreen> {
  Future<void> _addOrEdit([BusinessServiceItem? existing]) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final price = TextEditingController(text: existing?.price ?? '');
    final duration = TextEditingController(
      text: existing?.durationMinutes?.toString() ?? '',
    );
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              existing == null ? 'Add Service' : 'Edit Service',
              style: AppTypography.title,
            ),
            const SizedBox(height: 12),
            LabeledField(label: 'Service name', controller: name),
            const SizedBox(height: 12),
            LabeledField(label: 'Price', controller: price, hint: 'e.g. ₹299'),
            const SizedBox(height: 12),
            LabeledField(
              label: 'Duration (minutes, optional)',
              controller: duration,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () => Navigator.pop(sheetContext, {
                  'name': name.text.trim(),
                  'price': price.text.trim(),
                  'duration': duration.text.trim(),
                }),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
    if (result == null || (result['name'] as String).length < 2) return;
    final repo = ref.read(ownerRepositoryProvider);
    try {
      final body = {
        'name': result['name'],
        'price': result['price'],
        if ((result['duration'] as String).isNotEmpty)
          'durationMinutes': int.tryParse(result['duration'] as String),
      };
      if (existing == null) {
        await repo.createService(widget.details.id, body);
      } else {
        await repo.updateService(widget.details.id, existing.id, body);
      }
      _changed(ref);
      ref.invalidate(ownerBusinessDetailsProvider(widget.details.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.details.services;
    return OwnerScaffold(
      title: 'Services',
      fab: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _addOrEdit(),
        child: const Icon(Icons.add_rounded),
      ),
      body: services.isEmpty
          ? StatesView.empty(
              icon: Icons.design_services_outlined,
              message:
                  'No services yet — add your services so customers know what you offer.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final service in services)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: AppTypography.bodyStrong,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  if (service.price.isNotEmpty) service.price,
                                  if (service.durationMinutes != null)
                                    '${service.durationMinutes} min',
                                  if (!service.active) 'Inactive',
                                ].join(' · '),
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: service.active,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) async {
                            try {
                              await ref
                                  .read(ownerRepositoryProvider)
                                  .updateService(
                                    widget.details.id,
                                    service.id,
                                    {'active': v},
                                  );
                              _changed(ref);
                              ref.invalidate(
                                ownerBusinessDetailsProvider(widget.details.id),
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not update.'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 19,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _addOrEdit(service),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

// ── Restaurant menu ──────────────────────────────────────────────────────

class RestaurantMenuScreen extends ConsumerStatefulWidget {
  const RestaurantMenuScreen({super.key, required this.details});

  final OwnerBusinessDetails details;

  @override
  ConsumerState<RestaurantMenuScreen> createState() =>
      _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends ConsumerState<RestaurantMenuScreen> {
  Future<void> _addOrEditItem([OwnerMenuItem? existing]) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final price = TextEditingController(text: existing?.price ?? '');
    final description = TextEditingController(
      text: existing?.description ?? '',
    );
    String? categoryId = existing?.categoryId;
    var isVeg = existing?.isVeg ?? true;
    var available = existing?.available ?? true;
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing == null ? 'Add Menu Item' : 'Edit Menu Item',
                style: AppTypography.title,
              ),
              const SizedBox(height: 12),
              LabeledField(label: 'Item name', controller: name),
              const SizedBox(height: 12),
              LabeledField(
                label: 'Price',
                controller: price,
                hint: 'e.g. ₹249',
              ),
              const SizedBox(height: 12),
              LabeledField(
                label: 'Description (optional)',
                controller: description,
              ),
              const SizedBox(height: 12),
              if (widget.details.menuCategories.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: categoryId,
                  decoration: const InputDecoration(hintText: 'Category'),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('No category'),
                    ),
                    for (final cat in widget.details.menuCategories)
                      DropdownMenuItem(value: cat.id, child: Text(cat.name)),
                  ],
                  onChanged: (v) => setSheetState(() => categoryId = v),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilterChip(
                    label: const Text('Veg'),
                    selected: isVeg,
                    onSelected: (v) => setSheetState(() => isVeg = true),
                    selectedColor: const Color(0xFFE7F6EC),
                    labelStyle: TextStyle(
                      color: isVeg
                          ? AppColors.verifiedGreen
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Non-Veg'),
                    selected: !isVeg,
                    onSelected: (v) => setSheetState(() => isVeg = false),
                    selectedColor: const Color(0xFFFDECEC),
                    labelStyle: TextStyle(
                      color: !isVeg
                          ? AppColors.brandRed
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text('Available', style: AppTypography.label),
                  Switch(
                    value: available,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setSheetState(() => available = v),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () => Navigator.pop(sheetContext, {
                    'name': name.text.trim(),
                    'price': price.text.trim(),
                    'description': description.text.trim(),
                    'categoryId': categoryId,
                    'isVeg': isVeg,
                    'available': available,
                  }),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == null || (result['name'] as String).length < 2) return;
    final repo = ref.read(ownerRepositoryProvider);
    try {
      final body = {
        'name': result['name'],
        'price': result['price'],
        'description': result['description'],
        'isVeg': result['isVeg'],
        'available': result['available'],
        if ((result['categoryId'] as String?)?.isNotEmpty == true)
          'menuCategoryId': result['categoryId'],
      };
      if (existing == null) {
        await repo.createMenuItem(widget.details.id, body);
      } else {
        await repo.updateMenuItem(widget.details.id, existing.id, body);
      }
      _changed(ref);
      ref.invalidate(ownerBusinessDetailsProvider(widget.details.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Try again.')),
        );
      }
    }
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Add Menu Category', style: AppTypography.titleSm),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Starters, Main Course',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name == null || name.length < 2) return;
    try {
      await ref
          .read(ownerRepositoryProvider)
          .createMenuCategory(widget.details.id, name);
      _changed(ref);
      ref.invalidate(ownerBusinessDetailsProvider(widget.details.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not add category.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menu = widget.details;
    return OwnerScaffold(
      title: 'Menu',
      fab: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _addOrEditItem(),
        child: const Icon(Icons.add_rounded),
      ),
      body: menu.menuItems.isEmpty && menu.menuCategories.isEmpty
          ? StatesView.empty(
              icon: Icons.restaurant_menu_rounded,
              message:
                  'No menu items yet — add dishes so customers can see what you serve.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${menu.menuItems.length} items · ${menu.menuCategories.length} categories',
                        style: AppTypography.caption,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addCategory,
                      icon: const Icon(
                        Icons.folder_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: const Text('Add Category'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                for (final item in menu.menuItems)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: item.isVeg
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB91C1C),
                              width: 1.4,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: item.isVeg
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFFB91C1C),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodyStrong,
                                    ),
                                  ),
                                  if (!item.available) ...[
                                    const SizedBox(width: 6),
                                    const Text(
                                      '· Unavailable',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: AppColors.brandRed,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  menu.menuCategories
                                      .where((c) => c.id == item.categoryId)
                                      .firstOrNull
                                      ?.name,
                                  if (item.price.isNotEmpty) item.price,
                                ].whereType<String>().join(' · '),
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 19,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _addOrEditItem(item),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 19,
                            color: AppColors.brandRed,
                          ),
                          onPressed: () async {
                            try {
                              await ref
                                  .read(ownerRepositoryProvider)
                                  .deleteMenuItem(widget.details.id, item.id);
                              _changed(ref);
                              ref.invalidate(
                                ownerBusinessDetailsProvider(widget.details.id),
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not delete.'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

// ── Restaurant details ───────────────────────────────────────────────────

class RestaurantDetailsScreen extends ConsumerStatefulWidget {
  const RestaurantDetailsScreen({super.key, required this.details});

  final OwnerBusinessDetails details;

  @override
  ConsumerState<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState
    extends ConsumerState<RestaurantDetailsScreen> {
  late final _cuisine = TextEditingController(
    text: widget.details.restaurant?['cuisine'] as String? ?? '',
  );
  late final _price = TextEditingController(
    text: widget.details.restaurant?['priceRange'] as String? ?? '',
  );
  late String _vegType =
      widget.details.restaurant?['vegType'] as String? ?? 'mixed';
  bool _saving = false;

  @override
  void dispose() {
    _cuisine.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(ownerRepositoryProvider);
    final ok = await _saveWithFeedback(
      context,
      () => repo.updateRestaurant(widget.details.id, {
        'cuisine': _cuisine.text.trim(),
        'priceRange': _price.text.trim(),
        'vegType': _vegType,
      }),
    );
    if (ok) _changed(ref);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return OwnerScaffold(
      title: 'Restaurant Details',
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                children: [
                  LabeledField(
                    label: 'Cuisines',
                    controller: _cuisine,
                    hint: 'e.g. Mughlai · Awadhi · North Indian',
                  ),
                  const SizedBox(height: 12),
                  LabeledField(
                    label: 'Price range',
                    controller: _price,
                    hint: 'e.g. ₹200–₹600 for two',
                  ),
                  const SizedBox(height: 16),
                  Text('Kitchen type', style: AppTypography.titleSm),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final type in ['veg', 'non_veg', 'mixed'])
                        ChoiceChip(
                          label: Text(switch (type) {
                            'veg' => 'Pure Veg',
                            'non_veg' => 'Non-Veg',
                            _ => 'Mixed',
                          }),
                          selected: _vegType == type,
                          onSelected: (v) => setState(() => _vegType = type),
                          selectedColor: AppColors.primarySoft,
                          labelStyle: TextStyle(
                            color: _vegType == type
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            _SaveBar(label: 'Save Details', saving: _saving, onSave: _save),
          ],
        ),
      ),
    );
  }
}
