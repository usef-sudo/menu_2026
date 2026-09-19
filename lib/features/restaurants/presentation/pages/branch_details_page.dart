import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:menu_2026/core/auth/jwt_user_id.dart";
import "package:menu_2026/core/auth/session_controller.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/theme/tokens/app_radii.dart";
import "package:menu_2026/core/utils/phone_launcher.dart";
import "package:menu_2026/features/branches/domain/entities/branch_entity.dart";
import "package:menu_2026/features/branches/domain/entities/branch_opening_hour.dart";
import "package:menu_2026/features/branches/presentation/controllers/branches_controller.dart";
import "package:menu_2026/features/profile/presentation/controllers/user_profile_controller.dart";
import "package:menu_2026/features/restaurants/domain/entities/menu_image_entity.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/menu_images_controller.dart";
import "package:menu_2026/features/restaurants/presentation/controllers/restaurant_details_controller.dart";
import "package:menu_2026/features/restaurants/presentation/widgets/menu_flip_book_viewer.dart";
import "package:menu_2026/features/restaurants/presentation/widgets/restaurant_external_links.dart";
import "package:menu_2026/features/reviews/domain/entities/review_entity.dart";
import "package:menu_2026/features/reviews/presentation/controllers/reviews_controller.dart";
import "package:menu_2026/features/reviews/presentation/widgets/user_review_widgets.dart";
import "package:menu_2026/features/voting/domain/branch_vote_state.dart";
import "package:menu_2026/features/voting/presentation/controllers/voting_controller.dart";
import "package:url_launcher/url_launcher.dart";

class BranchDetailsPage extends ConsumerWidget {
  const BranchDetailsPage({required this.branch, super.key});

