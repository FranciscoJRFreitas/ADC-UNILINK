import 'package:flutter/material.dart';

class CombinedButton extends StatefulWidget {
  final GestureDetector image;
  final GestureDetector file;

  const CombinedButton({required this.image, required this.file});
  @override
  _CombinedButtonState createState() => _CombinedButtonState();
}

class _CombinedButtonState extends State<CombinedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  //late Animation<double> _slideAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpandedState() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpandedState,
      child: SizedBox(
          height: _isExpanded ? 174 : 50,
          child: Column(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 3000),
                  height: _isExpanded ? 150 : 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: _isExpanded,
                        child: Column(
                          children: [
                            widget.image,
                            SizedBox(height: 12),
                            widget.file,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
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
            ],
          )),
    );
  }
}
