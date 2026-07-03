import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/countries.dart';
import '../../../../core/constants/validators.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/edit_profile_cubit.dart';
import '../widgets/photo_source_sheet.dart';

/// Edit Profile (`GET`/`POST /api/[update-]profile`), reached from the
/// Profile header's edit badge.
///
/// Picking a photo from the device (camera or gallery) previews immediately
/// and is uploaded as multipart on Save — the API validates `profile_photo`
/// as an actual image file (jpg/jpeg/png/svg/webp/gif), not a URL.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  Country _country = Countries.defaultCountry;
  String _profilePhoto = '';
  File? _pickedPhoto;
  bool _prefilled = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _prefill(UserProfile profile) {
    if (_prefilled) return;
    _prefilled = true;
    _name.text = profile.name;
    _email.text = profile.email;
    _phone.text = profile.phone;
    _profilePhoto = profile.profilePhoto;
    _country = Countries.all.firstWhere(
      (c) => c.isoCode == profile.countryIso,
      orElse: () => Countries.defaultCountry,
    );
  }

  void _save(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<EditProfileCubit>().save(
      UserProfile(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        countryIso: _country.isoCode,
        countryCode: _country.dialCode,
        profilePhoto: _profilePhoto,
      ),
      photoFile: _pickedPhoto,
    );
  }

  Future<void> _changePhoto(BuildContext context) async {
    final source = await showPhotoSourceSheet(context);
    if (source == null || !context.mounted) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _pickedPhoto = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditProfileCubit, EditProfileState>(
      listenWhen: (p, c) => p.saved != c.saved || p.saveError != c.saveError,
      listener: (context, state) {
        if (state.saved) {
          AppToast.success(
            context,
            context.tr(LocaleKeys.profileUpdatedSuccessfully),
          );
          context.pop();
        } else if (state.saveError != null) {
          AppToast.error(context, state.saveError!);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: AppColors.textPrimary),
          title: Text(
            context.tr(LocaleKeys.editProfile),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<EditProfileCubit, EditProfileState>(
          buildWhen: (p, c) => p.status != c.status || p.profile != c.profile,
          builder: (context, state) {
            if (state.status == EditProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == EditProfileStatus.loadFailure) {
              return _ErrorView(
                message:
                    state.errorMessage ??
                    context.tr(LocaleKeys.somethingWentWrong),
              );
            }

            _prefill(state.profile!);

            return SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: context.edgeAll(20),
                  children: [
                    Center(
                      child: _AvatarPicker(
                        photoUrl: _profilePhoto,
                        localFile: _pickedPhoto,
                        onTap: () => _changePhoto(context),
                      ),
                    ),
                    context.gapH(10),
                    Center(
                      child: GestureDetector(
                        onTap: () => _changePhoto(context),
                        child: Text(
                          context.tr(LocaleKeys.changePhoto),
                          style: context.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    context.gapH(24),
                    AppTextField.name(
                      controller: _name,
                      hint: context.tr(LocaleKeys.fullName),
                      validator: Validators.name(context),
                    ),
                    context.gapH(14),
                    AppTextField.email(
                      controller: _email,
                      hint: context.tr(LocaleKeys.emailAddress),
                      validator: Validators.email(context),
                    ),
                    context.gapH(14),
                    AppTextField.phone(
                      controller: _phone,
                      hint: context.tr(LocaleKeys.phoneNumber),
                      country: _country,
                      onCountryChanged: (c) => setState(() => _country = c),
                    ),
                    context.gapH(24),
                    BlocBuilder<EditProfileCubit, EditProfileState>(
                      buildWhen: (p, c) => p.isSaving != c.isSaving,
                      builder: (context, state) => AppButton.filled(
                        label: context.tr(LocaleKeys.saveChanges),
                        isLoading: state.isSaving,
                        onPressed: state.isSaving
                            ? null
                            : () => _save(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.photoUrl,
    required this.onTap,
    this.localFile,
  });

  final String photoUrl;

  /// A just-picked device photo, previewed ahead of (not-yet-implemented)
  /// upload — takes priority over [photoUrl] when set.
  final File? localFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = context.r(110);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(context.r(3)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipOval(
              child: localFile != null
                  ? Image.file(
                      localFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : photoUrl.isEmpty
                  ? Container(
                      color: AppColors.inputLabel,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.person,
                        size: context.r(48),
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    )
                  : AppNetworkImage(url: photoUrl),
            ),
          ),
          Positioned(
            right: context.r(2),
            bottom: context.r(2),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                padding: context.edgeAll(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: context.r(16),
                  color: AppColors.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.edgeAll(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: context.r(48),
              color: AppColors.textSecondary,
            ),
            context.gapH(12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.sp(14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
