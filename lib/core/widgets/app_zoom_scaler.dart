import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppZoomScaler extends StatefulWidget {
  final Widget child;

  const AppZoomScaler({super.key, required this.child});

  static _AppZoomScalerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AppZoomScalerState>();
  }

  @override
  State<AppZoomScaler> createState() => _AppZoomScalerState();
}

class _AppZoomScalerState extends State<AppZoomScaler> {
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadScale();
  }

  Future<void> _loadScale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedScale = prefs.getDouble('app_zoom_scale');
    if (savedScale != null) {
      setState(() {
        _scale = savedScale;
      });
    }
  }

  Future<void> _saveScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('app_zoom_scale', scale);
  }

  void zoomIn() {
    if (_scale < 2.0) {
      setState(() {
        _scale = (_scale + 0.05).clamp(0.5, 2.0);
        _saveScale(_scale);
      });
    }
  }

  void zoomOut() {
    if (_scale > 0.5) {
      setState(() {
        _scale = (_scale - 0.05).clamp(0.5, 2.0);
        _saveScale(_scale);
      });
    }
  }

  void resetZoom() {
    setState(() {
      _scale = 1.0;
      _saveScale(_scale);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final originalSize = mediaQuery.size;
    final scaledSize = Size(originalSize.width / _scale, originalSize.height / _scale);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          // Scaled app content
          Positioned(
            top: 0,
            left: 0,
            width: scaledSize.width,
            height: scaledSize.height,
            child: Transform.scale(
              scale: _scale,
              alignment: Alignment.topLeft,
              child: MediaQuery(
                data: mediaQuery.copyWith(
                  size: scaledSize,
                ),
                child: widget.child,
              ),
            ),
          ),
          // Zoom controller overlay at bottom-right
          Positioned(
            bottom: 24,
            right: 24,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]!.withOpacity(0.9)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zoom out (-) button
                    _buildZoomButton(
                      icon: Icons.remove,
                      onPressed: zoomOut,
                    ),
                    const SizedBox(width: 8),
                    // Percentage indicator / reset button
                    InkWell(
                      onTap: resetZoom,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          '${(_scale * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Zoom in (+) button
                    _buildZoomButton(
                      icon: Icons.add,
                      onPressed: zoomIn,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
