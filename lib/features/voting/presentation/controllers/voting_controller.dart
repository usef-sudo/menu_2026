import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:menu_2026/core/network/menu_api.dart";
import "package:menu_2026/core/network/safe_request.dart";
import "package:menu_2026/features/voting/domain/branch_vote_state.dart";

class VotingController
    extends AutoDisposeFamilyAsyncNotifier<BranchVoteState, String> {
  bool _busy = false;
  int? _queued;

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
    if (value != 1 && value != -1) {
      return false;
    }
    final BranchVoteState? current = state.valueOrNull;
    if (current == null) {
      return false;
    }
    if (current.userVote == value) {
      return true;
    }

    state = AsyncData(current.applyVote(value));
    if (_busy) {
      _queued = value;
      return true;
    }

    _busy = true;
    try {
      while (true) {
        final int toSend = _queued ?? value;
        _queued = null;
        final result = await safeRequest<BranchVoteState>(
          () => ref.read(menuApiProvider).voteForBranch(arg, toSend),
        );
        final bool morePending = _queued != null;
        final bool ok = result.when(
          success: (BranchVoteState summary) {
            if (!morePending) {
              state = AsyncData(summary);
            }
            return true;
          },
          failure: (_) => false,
        );
        if (!ok) {
          ref.invalidateSelf();
          return false;
        }
        if (!morePending) {
          return true;
        }
      }
    } finally {
      _busy = false;
    }
  }
}

final votingControllerProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      VotingController,
      BranchVoteState,
      String
    >(VotingController.new);
