import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/features/restaurants/domain/entities/menu_image_entity.dart";
import "package:page_flip/page_flip.dart";

/// Flip-book style menu viewer. Tap a page to open a fullscreen flip + zoom view.
class MenuFlipBookViewer extends StatefulWidget {
  const MenuFlipBookViewer({
    super.key,
    required this.images,
    this.padding = const EdgeInsets.all(12),
  });

  final List<MenuImageEntity> images;
  final EdgeInsets padding;

  @override
  State<MenuFlipBookViewer> createState() => _MenuFlipBookViewerState();
}

class _MenuFlipBookViewerState extends State<MenuFlipBookViewer> {
  bool _fullscreenOpen = false;
  int _previewIndex = 0;

  Future<void> _openFullscreen(int index) async {
    setState(() {
      _fullscreenOpen = true;
      _previewIndex = index;
    });
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => MenuFlipBookFullScreen(
          images: widget.images,
          initialIndex: index,
        ),
      ),
    );
    if (mounted) {
      setState(() => _fullscreenOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<MenuImageEntity> images = widget.images;
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_fullscreenOpen) {
      return Padding(
        padding: widget.padding,
        child: _MenuPageImage(
          imageUrl: images[_previewIndex.clamp(0, images.length - 1)].imageUrl,
        ),
      );
    }

    if (images.length == 1) {
      return Padding(
        padding: widget.padding,
        child: GestureDetector(
          onTap: () => _openFullscreen(0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _MenuPageImage(imageUrl: images.first.imageUrl),
          ),
        ),
      );
    }

    return Padding(
      padding: widget.padding,
      child: PageFlipWidget(
        backgroundColor: Theme.of(context).colorScheme.surface,
        isRightSwipe: Directionality.of(context) == TextDirection.rtl,
        children: List<Widget>.generate(images.length, (int index) {
          final MenuImageEntity image = images[index];
          return GestureDetector(
            onTap: () => _openFullscreen(index),
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: _MenuPageImage(imageUrl: image.imageUrl),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "${index + 1} / ${images.length}  ·  ${context.l10n.menuTapForFullView}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class MenuFlipBookFullScreen extends StatefulWidget {
  const MenuFlipBookFullScreen({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  final List<MenuImageEntity> images;
  final int initialIndex;

  @override
  State<MenuFlipBookFullScreen> createState() => _MenuFlipBookFullScreenState();
}

class _MenuFlipBookFullScreenState extends State<MenuFlipBookFullScreen> {
  late int _currentIndex;
  final PageFlipController _flipController = PageFlipController();
  final TransformationController _transform = TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.images.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.images.length - 1);
    if (_currentIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _flipController.goToPage(_currentIndex);
        }
      });
    }
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transform.value = Matrix4.identity();
  }

  void _toggleZoom() {
    if (_transform.value.getMaxScaleOnAxis() > 1.05) {
      _resetZoom();
      return;
    }
    _transform.value = Matrix4.identity()
      ..translateByDouble(-80, -80, 0, 1)
      ..scaleByDouble(2.2, 2.2, 1, 1);
  }

  Widget _zoomablePage(int index) {
    final MenuImageEntity image = widget.images[index];
    return ColoredBox(
      color: Colors.black,
      child: GestureDetector(
        onDoubleTap: _toggleZoom,
        child: InteractiveViewer(
          transformationController: _transform,
          minScale: 1,
          maxScale: 5,
          clipBehavior: Clip.hardEdge,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: image.imageUrl,
              fit: BoxFit.contain,
              placeholder: (BuildContext context, String url) => const Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
              errorWidget: (BuildContext context, String url, Object error) =>
                  const Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final int safeIndex = widget.images.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.images.length - 1);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          l10n.tabMenu,
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                "${_currentIndex + 1}/${widget.images.length}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
      body: widget.images.isEmpty
          ? const SizedBox.shrink()
          : widget.images.length == 1
              ? _zoomablePage(0)
              : PageFlipWidget(
                  controller: _flipController,
                  initialIndex: safeIndex,
                  backgroundColor: Colors.black,
                  isRightSwipe:
                      Directionality.of(context) == TextDirection.rtl,
                  onFlipStart: _resetZoom,
                  onPageFlipped: (int page) {
                    _resetZoom();
                    setState(() => _currentIndex = page);
                  },
                  children: List<Widget>.generate(
                    widget.images.length,
                    _zoomablePage,
                  ),
                ),
    );
  }
}

class _MenuPageImage extends StatelessWidget {
  const _MenuPageImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      width: double.infinity,
      placeholder: (BuildContext context, String url) =>
          const Center(child: CircularProgressIndicator.adaptive()),
      errorWidget: (BuildContext context, String url, Object error) =>
          const Icon(Icons.broken_image_outlined, size: 48),
    );
  }
}
