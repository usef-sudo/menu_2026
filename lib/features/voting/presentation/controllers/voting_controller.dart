import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/network/safe_request.dart";
import "package:menu_2026/features/voting/domain/branch_vote_state.dart";

class VotingController
    extends AutoDisposeFamilyAsyncNotifier<BranchVoteState, String> {
  @override
  Future<BranchVoteState> build(String arg) async {
    final result = await safeRequest<BranchVoteState>(
      () => ref.read(menuApiProvider).getBranchVotes(arg),
    );
    return result.when(
      success: (BranchVoteState data) => data,
      failure: (failure) => throw failure,
    );
  }

  Future<bool> vote(int value) async {
    final String branchId = arg;
    final result = await safeRequest<BranchVoteState>(
      () => ref.read(menuApiProvider).voteForBranch(branchId, value),
    );

    return result.when(
      success: (BranchVoteState summary) {
        state = AsyncData(summary);
        return true;
      },
      failure: (_) => false,
    );
  }
}

final votingControllerProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      VotingController,
      BranchVoteState,
      String
    >(VotingController.new);
