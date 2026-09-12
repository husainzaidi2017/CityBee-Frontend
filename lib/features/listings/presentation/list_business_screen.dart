import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_animation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/states_view.dart';
import '../../../domain/models/listing_submission.dart';
import '../../../providers/app_providers.dart';
import '../../home/presentation/widgets/category_visual.dart';
import '../../../core/widgets/app_icons.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import '../../../core/widgets/skeleton.dart';

/// List Your Business — 6-step wizard:
/// 1 Category → 2 Details → 3 Address & Location → 4 Category Details
/// → 5 Photos → 6 Review & Submit → success screen.
class ListBusinessScreen extends ConsumerStatefulWidget {
  /// When set, the wizard runs in EDIT mode: it prefills from this
  /// rejected submission and PATCHes + resubmits instead of creating new.
  const ListBusinessScreen({super.key, this.editSubmissionId});

  final String? editSubmissionId;

  @override
  ConsumerState<ListBusinessScreen> createState() => _ListBusinessScreenState();
}

class _ListBusinessScreenState extends ConsumerState<ListBusinessScreen> {
  final _draft = ListingDraft();
  final List<XFile> _photos = [];
  final Map<String, String> _uploadedPhotos = {};
  int _step = 0;
  bool _submitting = false;
  bool _loadingEdit = false;

  @override
  void initState() {
    super.initState();
    final id = widget.editSubmissionId;
    if (id != null) _loadForEdit(id);
  }

  Future<void> _loadForEdit(String id) async {
    setState(() => _loadingEdit = true);
    try {
      final detail = await ref
          .read(listingRepositoryProvider)
          .submissionDetail(id);
      _draft.applyDetail(detail);
      _draft.imageUrls = ((detail['imageUrls'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load the submission for editing.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingEdit = false);
    }
  }

  static const _stepTitles = [
    'Business Type',
    'Business Details',
    'Address & Location',
    'Category Details',
    'Photos',
    'Review',
  ];

  @override
  Widget build(BuildContext context) {
    if (_loadingEdit) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.surface),
        body: const Shimmer(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: SkeletonBox(height: 120, width: double.infinity, radius: 16),
                  ),
                  SizedBox(height: 14),
                  SkeletonList(itemCount: 3, itemHeight: 96),
                ],
              ),
            ),
          ),
        ),
      );
    }
    // Guest gate: listing a business requires an account (so the approved
    // business can be owned). After sign-in the user returns here.
    final signedIn = ref.watch(authStateProvider);
    if (!signedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Iconify(
                    AppUiIcons.storefront_outline,
                    size: 34,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Sign in to list your business',
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(fontSize: 19),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a free account so your approved business belongs to you — you’ll manage it from My Business.',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () => context.push('/login'),
                  child: const Text('Sign in / Create Account'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text('Maybe later', style: AppTypography.label),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: AppUiIcons.show(AppUiIcons.back, size: 15),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--); // Back keeps all entered data.
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          widget.editSubmissionId != null
              ? 'Edit Your Listing'
              : 'List Your Business',
          style: AppTypography.title,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepIndicator(step: _step, titles: _stepTitles),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppAnimation.normal,
                child: switch (_step) {
                  0 => _CategoryStep(
                    draft: _draft,
                    onChanged: () => setState(() {}),
                  ),
                  1 => _DetailsStep(
                    draft: _draft,
                    onChanged: () => setState(() {}),
                  ),
                  2 => _AddressStep(
                    draft: _draft,
                    onChanged: () => setState(() {}),
                  ),
                  3 => _CategoryDetailsStep(
                    draft: _draft,
                    onChanged: () => setState(() {}),
                  ),
                  4 => _PhotosStep(
                    files: _photos,
                    draft: _draft,
                    onChanged: () => setState(() {}),
                  ),
                  _ => _ReviewStep(
                    draft: _draft,
                    submitting: _submitting,
                    onSubmit: _submit,
                  ),
                },
              ),
            ),
            if (_step < 5) _ContinueBar(enabled: _stepReady, onNext: _next),
          ],
        ),
      ),
    );
  }

  bool get _stepReady => switch (_step) {
    0 => _draft.categorySlug != null,
    1 =>
      _draft.businessName.trim().length >= 2 &&
          _draft.phone.replaceAll(RegExp(r'[^0-9]'), '').length >= 10 &&
          _draft.whatsapp.replaceAll(RegExp(r'[^0-9]'), '').length >= 10 &&
          _emailRe.hasMatch(_draft.email.trim()),
    2 =>
      _draft.address.trim().length >= 6 &&
          _draft.cityName.trim().isNotEmpty &&
          _draft.bizLat != null &&
          _draft.bizLng != null,
    3 => !_draft.isDoctor || (_draft.specialization ?? '').trim().length >= 2,
    4 => true, // photos optional
    _ => true,
  };

  static final _emailRe = RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[a-zA-Z]{2,}$');

  void _next() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _step++);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      // Photos chosen? Upload them first and attach the Cloudinary URLs.
      final repo = ref.read(listingRepositoryProvider);
      final urls = <String>[];
      for (final photo in _photos) {
        final url =
            _uploadedPhotos[photo.path] ?? await repo.uploadDraftImage(photo);
        _uploadedPhotos[photo.path] = url;
        urls.add(url);
      }
      _draft.imageUrls = urls;
      final editId = widget.editSubmissionId;
      if (editId != null) {
        // Edit mode: update the rejected submission, then flip to pending.
        await repo.editSubmission(editId, _draft.toBody());
        await repo.resubmit(editId);
      } else {
        await repo.submit(_draft);
      }
      if (!mounted) return;
      // Success → dedicated screen via the ROUTER (native push would put it
      // outside GoRouter's tree and break its buttons).
      ref.invalidate(mySubmissionsProvider);
      context.go('/submission-success');
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('already')
                  ? 'This business may already be listed on CityBee.'
                  : e.toString().contains('Photo upload')
                  ? 'Photos could not upload. Please retry; your listing has not been submitted.'
                  : e.toString().contains('valid')
                  ? 'Please check the highlighted fields.'
                  : 'Could not submit. Please check your connection and try again.',
            ),
          ),
        );
      }
    }
  }
}

