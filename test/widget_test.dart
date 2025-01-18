// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/main.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/habilidades/lib_habilidades.dart';

void main() {
  //
  // Teste com Força
  //
  Map forca = {
    "id": "FOR",
    "nome": "Força",
    "valor": 5,
    "bonus": [
      {"id": "FOR", "valor": 8, "nome": "Força", "idOrigem": "A1947a71e604"},
      {"idOrigem": "P1947a735449", "id": "FOR", "valor": 3, "nome": "Força"}
    ],
    "ausente": false
  };
  Habilidade testHab = Habilidade();
  testHab.initObject(forca);
  List habilidades = testHab.valoresTotais();
}
