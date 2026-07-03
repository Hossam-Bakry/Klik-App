part of 'edit_profile_cubit.dart';

enum EditProfileStatus { loading, loaded, loadFailure }

class EditProfileState extends Equatable {
  const EditProfileState({
    this.status = EditProfileStatus.loading,
    this.profile,
    this.errorMessage,
    this.isSaving = false,
    this.saveError,
    this.saved = false,
  });

  final EditProfileStatus status;

  /// The fetched (or, after [saved], last-saved) profile.
  final UserProfile? profile;
  final String? errorMessage;

  final bool isSaving;
  final String? saveError;

  /// True right after a successful save — the page reacts once, then this
  /// resets on the next [EditProfileCubit.save] call.
  final bool saved;

  EditProfileState copyWith({
    EditProfileStatus? status,
    UserProfile? profile,
    String? errorMessage,
    bool? isSaving,
    String? saveError,
    bool clearSaveError = false,
    bool? saved,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    errorMessage,
    isSaving,
    saveError,
    saved,
  ];
}
