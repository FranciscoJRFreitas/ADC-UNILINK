import 'package:flutter/material.dart';

class CombinedButton extends StatefulWidget {
  final GestureDetector image;
  final GestureDetector file;

  const CombinedButton({required this.image, required this.file});
  @override
  _CombinedButtonState createState() => _CombinedButtonState();
}

class _CombinedButtonState extends State<CombinedButton>
    with TickerProviderStateMixin {
  late AnimationController _expandAnimationController;
  late AnimationController _opacityAnimationController;
  late Animation<Offset> _offsetAnimation;
  OverlayEntry? _overlayEntry;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _expandAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _expandAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _expandAnimationController.dispose();
    _opacityAnimationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void toggleExpandedState() {
    if (_isExpanded) {
      _expandAnimationController.reverse();
      _opacityAnimationController.reverse().then((value) {
        _overlayEntry?.remove();
      });
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      _expandAnimationController.forward();
      _opacityAnimationController.forward();
    }

    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        left: offset.dx,
        top: offset.dy - size.height * (_isExpanded ? 2.5 : 0.5),
        width: size.width,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _opacityAnimationController,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  widget.image,
                  SizedBox(height: 12),
                  widget.file,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleExpandedState,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Icon(
            _isExpanded ? Icons.close : Icons.attach_file,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}