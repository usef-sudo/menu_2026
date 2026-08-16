import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:menu_2026/core/l10n/context_l10n.dart";
import "package:menu_2026/features/restaurants/domain/entities/menu_image_entity.dart";
import "package:page_flip/page_flip.dart";

/// Flip-book style menu viewer. Tap a page to open a zoomable fullscreen view.
class MenuFlipBookViewer extends StatelessWidget {
  const MenuFlipBookViewer({
    super.key,
    required this.images,
    this.padding = const EdgeInsets.all(12),
  });

  final List<MenuImageEntity> images;
  final EdgeInsets padding;

  void _openZoom(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => _MenuZoomViewer(
          images: images,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }
    if (images.length == 1) {
      return Padding(
        padding: padding,
        child: GestureDetector(
          onTap: () => _openZoom(context, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: images.first.imageUrl,
              fit: BoxFit.contain,
              placeholder: (BuildContext context, String url) =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              errorWidget: (BuildContext context, String url, Object error) =>
                  const Icon(Icons.broken_image_outlined, size: 48),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: PageFlipWidget(
        backgroundColor: Theme.of(context).colorScheme.surface,
        children: List<Widget>.generate(images.length, (int index) {
          final MenuImageEntity image = images[index];
          return GestureDetector(
            onTap: () => _openZoom(context, index),
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl: image.imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      placeholder: (BuildContext context, String url) =>
                          const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                      errorWidget:
                          (BuildContext context, String url, Object error) =>
                              const Icon(Icons.broken_image_outlined, size: 48),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "${index + 1} / ${images.length}  ·  tap to zoom",
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

class MenuFlipBookFullScreen extends StatelessWidget {
  const MenuFlipBookFullScreen({super.key, required this.images});

  final List<MenuImageEntity> images;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          l10n.tabMenu,
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
      body: MenuFlipBookViewer(
        images: images,
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      ),
    );
  }
}

class _MenuZoomViewer extends StatefulWidget {
  const _MenuZoomViewer({
    required this.images,
    required this.initialIndex,
  });

  final List<MenuImageEntity> images;
  final int initialIndex;

  @override
  State<_MenuZoomViewer> createState() => _MenuZoomViewerState();
}

class _MenuZoomViewerState extends State<_MenuZoomViewer> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
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
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (int index) => setState(() => _currentIndex = index),
        itemCount: widget.images.length,
        itemBuilder: (BuildContext context, int index) {
          final MenuImageEntity image = widget.images[index];
          return Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: CachedNetworkImage(
                imageUrl: image.imageUrl,
                fit: BoxFit.contain,
                placeholder: (BuildContext context, String url) =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                errorWidget: (BuildContext context, String url, Object error) =>
                    const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
