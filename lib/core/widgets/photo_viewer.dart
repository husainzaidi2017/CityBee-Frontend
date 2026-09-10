import 'package:flutter/material.dart';

import 'app_image.dart';

/// Full-screen photo viewer with pinch-zoom, double-tap zoom, swipe
/// between photos, and a dark blurred backdrop. Opened by tapping a hero
/// photo on any detail page.
class PhotoViewerScreen extends StatefulWidget {
  const PhotoViewerScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTag,
  });

  final List<String> imageUrls;
  final int initialIndex;

  /// Optional Hero tag for a smooth open transition from the carousel.
  final String? heroTag;

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final PageController _pageController;
  late int _index;
  bool _showChrome = true;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleChrome() => setState(() => _showChrome = !_showChrome);

  @override
  Widget build(BuildContext context) {
    final canSwipe = widget.imageUrls.length > 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Tap toggles the top bar / counter; the viewer itself handles
        // zoom gestures via InteractiveViewer.
        onTap: _toggleChrome,
        child: Stack(
          children: [
            // ── Zoomable, swipeable photos ─────────────────────────
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => _ZoomablePhoto(
                url: widget.imageUrls[i],
                onTap: _toggleChrome,
              ),
            ),

            // ── Top bar (back + counter), auto-hiding ──────────────
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showChrome ? 1 : 0,
              child: IgnorePointer(
                ignoring: !_showChrome,
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      if (canSwipe)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${_index + 1} / ${widget.imageUrls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One photo: pinch-zoom + pan via InteractiveViewer, double-tap zooms in
/// and out, single tap toggles the chrome.
class _ZoomablePhoto extends StatefulWidget {
  const _ZoomablePhoto({required this.url, required this.onTap});

  final String url;
  final VoidCallback onTap;

  @override
  State<_ZoomablePhoto> createState() => _ZoomablePhotoState();
}

class _ZoomablePhotoState extends State<_ZoomablePhoto>
    with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Guard: only react to taps when NOT zoomed (a tap while panning a
  // zoomed image should not toggle the chrome).
  bool get _isZoomed =>
      (_controller.value.getMaxScaleOnAxis() - 1.0) > 0.01;

  void _handleDoubleTap() {
    final position = _doubleTapDetails?.localPosition ?? Offset.zero;
    if (_isZoomed) {
      // Zoom back out.
      _controller.value = Matrix4.identity();
    } else {
      // Zoom 2.5× centered on the tapped point.
      const scale = 2.5;
      final matrix = Matrix4.identity();
      matrix.setEntry(0, 3, -position.dx * (scale - 1));
      matrix.setEntry(1, 3, -position.dy * (scale - 1));
      matrix.scaleByDouble(scale, scale, 1.0, 1.0);
      _controller.value = matrix;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      minScale: 1.0,
      maxScale: 5.0,
      // While zoomed, pan stays inside this viewer (no page swipe fights).
      panEnabled: true,
      child: GestureDetector(
        onTapUp: (details) {
          if (!_isZoomed) widget.onTap();
        },
        onDoubleTapDown: (details) => _doubleTapDetails = details,
        onDoubleTap: _handleDoubleTap,
        child: Center(
          child: AppImage(
            url: widget.url,
            fit: BoxFit.contain,
            memCacheWidth: null, // full resolution in the viewer
          ),
        ),
      ),
    );
  }
}
