import 'dart:async';

import 'package:flutter/material.dart';

abstract class LifecycleState<T extends StatefulWidget> extends State<T>
    with Lifecycle {
  String tag = T.toString();
  LifecycleManager lifecycleManager;

  T get widget => super.widget;

  LifecycleState() {
    lifecycleManager = LifecycleManager(this);
  }

  LifecycleState.fromLifeCycle(this.lifecycleManager);

  log(String log) {
    debugPrint('$tag --> $log');
  }

  @override
  void initState() {
    super.initState();
    lifecycleManager.init(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    lifecycleManager.initRoute(context);
  }

  @override
  void dispose() {
    lifecycleManager.destroy();
    super.dispose();
  }
}

class _LifecycleWrap implements Lifecycle {
  List<Lifecycle> array;

  _LifecycleWrap(this.array);

  @override
  void onBackground() {
    array.forEach((e) => {e.onBackground()});
  }

  @override
  void onCreate() {
    array.forEach((e) => {e.onCreate()});
  }

  @override
  void onDestroy() {
    array.forEach((e) => {e.onDestroy()});
  }

  @override
  void onForeground() {
    array.forEach((e) => {e.onForeground()});
  }

  @override
  void onLoadData() {
    array.forEach((e) => {e.onLoadData()});
  }

  @override
  void onWillPause() {
    array.forEach((e) => {e.onWillPause()});
  }

  @override
  void onPause() {
    array.forEach((e) => {e.onPause()});
  }

  @override
  void onResume() {
    array.forEach((e) => {e.onResume()});
  }
}

const String TAG = "Flutter.LifecycleManager";

class LifecycleManager with WidgetsBindingObserver, RouteAware {
  Lifecycle _lifecycle;

  LifecycleManager(this._lifecycle);

  LifecycleManager.fromArray(List<Lifecycle> array)
      : this(_LifecycleWrap(array));

  bool _isTop = true;

  bool onBackground = false;

  StreamSubscription _subscriptionEvent;

  void init(BuildContext context) {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  _initialize() {
    _lifecycle.onCreate();
    _lifecycle.onForeground();
    _lifecycle.onResume();
    _lifecycle.onLoadData();
  }

  initRoute(BuildContext context) {
  }

  void destroy() {
    _subscriptionEvent?.cancel();
    _lifecycle.onDestroy();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (_isTop) {
          onBackground = false;
          _lifecycle.onForeground();
          _lifecycle.onResume();
        }
        break;
      case AppLifecycleState.inactive:
        if (_isTop && !onBackground) {
          _lifecycle.onWillPause();
        }
        break;
      case AppLifecycleState.paused:
        if (_isTop) {
          _lifecycle.onBackground();
          onBackground = true;
          _lifecycle.onPause();
        }
        break;
      default:
        break;
    }
  }

  @override
  void didPush() {
    super.didPush();
    _isTop = true;
  }

  @override
  void didPushNext() {
    super.didPushNext();
    _lifecycle.onWillPause();
    _lifecycle.onPause();
    _isTop = false;
  }

  @override
  void didPop() {
    super.didPop();
    _lifecycle.onWillPause();
    _lifecycle.onPause();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _lifecycle.onResume();
    _isTop = true;
  }
}

abstract class Lifecycle {

  /// 用于让子类去实现的初始化方法
  void onCreate() {}

  /// 用于让子类去实现的不可见变为可见时的方法
  void onResume() {}

  ///加载数据
  void onLoadData() {}

  /// 用于让子类去实现的可见变为不可见时调用的方法。pause之前调用的方法
  void onWillPause() {}

  /// 用于让子类去实现的可见变为不可见时调用的方法。
  void onPause() {}

  /// 用于让子类去实现的销毁方法。
  void onDestroy() {}

  /// app切回到后台
  void onBackground() {}

  /// app切回到前台
  void onForeground() {}
}
