import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/sub_page_scaffold.dart';
import '../../../data/mock/mock_data.dart';
import '../../../domain/models/user_profile.dart';
import '../../../providers/app_providers.dart';

/// Edit Profile: avatar picker, name, phone. EMAIL IS READ-ONLY — it is the
/// account identity from Supabase Auth and cannot be changed here (changing
/// it would break sign-in identity).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final UserProfile _initial;
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late String _avatar;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initial = ref.read(userProfileProvider);
    _name = TextEditingController(text: _initial.name);
    _phone = TextEditingController(text: _initial.phone);
    _avatar = _initial.avatarImage;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _hasChanges =>
      _name.text != _initial.name ||
      _phone.text != _initial.phone ||
      _avatar != _initial.avatarImage;

  Future<void> _save() async {
    if (!_hasChanges || _saving) return;
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name can’t be empty')),
      );
      return;
    }
    setState(() => _saving = true);
    // Email is intentionally NOT sent — it comes from the auth identity
    // and must never be overwritten from the profile editor.
    await ref.read(userProfileProvider.notifier).save(
          _initial.copyWith(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            avatarImage: _avatar,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
    Navigator.of(context).maybePop();
  }

  Future<void> _pickAvatar() {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose a profile photo', style: AppTypography.title),
              const SizedBox(height: 14),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: mockAvatarChoices.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final url = mockAvatarChoices[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _avatar = url);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: url == _avatar ? AppColors.primary : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: AppAvatar(url: url, radius: 34),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Edit Profile',
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          children: [
            // ── Avatar ─────────────────────────────────────────────
            GestureDetector(
              onTap: _pickAvatar,
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2.5),
                ),
                child: Stack(
                  children: [
                    AppAvatar(url: _avatar, radius: 44),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit_rounded,
                            size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Tap photo to change', style: AppTypography.label),

            // ── Form ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    _ProfileField(
                      controller: _name,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    _ProfileField(
                      controller: _phone,
                      label: 'Phone Number (optional)',
                      icon: Icons.phone_iphone_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    // Read-only email: account identity from Supabase Auth.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email Address',
                            style: AppTypography.label),
                        const SizedBox(height: 6),
                        TextField(
                          controller: TextEditingController(text: _initial.email),
                          readOnly: true,
                          enabled: false,
                          style: AppTypography.body
                              .copyWith(color: AppColors.textSecondary),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                size: 18, color: AppColors.textMuted),
                            suffixIcon: const Tooltip(
                              message: 'Email is your account identity and cannot be changed',
                              child: Icon(Icons.info_outline_rounded,
                                  size: 18, color: AppColors.textMuted),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 13),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.border, width: 1.1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
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
            onPressed: _hasChanges && !_saving ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save Changes',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTypography.body,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.background,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1.1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
