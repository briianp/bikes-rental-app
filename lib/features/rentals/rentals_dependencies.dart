import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:bikes_app/core/data/supabase_providers.dart';
import 'package:bikes_app/features/bikes/bikes_dependencies.dart';
import 'package:bikes_app/features/rentals/data/datasources/fake_rentals_remote_data_source.dart';
import 'package:bikes_app/features/rentals/data/datasources/rentals_remote_data_source.dart';
import 'package:bikes_app/features/rentals/data/datasources/supabase_rentals_remote_data_source.dart';
import 'package:bikes_app/features/rentals/data/repositories/rentals_repository_impl.dart';
import 'package:bikes_app/features/rentals/domain/repositories/rentals_repository.dart';
import 'package:bikes_app/features/rentals/domain/usecases/finish_rental.dart';
import 'package:bikes_app/features/rentals/domain/usecases/get_active_rentals.dart';
import 'package:bikes_app/features/rentals/domain/usecases/get_rental_by_id.dart';
import 'package:bikes_app/features/rentals/domain/usecases/get_rental_history.dart';
import 'package:bikes_app/features/rentals/domain/usecases/scan_bike.dart';
import 'package:bikes_app/features/rentals/domain/usecases/start_rental.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rentalsRemoteDataSourceProvider = Provider<RentalsRemoteDataSource>((
  ref,
) {
  if (ref.watch(useSupabaseProvider)) {
    return SupabaseRentalsRemoteDataSource(ref.watch(supabaseClientProvider));
  }
  return FakeRentalsRemoteDataSource(ref.watch(inMemoryDatabaseProvider));
});

final rentalsRepositoryProvider = Provider<RentalsRepository>(
  (ref) => RentalsRepositoryImpl(ref.watch(rentalsRemoteDataSourceProvider)),
);

final getActiveRentalsUseCaseProvider = Provider<GetActiveRentals>(
  (ref) => GetActiveRentals(ref.watch(rentalsRepositoryProvider)),
);

final getRentalHistoryUseCaseProvider = Provider<GetRentalHistory>(
  (ref) => GetRentalHistory(ref.watch(rentalsRepositoryProvider)),
);

final getRentalByIdUseCaseProvider = Provider<GetRentalById>(
  (ref) => GetRentalById(ref.watch(rentalsRepositoryProvider)),
);

final startRentalUseCaseProvider = Provider<StartRental>(
  (ref) => StartRental(
    rentalsRepository: ref.watch(rentalsRepositoryProvider),
    bikesRepository: ref.watch(bikesRepositoryProvider),
  ),
);

final finishRentalUseCaseProvider = Provider<FinishRental>(
  (ref) => FinishRental(ref.watch(rentalsRepositoryProvider)),
);

final scanBikeUseCaseProvider = Provider<ScanBike>(
  (ref) => ScanBike(
    bikesRepository: ref.watch(bikesRepositoryProvider),
    rentalsRepository: ref.watch(rentalsRepositoryProvider),
  ),
);
