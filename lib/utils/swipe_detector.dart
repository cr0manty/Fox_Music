import 'package:flutter/cupertino.dart';

class SwipeDetector extends StatefulWidget {
  final Function onSwipeUp;
  final Function onSwipeDown;
  final Function onSwipeLeft;
  final Function onSwipeRight;
  final Function onTap;
  final Widget child;
  final bool enabled;

  SwipeDetector(
      {this.onSwipeDown,
      this.onSwipeLeft,
      this.onSwipeRight,
      this.onSwipeUp,
      this.onTap,
      this.child,
      this.enabled = true});

  @override
  State<StatefulWidget> createState() => SwipeDetectorState();
}

class SwipeDetectorState extends State<SwipeDetector> {
  DragStartDetails startVerticalDragDetails;
  DragUpdateDetails updateVerticalDragDetails;
  DragStartDetails startHorizontalDragDetails;
  DragUpdateDetails updateHorizontalDragDetails;

  @override
  Widget build(BuildContext context) {
    return widget.enabled
        ? GestureDetector(
            onTap: widget.onTap,
            onVerticalDragStart: (dragDetails) {
              startVerticalDragDetails = dragDetails;
            },
            onVerticalDragUpdate: (dragDetails) {
              updateVerticalDragDetails = dragDetails;
            },
            onVerticalDragEnd: (endDetails) {
              double dy = updateVerticalDragDetails.globalPosition.dy -
                  startVerticalDragDetails.globalPosition.dy;

              if (dy < 30 && widget?.onSwipeUp != null) {
                widget.onSwipeUp();
              } else if (dy > 30 && widget?.onSwipeDown != null) {
                widget.onSwipeDown();
              }
            },
            onHorizontalDragStart: (dragDetails) {
              startHorizontalDragDetails = dragDetails;
            },
            onHorizontalDragUpdate: (dragDetails) {
              updateHorizontalDragDetails = dragDetails;
            },
            onHorizontalDragEnd: (endDetails) {
              double dx = updateHorizontalDragDetails.globalPosition.dx -
                  startHorizontalDragDetails.globalPosition.dx;

              if (dx < 30 && widget?.onSwipeRight != null) {
                widget.onSwipeLeft();
              } else if (dx > 30 && widget?.onSwipeLeft != null) {
                widget.onSwipeRight();
              }
            },
            child: widget.child)
        : widget.child;
  }
}
