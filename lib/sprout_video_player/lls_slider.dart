import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

class LlsSlider extends StatefulWidget {
  final double value;

  final double min;

  final double max;

  final ValueChanged<double> onChanged;

  final ValueChanged<double> onChangeStart;

  final ValueChanged<double> onChangeEnd;

  final Color sliderColor;

  final Color thumbColor;

  final Color thumbRoundColor;

  final double lineHeight;

  final double thumbHeight;

  final double thumbRoundWidth;

  final bool canSlider;

  final bool showBufferSlider;

  final double bufferValue;

  const LlsSlider(
      {Key key,
      @required this.value,
      this.min = 0.0,
      this.max = 1.0,
      @required this.onChanged,
      this.onChangeStart,
      this.onChangeEnd,
      this.sliderColor,
      this.thumbColor,
      this.lineHeight = 16,
      this.thumbHeight = 22,
      this.thumbRoundWidth = 10,
      this.canSlider = true,
      this.showBufferSlider = false,
      this.bufferValue,
      this.thumbRoundColor})
      : assert(value != null),
        assert(min != null),
        assert(max != null),
        assert(min <= max),
        assert(value >= min && value <= max),
        super(key: key);

  @override
  _LlsSliderState createState() => _LlsSliderState();
}

class _LlsSliderState extends State<LlsSlider> with SingleTickerProviderStateMixin {
  double _sliderWidth;
  double _sliderHeight;
  double _thumbRoundHeight;
  double _currX = 0.0;
  AnimationController _animationController;
  CurvedAnimation _thumbAnimation;

