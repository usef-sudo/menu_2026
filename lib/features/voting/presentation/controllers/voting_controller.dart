import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/network/safe_request.dart";

class VotingController
    extends AutoDisposeFamilyAsyncNotifier<Map<String, int>, String> {
  @override
  Future<Map<String, int>> build(String arg) async {
    final result = await safeRequest<Map<String, int>>(
      () => ref.read(menuApiProvider).getBranchVotes(arg),
    );
    return result.when(
      success: (Map<String, int> data) => data,
      failure: (failure) => throw failure,
    );
  }

  Future<void> vote(int value) async {
    final branchId = arg;
    await safeRequest<void>(
      () => ref.read(menuApiProvider).voteForBranch(branchId, value),
    );
    state = await AsyncValue.guard(
      () => ref.read(menuApiProvider).getBranchVotes(branchId),
    );
  }
}

final votingControllerProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      VotingController,
      Map<String, int>,
      String
    >(VotingController.new);
