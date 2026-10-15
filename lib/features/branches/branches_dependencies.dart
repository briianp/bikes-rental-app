import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:bikes_app/core/data/supabase_providers.dart';
import 'package:bikes_app/features/branches/data/datasources/branches_data_sources.dart';
import 'package:bikes_app/features/branches/data/repositories/branches_repository_impl.dart';
import 'package:bikes_app/features/branches/domain/repositories/branches_repository.dart';
import 'package:bikes_app/features/branches/domain/usecases/branch_use_cases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final branchesRemoteDataSourceProvider = Provider<BranchesRemoteDataSource>((
  ref,
) {
  if (ref.watch(useSupabaseProvider)) {
    return SupabaseBranchesRemoteDataSource(ref.watch(supabaseClientProvider));
  }
  return FakeBranchesRemoteDataSource(ref.watch(inMemoryDatabaseProvider));
});

final branchesRepositoryProvider = Provider<BranchesRepository>(
  (ref) => BranchesRepositoryImpl(ref.watch(branchesRemoteDataSourceProvider)),
);

final getBranchesUseCaseProvider = Provider<GetBranches>(
  (ref) => GetBranches(ref.watch(branchesRepositoryProvider)),
);

final saveBranchUseCaseProvider = Provider<SaveBranch>(
  (ref) => SaveBranch(ref.watch(branchesRepositoryProvider)),
);
