import 'package:bikes_app/features/branches/domain/entities/branch.dart';

abstract interface class BranchesRepository {
  Future<List<Branch>> getBranches();

  Future<Branch> createBranch(BranchDraft draft);

  Future<Branch> updateBranch(String id, BranchDraft draft);
}
