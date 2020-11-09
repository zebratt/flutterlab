import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

const _AnimateDuration = Duration(milliseconds: 200);

const _WidgetScale = 0.88;

const _WidgetOpacity = 0.8;

typedef OnPageChange = void Function(int index);

enum CardStatus { unKnow, next, previous }

class CardChangeView extends StatefulWidget {
  //to scale left and right item
  final double scale;

  //to opacity left and right item
  final double opacity;

  //top item size
  final Size centerSize;

  final CardController controller;

  //widget item builder
  final IndexedWidgetBuilder itemBuilder;

  //item count
  final int itemCount;

  //center item position
  final int position;

  //anim duration
  final Duration duration;

  //PageChange, callback current index
  final OnPageChange onPageChange;

  // left and right card, offsetX
  final double offsetX;

  final VoidCallback previousCallBack;

  final VoidCallback nextCallBack;

  //widget default item builder
  final Widget defaultItem;

  CardChangeView(
      {@required this.controller,
      @required this.itemBuilder,
      @required this.itemCount,
      @required this.centerSize,
      this.defaultItem,
      this.position = 0,
      this.duration = _AnimateDuration,
      this.scale = _WidgetScale,
      this.opacity = _WidgetOpacity,
      this.onPageChange,
      this.offsetX,
      this.previousCallBack,
      this.nextCallBack})
      : assert(controller != null),
        assert(centerSize != null),
        assert(scale <= 1.0 && scale >= 0);

  @override
  _CardChangeViewState createState() {
    return _CardChangeViewState();
  }
}

class _CardChangeViewState extends State<CardChangeView> with SingleTickerProviderStateMixin {
  Size get size => widget.centerSize;

  IndexedWidgetBuilder get itemBuilder => widget.itemBuilder;

  CardController get cardController => widget.controller;

  Widget get defaultItem => widget.defaultItem;

  double get scale => widget.scale;

  double get opacity => widget.opacity;

  int get itemCount => widget.itemCount;

  AnimationController _controller;

  // left and right opacity animate
  Animatable<double> _opacityTween;

  // center opacity animate
  Animatable<double> _centerOpacityTween;

  // center opacity animate
  Animatable<double> _sideOpacityTween;

  // scale animate
  Animatable<double> _scaleTween;

  // scale animate
  Animatable<double> _positionTween;

  bool _toNext = true;

  double _offsetX;

  int _position;

  Function _listener;

  Function _cardStatusListener;

  bool _animateCompleted = true;

