class A {
  void update() {
    print('update a');
  }
}

class B {
  void update() {
    print('update b');
  }
}

class C extends A with B {
}

main() {
  var c = C();  
  c.update();
}
