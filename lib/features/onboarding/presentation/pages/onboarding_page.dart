import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/core/widgets/gradient_primary_button.dart";
import "package:menu_2026/l10n/app_localizations.dart";

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    this.onFlowCompleted,
    this.onSkipGuest,
  });

  /// When set (e.g. from [AppEntryPage]), finishes onboarding then continues entry flow.
  final Future<void> Function()? onFlowCompleted;

  /// When set, marks onboarding done and continues as guest (e.g. `/home`).
  final Future<void> Function()? onSkipGuest;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.startColor,
    required this.endColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color startColor;
  final Color endColor;
  final String title;
  final String description;
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  List<_OnboardingSlide> _slides(AppLocalizations l) => <_OnboardingSlide>[
        _OnboardingSlide(
          icon: Icons.search_rounded,
          startColor: const Color(0xFF8A4DFF),
          endColor: const Color(0xFFE05BFF),
          title: l.onboardingDiscoverTitle,
          description: l.onboardingDiscoverBody,
        ),
        _OnboardingSlide(
          icon: Icons.place_rounded,
          startColor: const Color(0xFF2D9CFF),
          endColor: const Color(0xFF3EE4FF),
          title: l.onboardingBranchesTitle,
          description: l.onboardingBranchesBody,
        ),
        _OnboardingSlide(
          icon: Icons.casino_rounded,
          startColor: const Color(0xFFFF3F8E),
          endColor: const Color(0xFFFF7B65),
          title: l.onboardingSpinTitle,
          description: l.onboardingSpinBody,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handlePrimaryAction(BuildContext context) async {
    final bool isLast =
        _currentIndex == _slides(context.l10n).length - 1;
    if (isLast) {
      if (widget.onFlowCompleted != null) {
        await widget.onFlowCompleted!();
      } else if (context.mounted) {
        context.go("/auth/login");
      }
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final List<_OnboardingSlide> slides = _slides(l10n);
    final bool isLast = _currentIndex == slides.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFFDF2FF), Color(0xFFF8F5FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: slides.length,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final _OnboardingSlide current = slides[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: <Color>[
                                  current.startColor,
                                  current.endColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: current.startColor.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 30,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Icon(
                              current.icon,
                              size: 72,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            current.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            current.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          _PageIndicator(
                            length: slides.length,
                            index: index,
                            activeColor: theme.colorScheme.primary,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                GradientPrimaryButton(
                  label: isLast ? l10n.onboardingGetStarted : l10n.commonNext,
                  onPressed: () => _handlePrimaryAction(context),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    if (widget.onSkipGuest != null) {
                      await widget.onSkipGuest!();
                    } else if (context.mounted) {
                      context.go("/home");
                    }
                  },
                  child: Text(l10n.onboardingSkipForNow),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.length,
    required this.index,
    required this.activeColor,
  });

  final int length;
  final int index;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(length, (int i) {
        final bool isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : activeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(40),
          ),
        );
      }),
    );
  }
}