  @override
  void initState() {
    super.initState();
    _offsetX = widget.offsetX ?? widget.centerSize.width * (1 - scale);
    _position = widget.position;
    _cardStatusListener = () {
      if (cardController.statusNotifier.value == CardStatus.next) {
        if (canChange() && !showRightDefault()) {
          _toNext = true;
          if (widget.nextCallBack != null) {
            widget.nextCallBack();
          }
          _controller.forward();
        }
      } else if (cardController.statusNotifier.value == CardStatus.previous) {
        if (canChange() && !showLeftDefault()) {
          _toNext = false;
          if (widget.previousCallBack != null) {
            widget.previousCallBack();
          }
          _controller.forward();
        }
      }
    };
    cardController.statusNotifier.addListener(_cardStatusListener);
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _opacityTween = Tween<double>(begin: opacity, end: 1);
    _centerOpacityTween = Tween<double>(begin: 1, end: 0);
    _sideOpacityTween = Tween<double>(begin: 0, end: opacity);
    _scaleTween = Tween<double>(begin: scale, end: 1);
    _positionTween = Tween<double>(begin: 0, end: _offsetX);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animateCompleted = true;
        if (_toNext) {
          _position = (_position + 1) % itemCount;
        } else {
          _position = (_position + itemCount - 1) % itemCount;
        }
        if (widget.onPageChange != null) {
          widget.onPageChange(_position);
        }
        _controller.reset();
      } else if (status == AnimationStatus.forward) {
        _animateCompleted = false;
      }
    });
  }

  @override
  void didUpdateWidget(CardChangeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.statusNotifier != cardController.statusNotifier) {
      oldWidget.controller.statusNotifier.removeListener(_cardStatusListener);
      cardController.statusNotifier.addListener(_cardStatusListener);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    cardController.statusNotifier.removeListener(_cardStatusListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (itemCount > 1) {
      return _createAnimateWidgets();
    } else {
      return _createCenterAnimateCard();
    }
  }

  Widget _createAnimateWidgets() {
    return AnimatedBuilder(
        animation: _controller.view,
        builder: (BuildContext context, Widget child) {
          return Container(
            child: Stack(children: _createCardsAnimateList()),
          );
        });
  }

  _createCard(Widget item,
      {double offset = 0,
      double scale,
      double opacity,
      AlignmentGeometry alignment = Alignment.center}) {
    return Center(
      child: Transform.translate(
        offset: Offset(offset, 0),
        child: Transform.scale(
          alignment: alignment,
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: size.width,
              height: size.height,
              child: item,
            ),
          ),
        ),
      ),
    );
  }

  _createDefaultCard(
      {double offset = 0,
      double scale,
      double opacity,
      AlignmentGeometry alignment = Alignment.center}) {
    return Center(
      child: Transform.translate(
        offset: Offset(offset, 0),
        child: Transform.scale(
          alignment: alignment,
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: defaultItem,
          ),
        ),
      ),
    );
  }

  List<Widget> _createCardsAnimateList() {
    List<Widget> cardList = List();
    cardList.add(_createLeftTwoAnimateCard());
    cardList.add(_createLeftAnimateCard());
    cardList.add(_createRightTwoAnimateCard());
    cardList.add(_createRightAnimateCard());
    cardList.add(_createCenterAnimateCard());
    return cardList;
  }

  Widget _createLeftAnimateCard() {
    double offsetX =
        _toNext ? -_offsetX : -_offsetX + _positionTween.evaluate(_controller);
    double leftScale = _toNext ? scale : _scaleTween.evaluate(_controller);
    double leftOpacity =
        _toNext ? opacity : _opacityTween.evaluate(_controller);
    int index = (_position + itemCount - 1) % itemCount;
    return showLeftDefault()
        ? _createDefaultCard(
            offset: offsetX, opacity: leftOpacity, scale: leftScale)
        : _createCard(itemBuilder(context, index),
            offset: offsetX, opacity: leftOpacity, scale: leftScale);
  }

  _createLeftTwoAnimateCard() {
    double offsetX = -_offsetX;
    double leftOpacity = _toNext ? 0 : _sideOpacityTween.evaluate(_controller);
    int index = (_position + itemCount - 2) % itemCount;
    return _createCard(itemBuilder(context, index),
        offset: offsetX, opacity: leftOpacity, scale: scale);
  }

  _createRightAnimateCard() {
    double offsetX =
        _toNext ? _offsetX - _positionTween.evaluate(_controller) : _offsetX;
    double rightScale = _toNext ? _scaleTween.evaluate(_controller) : scale;
    double rightOpacity =
        _toNext ? _opacityTween.evaluate(_controller) : opacity;
    int index = (_position + 1) % itemCount;
    return showRightDefault()
        ? _createDefaultCard(
            offset: offsetX, opacity: rightOpacity, scale: rightScale)
        : _createCard(itemBuilder(context, index),
            offset: offsetX, opacity: rightOpacity, scale: rightScale);
  }

  bool showLeftDefault() {
    return _position == 0 && itemCount == 2 && defaultItem != null;
  }

  bool showRightDefault() {
    return _position == 1 && itemCount == 2 && defaultItem != null;
  }

  _createRightTwoAnimateCard() {
    double rightOpacity = _toNext ? _sideOpacityTween.evaluate(_controller) : 0;
    int index = (_position + 2) % itemCount;
    return _createCard(itemBuilder(context, index),
        offset: _offsetX, opacity: rightOpacity, scale: scale);
  }

  _createCenterAnimateCard() {
    double offsetX =
        _toNext ? -_positionTween.evaluate(_controller) : _positionTween.evaluate(_controller);
    var centerOpacity = _centerOpacityTween.evaluate(_controller);
    return _createCard(itemBuilder(context, _position),
        offset: offsetX,
        opacity: centerOpacity,
        scale: 1 - (_scaleTween.evaluate(_controller) - scale));
  }

  bool canChange() {
    return itemCount > 1 && _animateCompleted;
  }
}

abstract class CardOperate {
  void next();

  void previous();
}

class CardController implements CardOperate {
  CardStatusNotifier statusNotifier = CardStatusNotifier(CardStatus.unKnow);

  @override
  void next() {
    statusNotifier.value = CardStatus.next;
  }

  @override
  void previous() {
    statusNotifier.value = CardStatus.previous;
  }
}

class CardStatusNotifier extends ValueNotifierWithoutFilter<CardStatus> {
  CardStatusNotifier(CardStatus value) : super(value);
}

class ValueNotifierWithoutFilter<T> extends ChangeNotifier implements ValueListenable<T> {
  /// Creates a [ChangeNotifier] that wraps this value.
  ValueNotifierWithoutFilter(this._value);

  /// The current value stored in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old
  /// value as evaluated by the equality operator ==, this class notifies its
  /// listeners.
  @override
  T get value => _value;
  T _value;
  set value(T newValue) {
    _value = newValue;
    notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}