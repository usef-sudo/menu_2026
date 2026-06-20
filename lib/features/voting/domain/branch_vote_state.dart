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
      userVote: parseUserVote(json["userVote"]),
    );
  }
}
