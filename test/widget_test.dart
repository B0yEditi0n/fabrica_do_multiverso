// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/main.dart';

import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

void main() {
  var pkg = EfeitoCompra();
  pkg.instanciarMetodo( 'Força Vital', 'E020');
  
}
