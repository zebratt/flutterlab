main(List<String> args) {
  var a = A();  

  a.show();
}

class C {
  final name = 'CCC';
}

class A extends B<C> {
  show(){
    print(ref.name);
  }
}

class B<T> {
  T ref;
}