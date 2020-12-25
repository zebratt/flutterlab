abstract class Fruit {}

// class Banana with Roller{

// }

class Apple extends Fruit with Roller {
}

mixin Roller on Fruit {
  roll(){
    print('rolling...');
  }
}

main(List<String> args) {
  var apple = Apple();

  apple.roll();
}