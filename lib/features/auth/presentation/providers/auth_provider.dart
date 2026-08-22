import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/profile_model.dart';
import '../../data/repositories/auth_repository.dart';

// ── Repository provider ───────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// ── Raw Supabase auth stream ──────────────────────────────────────────────

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).maybeWhen(
    data: (state) => state.session != null,
    orElse: () => false,
  );
});

// ── Current profile ───────────────────────────────────────────────────────

class CurrentProfileNotifier extends Notifier<ProfileModel?> {
  @override
  ProfileModel? build() {
    _init();
    return null;
  }

  Future<void> _init() async {
    final profile = await ref.read(authRepositoryProvider).fetchCurrentProfile();
    state = profile;
  }

  void setProfile(ProfileModel profile) => state = profile;
  void clear() => state = null;
}

final currentProfileProvider =
    NotifierProvider<CurrentProfileNotifier, ProfileModel?>(
  CurrentProfileNotifier.new,
);

// ── Passenger auth ────────────────────────────────────────────────────────

class PassengerAuthNotifier extends Notifier<AsyncValue<ProfileModel?>> {
  @override
  AsyncValue<ProfileModel?> build() => const AsyncValue.data(null);

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profile = await ref
          .read(authRepositoryProvider)
          .signInPassenger(email: email, password: password);
      ref.read(currentProfileProvider.notifier).setProfile(profile);
      return profile;
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profile = await ref
          .read(authRepositoryProvider)
          .signUpPassenger(email: email, password: password, fullName: fullName);
      ref.read(currentProfileProvider.notifier).setProfile(profile);
      return profile;
    });
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    ref.read(currentProfileProvider.notifier).clear();
    state = const AsyncValue.data(null);
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(authRepositoryProvider).resetPassword(email).then((_) => null));
  }
}

final passengerAuthProvider =
    NotifierProvider<PassengerAuthNotifier, AsyncValue<ProfileModel?>>(
  PassengerAuthNotifier.new,
);

// ── Driver auth ───────────────────────────────────────────────────────────

class DriverAuthNotifier extends Notifier<AsyncValue<ProfileModel?>> {
  @override
  AsyncValue<ProfileModel?> build() => const AsyncValue.data(null);

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profile = await ref
          .read(authRepositoryProvider)
          .signInDriver(email: email, password: password);
      ref.read(currentProfileProvider.notifier).setProfile(profile);
      return profile;
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String licenseNumber,
    String? vehicleModel,
    String? plateNumber,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profile = await ref.read(authRepositoryProvider).signUpDriver(
            email: email,
            password: password,
            fullName: fullName,
            licenseNumber: licenseNumber,
            vehicleModel: vehicleModel,
            platNumber: plateNumber,
          );
      ref.read(currentProfileProvider.notifier).setProfile(profile);
      return profile;
    });
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    ref.read(currentProfileProvider.notifier).clear();
    state = const AsyncValue.data(null);
  }
}

final driverAuthProvider =
    NotifierProvider<DriverAuthNotifier, AsyncValue<ProfileModel?>>(
  DriverAuthNotifier.new,
);

// ── Admin auth ────────────────────────────────────────────────────────────

class AdminAuthNotifier extends Notifier<AsyncValue<ProfileModel?>> {
  @override
  AsyncValue<ProfileModel?> build() => const AsyncValue.data(null);

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profile = await ref
          .read(authRepositoryProvider)
          .signInAdmin(email: email, password: password);
      ref.read(currentProfileProvider.notifier).setProfile(profile);
      return profile;
    });
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    ref.read(currentProfileProvider.notifier).clear();
    state = const AsyncValue.data(null);
  }
}

final adminAuthProvider =
    NotifierProvider<AdminAuthNotifier, AsyncValue<ProfileModel?>>(
  AdminAuthNotifier.new,
);
