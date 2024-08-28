// import 'package:flutter/foundation.dart';
// import 'package:flutter_test/flutter_test.dart';

class vaca{
  String animal = 'Vaquinha';
  daLeite(){
    return('Mu');
  }
}

class Boi extends vaca{
  DaXifre(){
    return('ai');
  }
}


AnalisaClass(String classe){
  var obj = Object();
  
  switch(classe){
    case('boi'):
      obj = Boi();
      return obj;
    case('vaca'):
      obj = vaca();
      return obj;
  }
    
}


void main() {
  var pkg = AnalisaClass('vaca');

  print(pkg.DaXifre());
  print(pkg.daLeite());

  //pkg.instanciarMetodo('Poder', 'E001');
  
}