// ── Step indicator ───────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step, required this.titles});

  final int step;
  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              Text(
                'Step ${step + 1} of ${titles.length}',
                style: AppTypography.label,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titles[step],
                  style: AppTypography.titleSm,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Progress bar.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              duration: AppAnimation.normal,
              tween: Tween(end: (step + 1) / titles.length),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Step 1: category ─────────────────────────────────────────────────────

class _CategoryStep extends ConsumerWidget {
  const _CategoryStep({required this.draft, required this.onChanged});

  final ListingDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return categories.when(
      data: (all) {
        // Hide consumer-only categories (cinemas, heritage, malls, parks,
        // places, markets) — customers cannot list these themselves.
        final list = all.where((c) => !_isHiddenWizardCategory(c)).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            Text(
              'Tell us what type of business you want to list.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final category = list[index];
                final selected = draft.categorySlug == category.id;
                final visual = CategoryVisual.of(category.id);
                return GestureDetector(
                  onTap: () {
                    draft.categorySlug = category.id;
                    onChanged();
                  },
                  child: AnimatedContainer(
                    duration: AppAnimation.fast,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primarySoft
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.card,
                      border: selected
                          ? Border.all(color: AppColors.primary, width: 1.6)
                          : null,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CategoryIcon(visual: visual, size: 40),
                        const SizedBox(height: 6),
                        Text(
                          category.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(
                            fontSize: 11,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => StatesView.loading(message: 'Loading categories…'),
      error: (e, _) => StatesView.error(
        message: 'Could not load categories.',
        onRetry: () => ref.invalidate(categoriesProvider),
      ),
    );
  }
}

// ── Step 2: common details ───────────────────────────────────────────────

/// Categories hidden from the wizard (consumer/curated only — the admin
/// can still list them via the panel).
const _hiddenWizardCategories = {
  'cinemas',
  'cinema',
  'heritages',
  'heritage',
  'malls',
  'mall',
  'parks',
  'park',
  'places',
  'place',
  'markets',
  'market',
};

bool _isHiddenWizardCategory(dynamic category) {
  final id = category.id.toString().trim().toLowerCase();
  final name = category.name.toString().trim().toLowerCase();
  return _hiddenWizardCategories.contains(id) ||
      _hiddenWizardCategories.contains(name) ||
      _hiddenWizardCategories.contains(name.replaceAll(' ', '-')) ||
      _hiddenWizardCategories.contains(name.replaceAll(' ', ''));
}

class _DetailsStep extends StatefulWidget {
  const _DetailsStep({required this.draft, required this.onChanged});

  final ListingDraft draft;
  final VoidCallback onChanged;

  @override
  State<_DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<_DetailsStep> {
  String _phoneDialCode = '+91';
  String _whatsappDialCode = '+91';
  bool _whatsappSameAsPhone = true;

  static const _dialCodes = [
    '+91',
    '+971',
    '+966',
    '+974',
    '+973',
    '+968',
    '+1',
    '+44',
    '+61',
    '+62',
    '+63',
    '+60',
    '+65',
    '+94',
    '+880',
    '+977',
    '+7',
    '+48',
    '+49',
    '+33',
  ];

  @override
  void initState() {
    super.initState();
    _phoneDialCode = _dialCodeFor(widget.draft.phone);
    _whatsappDialCode = _dialCodeFor(widget.draft.whatsapp);
    _whatsappSameAsPhone =
        widget.draft.whatsapp.isEmpty ||
        widget.draft.whatsapp == widget.draft.phone;
  }

  String _dialCodeFor(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return _dialCodes
        .where((code) => digits.startsWith(code.substring(1)))
        .fold('+91', (best, code) => code.length > best.length ? code : best);
  }

  String _digitsOnly(String raw, String dialCode) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final prefix = dialCode.substring(1);
    if (digits.startsWith(prefix) && digits.length > prefix.length) {
      digits = digits.substring(prefix.length);
    }
    return digits;
  }

  Future<void> _pickDialCode({
    required String current,
    required ValueChanged<String> onPicked,
  }) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          children: [
            for (final code in _dialCodes)
              ListTile(
                dense: true,
                title: Text(code),
                trailing: Text(switch (code) {
                  '+91' => 'India',
                  '+971' => 'UAE',
                  '+966' => 'Saudi',
                  '+974' => 'Qatar',
                  '+973' => 'Bahrain',
                  '+968' => 'Oman',
                  '+1' => 'US/Canada',
                  '+44' => 'UK',
                  '+61' => 'Australia',
                  '+62' => 'Indonesia',
                  '+63' => 'Philippines',
                  '+60' => 'Malaysia',
                  '+65' => 'Singapore',
                  '+94' => 'Sri Lanka',
                  '+880' => 'Bangladesh',
                  '+977' => 'Nepal',
                  '+7' => 'Russia',
                  '+48' => 'Poland',
                  '+49' => 'Germany',
                  _ => '',
                }, style: AppTypography.label),
                onTap: () => Navigator.pop(sheetContext, code),
              ),
          ],
        ),
      ),
    );
    if (picked != null && picked != current) onPicked(picked);
  }

  String _flagFor(String code) => switch (code) {
    '+91' => '🇮🇳',
    '+971' => '🇦🇪',
    '+966' => '🇸🇦',
    '+974' => '🇶🇦',
    '+973' => '🇧🇭',
    '+968' => '🇴🇲',
    '+1' => '🇺🇸',
    '+44' => '🇬🇧',
    '+61' => '🇦🇺',
    '+62' => '🇮🇩',
    '+63' => '🇵🇭',
    '+60' => '🇲🇾',
    '+65' => '🇸🇬',
    '+94' => '🇱🇰',
    '+880' => '🇧🇩',
    '+977' => '🇳🇵',
    '+7' => '🇷🇺',
    '+48' => '🇵🇱',
    '+49' => '🇩🇪',
    '+33' => '🇫🇷',
    _ => '🌐',
  };

  Future<void> _pickTime(bool isOpen) async {
    final current = widget.draft.openingHours;
    TimeOfDay initial = TimeOfDay(hour: isOpen ? 9 : 21, minute: 0);
    // Parse the existing "H:MM AM – H:MM PM" if present.
    final match = RegExp(
      r'(\d{1,2}):(\d{2})\s*(AM|PM)?\s*–\s*(\d{1,2}):(\d{2})\s*(AM|PM)?',
    ).firstMatch(current);
    if (match != null) {
      final h = int.parse(isOpen ? match.group(1)! : match.group(4)!);
      final m = int.parse(isOpen ? match.group(2)! : match.group(5)!);
      final pm = (isOpen ? match.group(3) : match.group(6)) == 'PM';
      var hour = h % 12 + (pm ? 12 : 0);
      initial = TimeOfDay(hour: hour, minute: m);
    }
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      String fmt(TimeOfDay t) =>
          '${((t.hour % 12) == 0 ? 12 : t.hour % 12).toString()}:${t.minute.toString().padLeft(2, '0')} ${t.hour >= 12 ? 'PM' : 'AM'}';
      final open = isOpen ? fmt(picked) : _openLabel ?? fmt(picked);
      final close = isOpen ? _closeLabel ?? fmt(picked) : fmt(picked);
      widget.draft.openingHours = '$open – $close';
    });
    widget.onChanged();
  }

  String? get _openLabel => RegExp(
    r'^(\d{1,2}:\d{2}\s*[AP]M)',
  ).firstMatch(widget.draft.openingHours)?.group(1);
  String? get _closeLabel => RegExp(
    r'–\s*(\d{1,2}:\d{2}\s*[AP]M)',
  ).firstMatch(widget.draft.openingHours)?.group(1);

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        _Field(
          label: draft.isDoctor
              ? 'Doctor Name *'
              : draft.isHotel
              ? 'Hotel Name *'
              : 'Business Name *',
          value: draft.businessName,
          onChanged: (v) {
            draft.businessName = v;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Tagline (short line under the name)',
          value: draft.tagline,
          onChanged: (v) => draft.tagline = v,
          hint: 'e.g. Mughlai · Family Dining',
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Description',
          value: draft.description,
          onChanged: (v) => draft.description = v,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        Text('Contact', style: AppTypography.titleSm),
        const SizedBox(height: 6),
        // Phone with dial code
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _pickDialCode(
                current: _phoneDialCode,
                onPicked: (code) {
                  setState(() {
                    final local = _digitsOnly(draft.phone, _phoneDialCode);
                    _phoneDialCode = code;
                    draft.phone = '$code$local';
                    if (_whatsappSameAsPhone) {
                      _whatsappDialCode = code;
                      draft.whatsapp = draft.phone;
                    }
                  });
                  widget.onChanged();
                },
              ),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1.1),
                ),
                child: Row(
                  children: [
                    Text(_flagFor(_phoneDialCode)),
                    const SizedBox(width: 6),
                    Text(_phoneDialCode, style: AppTypography.bodyStrong),
                    Iconify(AppUiIcons.chevron_down, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Field(
                label: 'Phone Number *',
                value: _digitsOnly(draft.phone, _phoneDialCode),
                onChanged: (v) {
                  draft.phone =
                      '$_phoneDialCode${_digitsOnly(v, _phoneDialCode)}';
                  if (_whatsappSameAsPhone) {
                    _whatsappDialCode = _phoneDialCode;
                    draft.whatsapp = draft.phone;
                  }
                  widget.onChanged();
                },
                keyboardType: TextInputType.phone,
                hint: 'Phone number',
                showLabel: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                errorText:
                    _digitsOnly(draft.phone, _phoneDialCode).isEmpty ||
                        _digitsOnly(draft.phone, _phoneDialCode).length == 10
                    ? null
                    : 'Enter 10 digits',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SamePhoneTile(
          value: _whatsappSameAsPhone,
          onChanged: (value) {
            setState(() {
              _whatsappSameAsPhone = value;
              if (value) {
                _whatsappDialCode = _phoneDialCode;
                draft.whatsapp = draft.phone;
              }
            });
            widget.onChanged();
          },
        ),
        if (!_whatsappSameAsPhone) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _pickDialCode(
                  current: _whatsappDialCode,
                  onPicked: (code) {
                    setState(() {
                      final local = _digitsOnly(
                        draft.whatsapp,
                        _whatsappDialCode,
                      );
                      _whatsappDialCode = code;
                      draft.whatsapp = '$code$local';
                    });
                    widget.onChanged();
                  },
                ),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1.1),
                  ),
                  child: Row(
                    children: [
                      Text(_flagFor(_whatsappDialCode)),
                      const SizedBox(width: 6),
                      Text(_whatsappDialCode, style: AppTypography.bodyStrong),
                      Iconify(AppUiIcons.chevron_down, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Field(
                  label: 'WhatsApp Number *',
                  value: _digitsOnly(draft.whatsapp, _whatsappDialCode),
                  onChanged: (v) {
                    draft.whatsapp =
                        '$_whatsappDialCode${_digitsOnly(v, _whatsappDialCode)}';
                    widget.onChanged();
                  },
                  keyboardType: TextInputType.phone,
                  hint: 'WhatsApp number',
                  showLabel: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  errorText:
                      _digitsOnly(draft.whatsapp, _whatsappDialCode).isEmpty ||
                          _digitsOnly(
                                draft.whatsapp,
                                _whatsappDialCode,
                              ).length ==
                              10
                      ? null
                      : 'Enter 10 digits',
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        _Field(
          label: 'Email *',
          value: draft.email,
          onChanged: (v) {
            draft.email = v;
            widget.onChanged();
          },
          keyboardType: TextInputType.emailAddress,
          hint: 'Email address *',
          showLabel: false,
          errorText:
              draft.email.trim().isEmpty ||
                  _ListBusinessScreenState._emailRe.hasMatch(draft.email.trim())
              ? null
              : 'Enter a valid email',
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Website',
          value: draft.website,
          onChanged: (v) => draft.website = v,
          keyboardType: TextInputType.url,
          hint: 'https://…',
        ),
        const SizedBox(height: 16),
        Text('Opening Hours', style: AppTypography.titleSm),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _TimeField(
                label: 'Opens',
                value: _openLabel,
                onTap: () => _pickTime(true),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Iconify(
                AppUiIcons.arrow_right,
                size: 12,
                color: AppColors.textMuted,
              ),
            ),
            Expanded(
              child: _TimeField(
                label: 'Closes',
                value: _closeLabel,
                onTap: () => _pickTime(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Clock-picker chip (Opens / Closes).
class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Iconify(
              AppUiIcons.clock_outline,
              size: 13,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.label),
                  Text(value ?? 'Select time', style: AppTypography.bodyStrong),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SamePhoneTile extends StatelessWidget {
  const _SamePhoneTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.24)),
        ),
        child: Row(
          children: [
            Iconify(AppUiIcons.message_outline, size: 15, color: AppColors.primary),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'WhatsApp is the same as Phone Number',
                style: AppTypography.label.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Checkbox(
              value: value,
              activeColor: AppColors.primary,
              onChanged: (v) => onChanged(v ?? false),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 3: address & location ───────────────────────────────────────────

class _AddressStep extends ConsumerStatefulWidget {
  const _AddressStep({required this.draft, required this.onChanged});

  final ListingDraft draft;
  final VoidCallback onChanged;

  @override
  ConsumerState<_AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends ConsumerState<_AddressStep> {
  String _cityQuery = '';

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(selectedLocationProvider);
    // Default city = the user's selected CityBee location.
    if (widget.draft.cityName.isEmpty) {
      widget.draft.cityName = location.displayName;
      widget.draft.cityLat ??= location.latitude;
      widget.draft.cityLng ??= location.longitude;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        _Field(
          label: 'Business Address *',
          value: widget.draft.address,
          onChanged: (v) {
            widget.draft.address = v;
            widget.onChanged();
          },
          maxLines: 2,
          hint: 'Shop no, street, landmark…',
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Locality / Area',
          value: widget.draft.locality,
          onChanged: (v) => widget.draft.locality = v,
          hint: 'e.g. Civil Lines',
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'City *',
          value: _cityQuery.isNotEmpty ? _cityQuery : widget.draft.cityName,
          onChanged: (v) {
            setState(() => _cityQuery = v);
            widget.draft.cityName = v;
            widget.onChanged();
          },
          hint: 'e.g. Moradabad',
        ),
        const SizedBox(height: 16),
        Text('Map Location *', style: AppTypography.titleSm),
        const SizedBox(height: 4),
        Text(
          'Tap to place your business pin — customers find you by it.',
          style: AppTypography.caption,
        ),
        const SizedBox(height: 10),
        _LocationPickerCard(draft: widget.draft, onChanged: widget.onChanged),
      ],
    );
  }
}

class _LocationPickerCard extends ConsumerWidget {
  const _LocationPickerCard({required this.draft, required this.onChanged});

  final ListingDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPin = draft.bizLat != null && draft.bizLng != null;
    return Pressable(
      onTap: () async {
        final picked = await Navigator.of(context).push<List<double>>(
          MaterialPageRoute(builder: (_) => _PinMapScreen(draft: draft)),
        );
        if (picked != null && picked.length >= 2) {
          draft.bizLat = picked[0];
          draft.bizLng = picked[1];
          // Pin se city auto-fill: reverse geocode the pin into the City
          // field (user can still edit it afterwards).
          try {
            final loc = await ref
                .read(cityRepositoryProvider)
                .reverseGeocode(picked[0], picked[1]);
            if (loc != null && loc.displayName.trim().isNotEmpty) {
              draft.cityName = loc.displayName.trim();
              draft.cityLat ??= loc.latitude;
              draft.cityLng ??= loc.longitude;
              if (draft.locality.isEmpty && loc.locality != null) {
                draft.locality = loc.locality!.trim();
              }
            }
          } catch (_) {
            // City stays as typed — pin coordinates still save.
          }
          onChanged();
        }
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              hasPin ? AppUiIcons.map_marker : AppUiIcons.map_marker_plus_outline,
              size: 29,
              color: AppColors.primary,
            ),
            const SizedBox(height: 6),
            Text(
              hasPin
                  ? 'Pin set (${draft.bizLat!.toStringAsFixed(4)}, ${draft.bizLng!.toStringAsFixed(4)})'
                  : 'Tap to set your business location',
              style: AppTypography.bodyStrong.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
            if (hasPin)
              TextButton(
                onPressed: null,
                child: Text('Tap to adjust', style: AppTypography.label),
              ),
          ],
        ),
      ),
    );
  }
}

/// Real geographic map: selected coordinates come from the tapped map point.
class _PinMapScreen extends StatefulWidget {
  const _PinMapScreen({required this.draft});

  final ListingDraft draft;

  @override
  State<_PinMapScreen> createState() => _PinMapScreenState();
}

class _PinMapScreenState extends State<_PinMapScreen> {
  late LatLng? _pin = widget.draft.bizLat != null && widget.draft.bizLng != null
      ? LatLng(widget.draft.bizLat!, widget.draft.bizLng!)
      : null;
  bool _tileError = false;
  int _mapAttempt = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Set Location', style: AppTypography.title),
        leading: IconButton(
          icon: AppUiIcons.show(AppUiIcons.back, size: 15),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              key: ValueKey(_mapAttempt),
              options: MapOptions(
                initialCenter:
                    _pin ??
                    LatLng(
                      widget.draft.cityLat ?? 28.8386,
                      widget.draft.cityLng ?? 78.7733,
                    ),
                initialZoom: 15,
                maxZoom: 19,
                onTap: (_, point) => setState(() => _pin = point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.localgo',
                  errorTileCallback: (_, __, ___) {
                    if (!mounted || _tileError) return;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _tileError = true);
                    });
                  },
                ),
                MarkerLayer(
                  markers: [
                    if (_pin != null)
                      Marker(
                        point: _pin!,
                        width: 40,
                        height: 40,
                        alignment: Alignment.topCenter,
                        child: Iconify(
                          AppUiIcons.map_marker,
                          size: 34,
                          color: AppColors.brandRed,
                        ),
                      ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(
                        Uri.parse('https://www.openstreetmap.org/copyright'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_tileError)
            MaterialBanner(
              content: const Text(
                'Map could not load. Check your connection and retry.',
              ),
              actions: [
                TextButton(
                  onPressed: () => setState(() {
                    _tileError = false;
                    _mapAttempt++;
                  }),
                  child: const Text('Retry'),
                ),
              ],
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
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
                  onPressed: _pin == null || _tileError
                      ? null
                      : () {
                          Navigator.of(
                            context,
                          ).pop([_pin!.latitude, _pin!.longitude]);
                        },
                  child: const Text('Confirm Location'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 4: category-specific ────────────────────────────────────────────

class _CategoryDetailsStep extends StatefulWidget {
  const _CategoryDetailsStep({required this.draft, required this.onChanged});

  final ListingDraft draft;
  final VoidCallback onChanged;

  @override
  State<_CategoryDetailsStep> createState() => _CategoryDetailsStepState();
}

class _CategoryDetailsStepState extends State<_CategoryDetailsStep> {
  static const _specializations = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Dentist',
    'Orthopedic',
    'Pediatrician',
    'Gynecologist',
    'ENT Specialist',
    'Neurologist',
    'Psychiatrist',
    'General Surgeon',
    'Eye Specialist',
    'Urologist',
    'Gastroenterologist',
    'Homeopathy',
    'Ayurvedic',
    'Other',
  ];

  static const _amenityOptions = [
    'Wi-Fi',
    'Parking',
    'AC',
    'Restaurant',
    'Room Service',
    'Pool',
    'Power Backup',
    'Banquet Hall',
    'Gym',
    'Breakfast Included',
  ];

  final _serviceController = TextEditingController();

  @override
  void dispose() {
    _serviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        if (draft.isDoctor) ..._doctorFields(draft),
        if (draft.isRestaurant) ..._restaurantFields(draft),
        if (draft.isHotel) ..._hotelFields(draft),
        if (draft.isSalon) ..._salonFields(draft),
        if (!draft.isDoctor &&
            !draft.isRestaurant &&
            !draft.isHotel &&
            !draft.isSalon)
          _genericFields(draft),
      ],
    );
  }

  List<Widget> _doctorFields(ListingDraft draft) => [
    Text('Specialization *', style: AppTypography.titleSm),
    const SizedBox(height: 8),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final spec in _specializations)
          ChoiceChip(
            label: Text(spec),
            selected: draft.specialization == spec,
            onSelected: (v) {
              setState(() => draft.specialization = spec);
              widget.onChanged();
            },
            selectedColor: AppColors.primarySoft,
            labelStyle: TextStyle(
              color: draft.specialization == spec
                  ? AppColors.primaryDark
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
      ],
    ),
    const SizedBox(height: 14),
    _Field(
      label: 'Qualification',
      value: draft.qualification ?? '',
      onChanged: (v) => draft.qualification = v,
      hint: 'e.g. MBBS, MS (Orthopaedics)',
    ),
    const SizedBox(height: 12),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Field(
            label: 'Experience (years)',
            value: (draft.experienceYears ?? '').toString(),
            onChanged: (v) => draft.experienceYears = int.tryParse(v) ?? 0,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Field(
            label: 'Consultation Fee',
            value: draft.consultationFee ?? '',
            onChanged: (v) => draft.consultationFee = v,
            hint: '₹300',
          ),
        ),
      ],
    ),
  ];

  List<Widget> _restaurantFields(ListingDraft draft) => [
    _Field(
      label: 'Cuisines',
      value: draft.cuisine ?? '',
      onChanged: (v) => draft.cuisine = v,
      hint: 'e.g. Mughlai · Awadhi · North Indian',
    ),
    const SizedBox(height: 12),
    _Field(
      label: 'Price Range',
      value: draft.priceRange ?? '',
      onChanged: (v) => draft.priceRange = v,
      hint: 'e.g. ₹200–₹600 for two',
    ),
    const SizedBox(height: 14),
    Text('Kitchen type', style: AppTypography.titleSm),
    const SizedBox(height: 8),
    Wrap(
      spacing: 8,
      children: [
        for (final (type, label) in [
          ('veg', 'Pure Veg'),
          ('non_veg', 'Non-Veg'),
          ('mixed', 'Both'),
        ])
          ChoiceChip(
            label: Text(label),
            selected: draft.vegType == type,
            onSelected: (v) {
              setState(() => draft.vegType = type);
              widget.onChanged();
            },
            selectedColor: AppColors.primarySoft,
            labelStyle: TextStyle(
              color: draft.vegType == type
                  ? AppColors.primaryDark
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    ),
  ];

  List<Widget> _hotelFields(ListingDraft draft) => [
    _Field(
      label: 'Hotel Type',
      value: draft.hotelType ?? '',
      onChanged: (v) => draft.hotelType = v,
      hint: 'e.g. 3-Star, Boutique, Budget',
    ),
    const SizedBox(height: 12),
    _Field(
      label: 'Price Range / Starting Price',
      value: draft.priceRange ?? '',
      onChanged: (v) => draft.priceRange = v,
      hint: 'e.g. ₹1,400 / night',
    ),
    const SizedBox(height: 12),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Field(
            label: 'Check-in',
            value: draft.checkInTime ?? '',
            onChanged: (v) => draft.checkInTime = v,
            hint: '12:00',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Field(
            label: 'Check-out',
            value: draft.checkOutTime ?? '',
            onChanged: (v) => draft.checkOutTime = v,
            hint: '11:00',
          ),
        ),
      ],
    ),
    const SizedBox(height: 14),
    Text('Amenities', style: AppTypography.titleSm),
    const SizedBox(height: 8),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final amenity in _amenityOptions)
          FilterChip(
            label: Text(amenity),
            selected: draft.amenities.contains(amenity),
            onSelected: (v) {
              setState(
                () => v
                    ? draft.amenities.add(amenity)
                    : draft.amenities.remove(amenity),
              );
              widget.onChanged();
            },
            selectedColor: AppColors.primarySoft,
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: draft.amenities.contains(amenity)
                  ? AppColors.primaryDark
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
      ],
    ),
  ];

  List<Widget> _salonFields(ListingDraft draft) => [
    Text('Services you offer', style: AppTypography.titleSm),
    const SizedBox(height: 4),
    Text(
      'Add each service with its price (optional).',
      style: AppTypography.caption,
    ),
    const SizedBox(height: 10),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final service in draft.serviceNames)
          InputChip(
            label: Text(service),
            onDeleted: () {
              setState(() => draft.serviceNames.remove(service));
              widget.onChanged();
            },
            backgroundColor: AppColors.primarySoft,
            labelStyle: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    ),
    const SizedBox(height: 10),
    Row(
      children: [
        Expanded(
          child: TextField(
            controller: _serviceController,
            decoration: const InputDecoration(hintText: 'e.g. Haircut ₹200'),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () {
            final value = _serviceController.text.trim();
            if (value.length >= 2) {
              setState(() => draft.serviceNames.add(value));
              _serviceController.clear();
              widget.onChanged();
            }
          },
          icon: Iconify(AppUiIcons.plus, color: Colors.white, size: 15),
        ),
      ],
    ),
  ];

  Widget _genericFields(ListingDraft draft) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'No extra details needed for this category — your description, photos and contact information are what customers see.',
        style: AppTypography.caption,
      ),
    ],
  );
}

// ── Step 5: photos ───────────────────────────────────────────────────────

class _PhotosStep extends ConsumerStatefulWidget {
  const _PhotosStep({
    required this.files,
    required this.draft,
    required this.onChanged,
  });

  final List<XFile> files;
  final ListingDraft draft;
  final VoidCallback onChanged;

  @override
  ConsumerState<_PhotosStep> createState() => _PhotosStepState();
}

class _PhotosStepState extends ConsumerState<_PhotosStep> {
  List<XFile> get _files => widget.files;

  Future<void> _pick() async {
    if (_files.length >= 5) return;
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(
      maxWidth: 1200,
      imageQuality: 80,
      limit: 5,
    );
    if (!mounted || picked.isEmpty) return;
    setState(() => _files.addAll(picked.take(5 - _files.length)));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        Text(
          'Add up to 5 photos (first becomes the main photo).',
          style: AppTypography.caption,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: _files.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Pressable(
                onTap: _files.length >= 5 ? null : _pick,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Iconify(
                    AppUiIcons.image_plus,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
              );
            }
            final file = _files[index - 1];
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: FutureBuilder<Uint8List>(
                    future: file.readAsBytes(),
                    builder: (_, snapshot) => snapshot.hasData
                        ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _files.remove(file));
                      widget.onChanged();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Iconify(
                        AppUiIcons.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (index == 1)
                  Positioned(
                    bottom: 4,
                    left: 4,
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
            );
          },
        ),
      ],
    );
  }
}

// ── Step 6: review ───────────────────────────────────────────────────────

class _ReviewStep extends ConsumerWidget {
  const _ReviewStep({
    required this.draft,
    required this.submitting,
    required this.onSubmit,
  });

  final ListingDraft draft;
  final bool submitting;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        Text('Review Your Listing', style: AppTypography.titleSm),
        const SizedBox(height: 10),
        _ReviewCard(
          title: 'Business',
          rows: [
            ('Name', draft.businessName),
            ('Phone', draft.phone),
            if (draft.tagline.isNotEmpty) ('Tagline', draft.tagline),
            if (draft.openingHours.isNotEmpty) ('Hours', draft.openingHours),
          ],
        ),
        const SizedBox(height: 10),
        _ReviewCard(
          title: 'Address',
          rows: [
            ('Address', draft.address),
            if (draft.locality.isNotEmpty) ('Area', draft.locality),
            ('City', draft.cityName),
            (
              'Location',
              draft.bizLat != null
                  ? '${draft.bizLat!.toStringAsFixed(4)}, ${draft.bizLng!.toStringAsFixed(4)}'
                  : '—',
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ReviewCard(
          title: 'Category Details',
          rows: [
            if (draft.isDoctor) ...[
              ('Specialization', draft.specialization ?? '—'),
              if (draft.qualification?.isNotEmpty == true)
                ('Qualification', draft.qualification!),
              if (draft.consultationFee?.isNotEmpty == true)
                ('Fee', draft.consultationFee!),
            ],
            if (draft.isRestaurant) ...[
              ('Cuisine', draft.cuisine ?? '—'),
              (
                'Kitchen',
                switch (draft.vegType) {
                  'veg' => 'Pure Veg',
                  'non_veg' => 'Non-Veg',
                  _ => 'Both',
                },
              ),
            ],
            if (draft.isHotel) ...[
              ('Type', draft.hotelType ?? '—'),
              if (draft.priceRange?.isNotEmpty == true)
                ('Price', draft.priceRange!),
              if (draft.amenities.isNotEmpty)
                ('Amenities', draft.amenities.join(', ')),
            ],
            if (draft.isSalon && draft.serviceNames.isNotEmpty)
              ('Services', draft.serviceNames.join(', ')),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: submitting ? null : onSubmit,
            child: submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Submit for Review',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleSm),
          const SizedBox(height: 8),
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(label, style: AppTypography.label),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
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

// ── Success screen ───────────────────────────────────────────────────────

class SubmissionSuccessScreen extends ConsumerWidget {
  const SubmissionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.openGreenSoft,
                  shape: BoxShape.circle,
                ),
                child: Iconify(
                  AppUiIcons.check,
                  size: 37,
                  color: AppColors.openGreen,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Your request has been submitted successfully',
                textAlign: TextAlign.center,
                style: AppTypography.title.copyWith(fontSize: 19),
              ),
              const SizedBox(height: 10),
              Text(
                'Your business listing has been sent for review.\n'
                'After approval, it will be visible on CityBee.\n'
                'Review may take up to 24 hours.',
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.starAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'PENDING REVIEW',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.starAmber,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () {
                  // Refresh submissions and open the status screen.
                  ref.invalidate(mySubmissionsProvider);
                  context.go('/submission-status');
                },
                child: const Text('View Submission'),
              ),
              const SizedBox(height: 10),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                // Clear the whole stack back to the Home tab.
                onPressed: () => context.go('/'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── shared field + continue bar ──────────────────────────────────────────

class _Field extends StatefulWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.hint,
    this.showLabel = true,
    this.errorText,
    this.inputFormatters,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hint;
  final bool showLabel;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: AppTypography.label.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 5),
        ],
        TextField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
          ),
        ),
      ],
    );
  }
}

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({required this.enabled, required this.onNext});

  final bool enabled;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: enabled
                  ? AppColors.primary
                  : AppColors.textMuted,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: enabled ? onNext : null,
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