  final BranchWithDistance branch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String lang = Localizations.localeOf(context).languageCode;
    final String branchTitle =
        (lang == "ar" && branch.branch.nameAr.isNotEmpty)
            ? branch.branch.nameAr
            : (branch.branch.nameEn.isNotEmpty
                ? branch.branch.nameEn
                : branch.branch.nameAr);
    final AsyncValue<BranchVoteState> votes =
        ref.watch(votingControllerProvider(branch.branch.id));
    final RestaurantDetailsState? restaurantDetails = ref
        .watch(restaurantDetailsControllerProvider(branch.branch.restaurantId))
        .valueOrNull;
    final String restaurantPhone = restaurantDetails?.phone.trim() ?? "";
    final String branchPhone = branch.branch.phone?.trim() ?? "";
    final String phone =
        branchPhone.isNotEmpty ? branchPhone : restaurantPhone;
    final bool openNow = branch.branch.isEffectivelyOpenNow();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(branchTitle),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[

          _BranchContactCard(
            branch: branch,
            openNow: openNow,
            phone: phone,
            onCall: () => _callBranch(context, phone),
            onNavigate: () => _openMaps(branch),
          ),
          if (restaurantDetails != null &&
              RestaurantExternalLinks.hasAny(
                websiteUrl: restaurantDetails.websiteUrl,
                instagramUrl: restaurantDetails.instagramUrl,
                facebookUrl: restaurantDetails.facebookUrl,
                talabatUrl: restaurantDetails.talabatUrl,
                careemUrl: restaurantDetails.careemUrl,
              )) ...<Widget>[
            const SizedBox(height: 12),
            RestaurantExternalLinks(
              websiteUrl: restaurantDetails.websiteUrl,
              instagramUrl: restaurantDetails.instagramUrl,
              facebookUrl: restaurantDetails.facebookUrl,
              talabatUrl: restaurantDetails.talabatUrl,
              careemUrl: restaurantDetails.careemUrl,
              inCard: true,
            ),
          ],
          const SizedBox(height: 12),

          _ViewMenuButton(branchId: branch.branch.id),

          const SizedBox(height: 12),
          _OpeningHoursExpandableCard(branch: branch),
          const SizedBox(height: 12),
          _FacilitiesSection(branch: branch),
          const SizedBox(height: 12),
          _VotesSummaryCard(
            branchId: branch.branch.id,
            votes: votes,
          ),
          const SizedBox(height: 12),
          _BranchReviewsSection(
            branchId: branch.branch.id,
            restaurantId: branch.branch.restaurantId,
          ),
        ],
      ),
    );
  }

  Future<void> _callBranch(BuildContext context, String phone) async {
    final l10n = context.l10n;
    final bool ok = await launchPhoneCall(context, phone);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.branchNoPhone)),
      );
    }
  }

  Future<void> _openMaps(BranchWithDistance b) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=${b.branch.latitude},${b.branch.longitude}",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _BranchContactCard extends StatelessWidget {
  const _BranchContactCard({
    required this.branch,
    required this.openNow,
    required this.phone,
    required this.onCall,
    required this.onNavigate,
  });

  final BranchWithDistance branch;
  final bool openNow;
  final String phone;
  final VoidCallback onCall;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final bool hasPhone = phone.isNotEmpty;
    final String address = branch.branch.address.trim();

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _StatusChip(openNow: openNow),
              const Spacer(),
              Icon(
                Icons.near_me_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.distanceKm(branch.distanceKm.toStringAsFixed(1)),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 16),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: <Widget>[
          //     Container(
          //       width: 44,
          //       height: 44,
          //       decoration: BoxDecoration(
          //         color: theme.colorScheme.primaryContainer,
          //         borderRadius: BorderRadius.circular(AppRadii.md),
          //       ),
          //       child: Icon(
          //         Icons.place_rounded,
          //         color: theme.colorScheme.onPrimaryContainer,
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: <Widget>[
          //           Text(
          //             l10n.branchAddressLabel,
          //             style: theme.textTheme.labelMedium?.copyWith(
          //               color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //           const SizedBox(height: 4),
          //           Text(
          //             address.isNotEmpty ? address : "—",
          //             style: theme.textTheme.bodyLarge?.copyWith(
          //               fontWeight: FontWeight.w600,
          //               height: 1.35,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  onPressed: hasPhone ? onCall : null,
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                  label: Text(l10n.branchCallNow),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.directions_rounded, size: 20),
                  label: Text(l10n.branchGetDirections),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.openNow});

  final bool openNow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: openNow
            ? const Color(0xFF00C853).withValues(alpha: 0.12)
            : const Color(0xFFD50000).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            openNow ? Icons.circle : Icons.circle_outlined,
            size: 10,
            color: openNow ? const Color(0xFF00C853) : const Color(0xFFD50000),
          ),
          const SizedBox(width: 6),
          Text(
            openNow ? l10n.openNow : l10n.closed,
            style: TextStyle(
              color: openNow ? const Color(0xFF00C853) : const Color(0xFFD50000),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningHoursExpandableCard extends StatefulWidget {
  const _OpeningHoursExpandableCard({required this.branch});

  final BranchWithDistance branch;

  @override
  State<_OpeningHoursExpandableCard> createState() =>
      _OpeningHoursExpandableCardState();
}

class _OpeningHoursExpandableCardState
    extends State<_OpeningHoursExpandableCard> {
  bool _expanded = false;

  String _todaySummary(BuildContext context) {
    final l10n = context.l10n;
    final String? today = widget.branch.branch.todaysHoursRangeLabel();
    if (today == null) return l10n.branchHoursNotAvailable;
    if (today.isEmpty) return l10n.branchClosedToday;
    return today;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final int todayWd = DateTime.now().weekday;
    final String locale = Localizations.localeOf(context).toString();
    final List<BranchOpeningHour> hours = widget.branch.branch.openingHours;

    return _InfoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: theme.colorScheme.onSecondaryContainer,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.branchOpeningHours,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!_expanded) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            "${l10n.branchToday}: ${_todaySummary(context)}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.65),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: <Widget>[
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: _buildSchedule(
                    context: context,
                    theme: theme,
                    hours: hours,
                    todayWd: todayWd,
                    locale: locale,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule({
    required BuildContext context,
    required ThemeData theme,
    required List<BranchOpeningHour> hours,
    required int todayWd,
    required String locale,
  }) {
    final l10n = context.l10n;

    if (hours.isEmpty) {
      final String? open = widget.branch.branch.openTime;
      final String? close = widget.branch.branch.closeTime;
      final String text =
          (open != null && close != null && open.isNotEmpty && close.isNotEmpty)
              ? "${BranchEntity.formatHm12(open)} – ${BranchEntity.formatHm12(close)}"
              : l10n.branchHoursNotAvailable;
      return Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final Map<int, List<BranchOpeningHour>> byDay = <int, List<BranchOpeningHour>>{};
    for (final BranchOpeningHour h in hours) {
      byDay.putIfAbsent(h.dayOfWeek, () => <BranchOpeningHour>[]).add(h);
    }
    for (final List<BranchOpeningHour> list in byDay.values) {
      list.sort(
        (BranchOpeningHour a, BranchOpeningHour b) =>
            a.slotIndex.compareTo(b.slotIndex),
      );
    }

    final bool hasOvernight =
        hours.any((BranchOpeningHour h) => h.closesNextDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int day = 1; day <= 7; day++) ...<Widget>[
          if (byDay.containsKey(day))
            _DayHoursRow(
              day: day,
              slots: byDay[day]!,
              isToday: day == todayWd,
              locale: locale,
              todayLabel: l10n.branchToday,
            )
          else
            _DayHoursRow(
              day: day,
              slots: const <BranchOpeningHour>[],
              isToday: day == todayWd,
              locale: locale,
              todayLabel: l10n.branchToday,
              closedLabel: l10n.branchClosedToday,
            ),
        ],
        if (hasOvernight) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            l10n.branchHoursOvernightFootnote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

class _DayHoursRow extends StatelessWidget {
  const _DayHoursRow({
    required this.day,
    required this.slots,
    required this.isToday,
    required this.locale,
    required this.todayLabel,
    this.closedLabel,
  });

  final int day;
  final List<BranchOpeningHour> slots;
  final bool isToday;
  final String locale;
  final String todayLabel;
  final String? closedLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime anchor = DateTime(2024, 1, day);
    final String dayName = DateFormat.E(locale).format(anchor);

    final String timesText = slots.isEmpty
        ? (closedLabel ?? "—")
        : slots
            .map(
              (BranchOpeningHour h) =>
                  "${BranchEntity.formatHm12(h.openTime)} – ${BranchEntity.formatHm12(h.closeTime)}",
            )
            .join(", ");

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 88,
            child: Text(
              isToday ? todayLabel : dayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: isToday
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
          Expanded(
            child: Text(
              timesText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                color: isToday
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilitiesSection extends StatelessWidget {
  const _FacilitiesSection({required this.branch});

  final BranchWithDistance branch;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final List<String> facilities = branch.branch.facilities;

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.local_offer_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.branchServicesFacilities,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (facilities.isEmpty)
            Text(
              l10n.branchNoFacilities,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: facilities
                  .map(
                    (String name) => Chip(
                      label: Text(name),
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.08),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                      labelStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }
}

class _BranchReviewsSection extends ConsumerWidget {
  const _BranchReviewsSection({
    required this.branchId,
    required this.restaurantId,
  });

  final String branchId;
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final AsyncValue<ReviewsState> reviewsAsync =
        ref.watch(reviewsControllerProvider(branchId));
    final bool isLoggedIn =
        ref.watch(sessionControllerProvider).valueOrNull?.isAuthenticated ??
            false;
    final String? profileId =
        ref.watch(userProfileControllerProvider).valueOrNull?.id.trim();
    final String? myId = (profileId != null && profileId.isNotEmpty)
        ? profileId
        : jwtUserId(ref.watch(sessionControllerProvider).valueOrNull?.token);

    return reviewsAsync.when(
      data: (ReviewsState state) {
        final ReviewEntity? myReview = findMyReview(state.reviews, myId);
        return _InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.rate_review_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.tabReviews,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ReviewsSummaryHeader(
                avgRating: state.summary.avgRating,
                total: state.summary.total,
              ),
              const SizedBox(height: 12),
              WriteReviewButton(
                branchId: branchId,
                restaurantId: restaurantId,
                isLoggedIn: isLoggedIn,
                existingReview: myReview,
              ),
              const SizedBox(height: 16),
              if (state.reviews.isEmpty)
                Text(
                  l10n.restaurantNoReviewsYet,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                )
              else
                ...state.reviews.map(
                  (ReviewEntity review) => UserReviewCard(
                    review: review,
                    branchId: review.branchId.isNotEmpty
                        ? review.branchId
                        : branchId,
                    restaurantId: restaurantId,
                    isMine: myId != null && myId == review.userId,
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const _InfoCard(
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (Object error, StackTrace stack) => _InfoCard(
        child: Text(l10n.restaurantReviewsLoadError),
      ),
    );
  }
}

class _VotesSummaryCard extends ConsumerWidget {
  const _VotesSummaryCard({
    required this.branchId,
    required this.votes,
  });

  final String branchId;
  final AsyncValue<BranchVoteState> votes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final bool isAuth =
        ref.watch(sessionControllerProvider).valueOrNull?.isAuthenticated ??
            false;

    Future<void> handleVote(int value) async {
      if (!isAuth) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.voteLoginRequired)),
        );
        context.go("/auth/login");
        return;
      }
      final BranchVoteState? current = votes.valueOrNull;
      if (current != null && current.userVote == value) {
        return;
      }
      final bool success = await ref
          .read(votingControllerProvider(branchId).notifier)
          .vote(value);
      if (!context.mounted) {
        return;
      }
      if (!success) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.voteFailed)),
        );
      }
    }

    return _InfoCard(
      child: votes.when(
        data: (BranchVoteState voteState) {
          return Row(
            children: <Widget>[
              Expanded(
                child: _VoteStatTile(
                  icon: Icons.thumb_up_alt_rounded,
                  color: const Color(0xFF00C853),
                  countLabel: l10n.voteCountUp(voteState.upVotes),
                  actionLabel: l10n.voteUp,
                  theme: theme,
                  isSelected: voteState.hasUpvoted,
                  onTap: () => handleVote(1),
                ),
              ),
              Container(
                width: 1,
                height: 56,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              Expanded(
                child: _VoteStatTile(
                  icon: Icons.thumb_down_alt_rounded,
                  color: const Color(0xFFD50000),
                  countLabel: l10n.voteCountDown(voteState.downVotes),
                  actionLabel: l10n.voteDown,
                  theme: theme,
                  isSelected: voteState.hasDownvoted,
                  onTap: () => handleVote(-1),
                ),
              ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (Object error, StackTrace stack) =>
            Text(l10n.branchVotesUnavailable),
      ),
    );
  }
}

class _VoteStatTile extends StatelessWidget {
  const _VoteStatTile({
    required this.icon,
    required this.color,
    required this.countLabel,
    required this.actionLabel,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String countLabel;
  final String actionLabel;
  final ThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: <Widget>[
              Icon(
                icon,
                color: color,
                size: 28,
                fill: isSelected ? 1.0 : 0.0,
              ),
              const SizedBox(height: 6),
              Text(
                countLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                actionLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewMenuButton extends ConsumerWidget {
  const _ViewMenuButton({required this.branchId});

  final String branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final AsyncValue<List<MenuImageEntity>> imagesAsync =
        ref.watch(menuImagesControllerProvider(branchId));

    return imagesAsync.when(
      data: (List<MenuImageEntity> images) {
        final bool hasMenu = images.isNotEmpty;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(

            onPressed: hasMenu
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            MenuFlipBookFullScreen(images: images),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.menu_book_rounded),
            label: Text(
              hasMenu ? l10n.branchViewMenu : l10n.branchMenuUnavailable,
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      error: (Object error, StackTrace stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

