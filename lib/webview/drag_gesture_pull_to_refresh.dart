import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DragGesturePullToRefresh extends VerticalDragGestureRecognizer {
  static const double EXCEEDS_LOADING_TIME = 3000;

  late BuildContext _context;
  WebViewController? _controller;

  // loading
  Completer<void> completer = Completer<void>();
  int msLoading = 0;
  bool isLoading = true;

  // drag
  int    dragStartYDiff = 0;
  double height = 200;
  bool dragStarted = false;
  double dragDistance = 0;

  @override
  //override rejectGesture here
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }

  void _clearDrag() {
    dragStarted = false;
    dragDistance = 0;
  }

  DragGesturePullToRefresh setContext(BuildContext context) { _context = context; return this; }
  DragGesturePullToRefresh setController(WebViewController controller) { _controller = controller; return this; }
  DragGesturePullToRefresh setDragHeightEnd(double value)      { height = value;   return this; }
  DragGesturePullToRefresh setDragStartYDiff(int value) { dragStartYDiff = value;  return this; }

  void setHeight(double height) { this.height = height; }

  Future refresh() {
    if (!completer.isCompleted) {
      completer.complete();
    }
    completer = Completer<void>();
    started();
    _controller?.reload();
    return completer.future;
  }

  void started() {
    msLoading = DateTime.now().millisecondsSinceEpoch;
    isLoading = true;
  }

  Future<void> finished() {
    msLoading = 0;
    isLoading = false;
    // hide the RefreshIndicator
    if (!completer.isCompleted) {
      completer.complete();
    }
    return completer.future;
  }

  FixedScrollMetrics _getMetrics(double minScrollExtent, double maxScrollExtent,
      double pixels, double viewportDimension, AxisDirection axisDirection) {
    return FixedScrollMetrics(
        minScrollExtent: minScrollExtent,
        maxScrollExtent: maxScrollExtent,
        pixels: pixels,
        viewportDimension: viewportDimension,
        axisDirection: axisDirection,
    devicePixelRatio: 0);
  }

  DragGesturePullToRefresh() {
    onStart = (DragStartDetails dragDetails) async {
      //debugPrint('DragGesturePullToRefresh(): $dragDetails');
      if (!isLoading ||
          // Reallow pull to refresh if the website didn't load in msWaitToRestart time
          (msLoading > 0 && (DateTime.now().millisecondsSinceEpoch - msLoading) > EXCEEDS_LOADING_TIME)) {
        Offset? scrollPos = await _controller?.getScrollPosition();

        // Only allow RefreshIndicator if you are at the top of page!
        if (scrollPos!.dy <= dragStartYDiff) {
          dragStarted = true;
          dragDistance = 0;
          ScrollStartNotification(
              metrics: _getMetrics(0, height, 0, height, AxisDirection.down),
              dragDetails: dragDetails,
              context: _context
          ).dispatch(_context);
        }
      }
    };
    // onStart = (DragStartDetails dragDetails) {
    //   // debugPrint('MyWebViewWidget:onStart(): $dragDetails');
    //   if (!isLoading ||
    //       (msLoading > 0 && (DateTime.now().millisecondsSinceEpoch - msLoading) > EXCEEDS_LOADING_TIME)) {
    //     // _controller?.getScrollY()
    //     _controller?.runJavaScriptReturningResult("window.scrollY").then((scrollYPos) {
    //       print("podition xy : $scrollYPos");
    //       if (scrollYPos == 0) {
    //         dragStarted = true;
    //         dragDistance = 0;
    //         ScrollStartNotification(
    //             metrics: _getMetrics(0, height, 0, height, AxisDirection.down, ),
    //             dragDetails: dragDetails,
    //             context: _context)
    //             .dispatch(_context);
    //       }
    //     });
    //   }
    // };
    onUpdate = (DragUpdateDetails dragDetails) {
      if (dragStarted) {
        double dy = dragDetails.delta.dy;
        dragDistance += dy;
        ScrollUpdateNotification(
            metrics: _getMetrics(
                dy > 0 ? 0 : dragDistance, height,
                dy > 0 ? (-1) * dy : dragDistance, height,
                dragDistance < 0 ? AxisDirection.up : AxisDirection.down),
            context: _context,
            scrollDelta: (-1) * dy)
            .dispatch(_context);
        if (dragDistance < 0) {
          _clearDrag();
        }
      }
    };
    onEnd = (DragEndDetails dragDetails) {
      ScrollEndNotification(
          metrics: _getMetrics(0, height, dragDistance, height, AxisDirection.down),
          context: _context)
          .dispatch(_context);
      _clearDrag();
    };
    onCancel = () {
      ScrollUpdateNotification(
          metrics: _getMetrics(0, height, 1, height, AxisDirection.up),
          context: _context,
          scrollDelta: 0)
          .dispatch(_context);
      _clearDrag();
    };
  }
}