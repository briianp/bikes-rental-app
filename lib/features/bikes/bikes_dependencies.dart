import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:bikes_app/core/data/supabase_providers.dart';
import 'package:bikes_app/features/bikes/data/datasources/bikes_remote_data_source.dart';
import 'package:bikes_app/features/bikes/data/datasources/fake_bikes_remote_data_source.dart';
import 'package:bikes_app/features/bikes/data/datasources/supabase_bikes_remote_data_source.dart';
import 'package:bikes_app/features/bikes/data/repositories/bikes_repository_impl.dart';
import 'package:bikes_app/features/bikes/domain/repositories/bikes_repository.dart';
import 'package:bikes_app/features/bikes/domain/usecases/get_bike_by_code.dart';
import 'package:bikes_app/features/bikes/domain/usecases/get_bikes.dart';
import 'package:bikes_app/features/bikes/domain/usecases/save_bike.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bikesRemoteDataSourceProvider = Provider<BikesRemoteDataSource>((ref) {
  if (ref.watch(useSupabaseProvider)) {
    return SupabaseBikesRemoteDataSource(ref.watch(supabaseClientProvider));
  }
  return FakeBikesRemoteDataSource(ref.watch(inMemoryDatabaseProvider));
});

final bikesRepositoryProvider = Provider<BikesRepository>(
  (ref) => BikesRepositoryImpl(ref.watch(bikesRemoteDataSourceProvider)),
);

final getBikesUseCaseProvider = Provider<GetBikes>(
  (ref) => GetBikes(ref.watch(bikesRepositoryProvider)),
);

final getBikeByIdUseCaseProvider = Provider<GetBikeById>(
  (ref) => GetBikeById(ref.watch(bikesRepositoryProvider)),
);

final getBikeByCodeUseCaseProvider = Provider<GetBikeByCode>(
  (ref) => GetBikeByCode(ref.watch(bikesRepositoryProvider)),
);

final saveBikeUseCaseProvider = Provider<SaveBike>(
  (ref) => SaveBike(ref.watch(bikesRepositoryProvider)),
);
