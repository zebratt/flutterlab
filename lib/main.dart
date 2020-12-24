import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Switch(child: TestWidget()),
          )),
    );
  }
}

class Switch extends HookWidget {
  Widget child;

  Switch({this.child});

  @override
  Widget build(BuildContext context) {
    var visible = useState(true);

    return Column(
      children: [
        Visibility(visible: visible.value, child: child),
        GestureDetector(
          onTap: () {
            visible.value = !visible.value;
          },
          child: Container(
            color: Colors.grey,
              width: 120, height: 40, child: Center(child: Text('toggle'))),
        )
      ],
    );
  }
}

class TestWidget extends Widget {
  @override
  Element createElement() {
    print('----- test widget create element');
    return TestElement(this);
  }

  Widget build(BuildContext context) {
    print('----- test widget build');
    return Text('test abc');
  }
}

class TestComponentElement extends ComponentElement {
  TestComponentElement(Widget widget) : super(widget);

  @override
  Widget build() {
    return (super.widget as TestWidget).build(this);
  }
}

class TestElement extends Element {
  TestElement(Widget widget) : super(widget);

  Element _child;

  // @override
  // void mount(Element parent, dynamic newSlot) {
  //   super.mount(parent, newSlot);
  //   print('----- mount');
  //   assert(_child == null);
  //   rebuild();
  //   assert(_child != null);
  // }

  @override
  bool get debugDoingBuild => throw UnimplementedError();

  @override
  void performRebuild() {
    var built = build();
    _child = updateChild(_child, built, slot);
  }

  // @override
  // void update(Widget newWidget) {
  //   super.update(newWidget);
  //   print("----- update");
  //   assert(widget == newWidget);
  //   rebuild();
  // }

  Widget build() {
    return (super.widget as TestWidget).build(this);
  }
}

class LifecycleElement extends TestElement {
  LifecycleElement(Widget widget) : super(widget);

  @override
  void mount(Element parent, newSlot) {
    print("LifecycleElement mount");
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    print("LifecycleElement unmount");
    super.unmount();
  }

  @override
  void activate() {
    print("LifecycleElement activate");
    super.activate();
  }

  @override
  void rebuild() {
    print("LifecycleElement rebuild");
    super.rebuild();
  }

  @override
  void deactivate() {
    print("LifecycleElement deactivate");
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    print("LifecycleElement didChangeDependencies");
    super.didChangeDependencies();
  }

  @override
  void update(Widget newWidget) {
    print("LifecycleElement update");
    super.update(newWidget);
  }

  @override
  Element updateChild(Element child, Widget newWidget, newSlot) {
    print("LifecycleElement updateChild");
    return super.updateChild(child, newWidget, newSlot);
  }

  @override
  void deactivateChild(Element child) {
    print("LifecycleElement deactivateChild");
    super.deactivateChild(child);
  }
}
