import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'edit_profile_state.dart';

/// Page-scoped Cubit for Edit Profile: loads the current profile on
/// construction (to pre-fill the form), then submits edits via [save].
class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._repository) : super(const EditProfileState()) {
    _load();
  }

  final ProfileRepository _repository;

  Future<void> _load() async {
    final result = await _repository.getProfile();
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: EditProfileStatus.loaded, profile: data));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: EditProfileStatus.loadFailure,
          errorMessage: failure.message,
        ));
    }
  }

  Future<void> save(UserProfile updated, {File? photoFile}) async {
    emit(state.copyWith(isSaving: true, clearSaveError: true, saved: false));
    final result = await _repository.updateProfile(
      updated,
      photoFile: photoFile,
    );
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(isSaving: false, profile: data, saved: true));
      case ApiFailure(:final failure):
        emit(state.copyWith(isSaving: false, saveError: failure.message));
    }
  }
}
