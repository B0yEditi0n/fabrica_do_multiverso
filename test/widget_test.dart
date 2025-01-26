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
      "valor": 2,
      "bonus": [
        {
          "idOrigem": "P1948063b613",
          "idArranjo": "A19480638e96",
          "id": "FOR",
          "valor": 5,
          "nome": "Força"
        },
        {
          "id": "FOR",
          "valor": 8,
          "nome": "Força",
          "idOrigem": "P1948063dc80",
          "idArranjo": "A19480638e96"
        },
        {
          "id": "FOR",
          "valor": 4,
          "nome": "Força",
          "idOrigem": "P194806498e4",
          "idArranjo": "A19480647dfc"
        },
        {
          "idOrigem": "P1948064d4dc",
          "idArranjo": "A19480647dfc",
          "id": "FOR",
          "valor": 2,
          "nome": "Força"
        },
        {
          "idOrigem": "P19480658417",
          "idArranjo": "A19480654a96",
          "id": "FOR",
          "valor": 1,
          "nome": "Força"
        },
        {
          "id": "FOR",
          "valor": 2,
          "nome": "Força",
          "idOrigem": "P19480655e0e",
          "idArranjo": "A19480654a96"
        },
        {
          "id": "FOR",
          "valor": 3,
          "nome": "Força",
          "idOrigem": "P1948067f077",
          "idArranjo": ""
        }
      ],
      "ausente": false
    };
    
  Habilidade testHab = Habilidade();
  testHab.initObject(forca);
  List habilidades = testHab.valoresTotais();
  print(habilidades);
}