  @override
  initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _thumbAnimation = CurvedAnimation(
      curve: Curves.bounceOut,
      parent: _animationController,
    );
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Offset _getGlobalToLocal(Offset globalPosition) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    return renderBox.globalToLocal(globalPosition);
  }

  void _onHorizontalDragDown(DragDownDetails details) {
    if (_isInteractive) {
      _animationController.forward();
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_isInteractive) {
      if (widget.onChangeStart != null) {
        _handleDragStart(widget.value);
      }
      _currX = _getGlobalToLocal(details.globalPosition).dx / _sliderWidth;
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isInteractive) {
      final double valueDelta = details.primaryDelta / _sliderWidth;
      _currX += valueDelta;

      _handleChanged(_clamp(_currX));
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (widget.onChangeEnd != null) {
      _handleDragEnd(_clamp(_currX));
    }
    _currX = 0.0;
    _animationController.reverse();
  }

  void _onHorizontalDragCancel() {
    if (widget.onChangeEnd != null) {
      _handleDragEnd(_clamp(_currX));
    }
    _currX = 0.0;
    _animationController.reverse();
  }

  double _clamp(double value) {
    return value.clamp(0.0, 1.0);
  }

  void _handleChanged(double value) {
    assert(widget.onChanged != null);
    final double lerpValue = _lerp(value);
    if (lerpValue != widget.value) {
      widget.onChanged(lerpValue);
    }
  }

  void _handleDragStart(double value) {
    assert(widget.onChangeStart != null);
    widget.onChangeStart((value));
  }

  void _handleDragEnd(double value) {
    assert(widget.onChangeEnd != null);
    widget.onChangeEnd((_lerp(value)));
  }

  double _lerp(double value) {
    assert(value >= 0.0);
    assert(value <= 1.0);
    return value * (widget.max - widget.min) + widget.min;
  }

  // Returns a number between 0.0 and 1.0, given a value between min and max.
  double _unlerp(double value) {
    assert(value <= widget.max);
    assert(value >= widget.min);
    return widget.max > widget.min ? (value - widget.min) / (widget.max - widget.min) : 0.0;
  }

  Color get _sliderColor {
    if (_isInteractive) {
      return widget.sliderColor ?? Theme.of(context).primaryColor;
    } else {
      return Colors.grey;
    }
  }

  Color get _thumbColor {
    if (_isInteractive) {
      return widget.thumbColor ?? _sliderColor;
    } else {
      return Colors.grey[300];
    }
  }

  Color get _thumbRoundColor {
    if (_isInteractive) {
      return widget.thumbRoundColor ?? Colors.white;
    } else {
      return Colors.grey[300];
    }
  }

  bool get _isInteractive => widget.onChanged != null;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double thumbPosFactor = _unlerp(widget.value);

        double remainingWidth;

        _sliderWidth = constraints.hasBoundedWidth ? constraints.maxWidth : 200.0;

        _thumbRoundHeight = widget.thumbHeight + widget.thumbRoundWidth;

        _sliderHeight = max(widget.lineHeight, _thumbRoundHeight);

        remainingWidth = _sliderWidth - _thumbRoundHeight;

        double bufferPosFactor = 0;
        double bufferValue = widget.max;
        if ((widget.showBufferSlider ?? false) && widget.bufferValue != null) {
          bufferPosFactor = _unlerp(widget.bufferValue);
          bufferValue = lerpDouble(remainingWidth, 0, bufferPosFactor);
        }

        bool bufferRightRound = bufferPosFactor > 0.98;

        //The position of the thumb control of the slider from max value.
        final double thumbPositionLeft = lerpDouble(0, remainingWidth, thumbPosFactor);

        final double thumbPositionRight = lerpDouble(remainingWidth, 0, thumbPosFactor);

        final RelativeRect beginRect =
            RelativeRect.fromLTRB(thumbPositionLeft, 0.0, thumbPositionRight, 0.0);

        final RelativeRect endRect =
            RelativeRect.fromLTRB(thumbPositionLeft, 0.0, thumbPositionRight, 0.0);

        Animation<RelativeRect> thumbPosition = RelativeRectTween(
          begin: beginRect,
          end: endRect,
        ).animate(_thumbAnimation);

        return Container(
          width: _sliderWidth,
          height: _sliderHeight,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                top: (_sliderHeight - widget.lineHeight) / 2,
                bottom: (_sliderHeight - widget.lineHeight) / 2,
                child: Container(
                    width: _sliderWidth,
                    height: widget.lineHeight,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(widget.lineHeight / 2),
                        right: Radius.circular(widget.lineHeight / 2),
                      ),
                    )),
              ),
              Positioned(
                left: 0,
                right: bufferValue,
                top: (_sliderHeight - widget.lineHeight) / 2,
                bottom: (_sliderHeight - widget.lineHeight) / 2,
                child: Visibility(
                  visible: (widget.showBufferSlider ?? false) && widget.bufferValue != null,
                  child: Container(
                      height: widget.lineHeight,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(widget.lineHeight / 2),
                            right: Radius.circular(bufferRightRound ? widget.lineHeight / 2 : 0)),
                      )),
                ),
              ),
              Positioned(
                left: 0,
                right: remainingWidth - thumbPositionLeft + _thumbRoundHeight / 2,
                top: (_sliderHeight - widget.lineHeight) / 2,
                bottom: (_sliderHeight - widget.lineHeight) / 2,
                child: Container(
                    height: widget.lineHeight,
                    decoration: BoxDecoration(
                      color: _sliderColor,
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(widget.lineHeight / 2)),
                    )),
              ),
              PositionedTransition(
                rect: thumbPosition,
                child: _buildIndicator(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIndicator() {
    return widget.canSlider
        ? GestureDetector(
            onHorizontalDragCancel: _onHorizontalDragCancel,
            onHorizontalDragDown: _onHorizontalDragDown,
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: _buildPointIndicator())
        : _buildPointIndicator();
  }

  Container _buildPointIndicator() {
    return Container(
      width: _thumbRoundHeight,
      height: _thumbRoundHeight,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _thumbRoundColor,
      ),
      alignment: Alignment.center,
      child: Container(
          width: widget.thumbHeight,
          height: widget.thumbHeight,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _thumbColor,
          )),
    );
  }
}
