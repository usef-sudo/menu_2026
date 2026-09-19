import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/features/reviews/domain/entities/review_entity.dart";
import "package:menu_2026/features/reviews/presentation/controllers/reviews_controller.dart";
import "package:menu_2026/l10n/app_localizations.dart";

ReviewEntity? findMyReview(List<ReviewEntity> reviews, String? userId) {
  if (userId == null || userId.isEmpty) {
    return null;
  }
  for (final ReviewEntity review in reviews) {
    if (review.userId == userId) {
      return review;
    }
  }
  return null;
}

Future<void> showReviewFormSheet(
  BuildContext context, {
  required String branchId,
  required String restaurantId,
  int? initialRating,
  String? initialComment,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) {
      return ReviewFormSheet(
        branchId: branchId,
        restaurantId: restaurantId,
        initialRating: initialRating,
        initialComment: initialComment,
      );
    },
  );
}

class ReviewsSummaryHeader extends StatelessWidget {
  const ReviewsSummaryHeader({
    required this.avgRating,
    required this.total,
    super.key,
  });

  final double avgRating;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              avgRating > 0 ? avgRating.toStringAsFixed(1) : l10n.emDash,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: List<Widget>.generate(5, (int index) {
                final double threshold = index + 1;
                final IconData icon;
                if (avgRating >= threshold) {
                  icon = Icons.star;
                } else if (avgRating >= threshold - 0.5) {
                  icon = Icons.star_half;
                } else {
                  icon = Icons.star_border;
                }
                return Icon(icon, color: Colors.amber, size: 18);
              }),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Text(l10n.reviewsCount(total), style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class WriteReviewButton extends StatelessWidget {
  const WriteReviewButton({
    required this.branchId,
    required this.restaurantId,
    required this.isLoggedIn,
    this.existingReview,
    super.key,
  });

  final String branchId;
  final String restaurantId;
  final bool isLoggedIn;
  final ReviewEntity? existingReview;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final bool hasMine = existingReview != null;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      onPressed: () {
        if (!isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.reviewLoginRequired)),
          );
          context.push("/auth/login");
          return;
        }
        showReviewFormSheet(
          context,
          branchId: branchId,
          restaurantId: restaurantId,
          initialRating: existingReview?.rating,
          initialComment: existingReview?.comment,
        );
      },
      icon: Icon(hasMine ? Icons.edit_outlined : Icons.rate_review_outlined),
      label: Text(
        !isLoggedIn
            ? l10n.restaurantLoginToWriteReview
            : hasMine
                ? l10n.reviewEditReview
                : l10n.restaurantWriteReview,
      ),
    );
  }
}

class UserReviewCard extends ConsumerWidget {
  const UserReviewCard({
    required this.review,
    required this.branchId,
    required this.restaurantId,
    required this.isMine,
    super.key,
  });

  final ReviewEntity review;
  final String branchId;
  final String restaurantId;
  final bool isMine;

  Future<void> _edit(BuildContext context) {
    return showReviewFormSheet(
      context,
      branchId: branchId,
      restaurantId: restaurantId,
      initialRating: review.rating,
      initialComment: review.comment,
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = context.l10n;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.commonDelete),
        content: Text(l10n.reviewDeleteConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final bool success = await ref
        .read(reviewsControllerProvider(branchId).notifier)
        .deleteMyReview(
          branchId: branchId,
          restaurantId: restaurantId,
        );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? l10n.reviewDeleted : l10n.reviewDeleteFailed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 14,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : "?",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      review.userName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isMine)
                      Text(
                        l10n.reviewYours,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: List<Widget>.generate(
                        5,
                        (int index) => Icon(
                          index < review.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isMine)
                PopupMenuButton<_ReviewOwnerAction>(
                  tooltip: l10n.reviewEditReview,
                  onSelected: (_ReviewOwnerAction action) {
                    switch (action) {
                      case _ReviewOwnerAction.edit:
                        _edit(context);
                      case _ReviewOwnerAction.delete:
                        _delete(context, ref);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<_ReviewOwnerAction>>[
                    PopupMenuItem<_ReviewOwnerAction>(
                      value: _ReviewOwnerAction.edit,
                      child: Text(l10n.reviewEdit),
                    ),
                    PopupMenuItem<_ReviewOwnerAction>(
                      value: _ReviewOwnerAction.delete,
                      child: Text(l10n.commonDelete),
                    ),
                  ],
                ),
            ],
          ),
          if (review.comment.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(review.comment, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

enum _ReviewOwnerAction { edit, delete }

class ReviewFormSheet extends ConsumerStatefulWidget {
  const ReviewFormSheet({
    required this.branchId,
    required this.restaurantId,
    this.initialRating,
    this.initialComment,
    super.key,
  });

  final String branchId;
  final String restaurantId;
  final int? initialRating;
  final String? initialComment;

  @override
  ConsumerState<ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends ConsumerState<ReviewFormSheet> {
  late int _rating;
  late final TextEditingController _commentController;
  bool _submitting = false;

  bool get _isEditing => widget.initialRating != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 5;
    _commentController =
        TextEditingController(text: widget.initialComment ?? "");
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating < 1 || _rating > 5) {
      return;
    }
    setState(() {
      _submitting = true;
    });
    final bool success = await ref
        .read(reviewsControllerProvider(widget.branchId).notifier)
        .submitReview(
          branchId: widget.branchId,
          restaurantId: widget.restaurantId,
          rating: _rating,
          comment: _commentController.text.trim(),
        );
    if (!mounted) {
      return;
    }
    final AppLocalizations l10n = context.l10n;
    setState(() {
      _submitting = false;
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (_isEditing ? l10n.reviewUpdated : l10n.reviewSubmitted)
              : l10n.reviewSubmitFailed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: mediaQuery.viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            _isEditing ? l10n.reviewEditReview : l10n.rateThisBranch,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List<Widget>.generate(5, (int index) {
              final int starValue = index + 1;
              return IconButton(
                onPressed: () {
                  setState(() {
                    _rating = starValue;
                  });
                },
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.reviewCommentOptional,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
              ),
              onPressed: _submitting ? null : _submit,
              child: Text(
                _submitting
                    ? l10n.reviewSubmitting
                    : (_isEditing ? l10n.reviewSaveChanges : l10n.submitReview),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
