class BranchVoteState {
  const BranchVoteState({
    required this.upVotes,
    required this.downVotes,
    this.userVote,
  });

  final int upVotes;
  final int downVotes;

  /// `1` = upvote, `-1` = downvote, `null` = no vote yet.
  final int? userVote;

  bool get hasUpvoted => userVote == 1;
  bool get hasDownvoted => userVote == -1;

  BranchVoteState copyWith({
    int? upVotes,
    int? downVotes,
    int? userVote,
    bool clearUserVote = false,
  }) {
    return BranchVoteState(
      upVotes: upVotes ?? this.upVotes,
      downVotes: downVotes ?? this.downVotes,
      userVote: clearUserVote ? null : (userVote ?? this.userVote),
    );
  }

  /// Instantly apply a 1 / -1 vote to the visible counts.
  BranchVoteState applyVote(int value) {
    if (value != 1 && value != -1) {
      return this;
    }
    if (userVote == value) {
      return this;
    }
    int nextUp = upVotes;
    int nextDown = downVotes;
    if (userVote == 1) {
      nextUp = nextUp > 0 ? nextUp - 1 : 0;
    } else if (userVote == -1) {
      nextDown = nextDown > 0 ? nextDown - 1 : 0;
    }
    if (value == 1) {
      nextUp += 1;
    } else {
      nextDown += 1;
    }
    return BranchVoteState(
      upVotes: nextUp,
      downVotes: nextDown,
      userVote: value,
    );
  }

  factory BranchVoteState.fromJson(Map<String, dynamic> json) {
    int? parseUserVote(dynamic raw) {
      if (raw == null) {
        return null;
      }
      final int? parsed = int.tryParse(raw.toString());
      if (parsed == 1 || parsed == -1) {
        return parsed;
      }
      return null;
    }

    return BranchVoteState(
      upVotes: int.tryParse(
            (json["upVotes"] ?? json["up"] ?? 0).toString(),
          ) ??
          0,
      downVotes: int.tryParse(
            (json["downVotes"] ?? json["down"] ?? 0).toString(),
          ) ??
          0,
      userVote: parseUserVote(json["userVote"] ?? json["user_vote"]),
    );
  }
}
