import 'package:bikes_app/core/error/api_exception.dart';
import 'package:bikes_app/features/branches/data/datasources/branches_data_sources.dart';
import 'package:bikes_app/features/branches/data/models/branch_model.dart';
import 'package:bikes_app/features/branches/domain/entities/branch.dart';
import 'package:bikes_app/features/branches/domain/repositories/branches_repository.dart';

class BranchesRepositoryImpl implements BranchesRepository {
  const BranchesRepositoryImpl(this._remoteDataSource);

  final BranchesRemoteDataSource _remoteDataSource;

  @override
  Future<List<Branch>> getBranches() => guardApiCall(() async {
    final rows = await _remoteDataSource.getBranches();
    return rows.map(BranchModel.fromJson).toList();
  });

  @override
  Future<Branch> createBranch(BranchDraft draft) => guardApiCall(() async {
    final row = await _remoteDataSource.createBranch(BranchModel.toJson(draft));
    return BranchModel.fromJson(row);
  });

  @override
  Future<Branch> updateBranch(String id, BranchDraft draft) =>
      guardApiCall(() async {
        final row = await _remoteDataSource.updateBranch(
          id,
          BranchModel.toJson(draft),
        );
        return BranchModel.fromJson(row);
      });
}
