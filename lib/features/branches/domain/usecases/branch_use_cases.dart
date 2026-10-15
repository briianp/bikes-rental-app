import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/features/branches/domain/entities/branch.dart';
import 'package:bikes_app/features/branches/domain/repositories/branches_repository.dart';

class GetBranches {
  const GetBranches(this._repository);

  final BranchesRepository _repository;

  Future<List<Branch>> call() => _repository.getBranches();
}

/// Crea una sucursal (si [id] es `null`) o la actualiza.
class SaveBranch {
  const SaveBranch(this._repository);

  final BranchesRepository _repository;

  Future<Branch> call(BranchDraft draft, {String? id}) async {
    final name = draft.name.trim();
    if (name.isEmpty) {
      throw const ValidationFailure('El nombre de la sucursal es obligatorio.');
    }
    final address = draft.address?.trim();
    final clean = BranchDraft(
      name: name,
      address: (address == null || address.isEmpty) ? null : address,
      isActive: draft.isActive,
    );
    return id == null
        ? _repository.createBranch(clean)
        : _repository.updateBranch(id, clean);
  }
}
