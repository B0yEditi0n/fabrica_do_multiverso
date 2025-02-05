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

import 'dart:developer' as dev;

List _calculaBonusTotal(mapObj, [ List<int> bonusBase = const [0] ]){
    /*
      Retorna uma lista de valores que esse objeto pode assumir 
      caso haja efeitos aternativos do mesmo bonus
    */

    // 1 - Analisa se há mais de um bonus com o mesmo ID de criação
    List bonusAlternativo = [];
    Map b;
    int i = 0;
    List bonusLoop = [];
    List otherBonus = [];

    bonusLoop.addAll(mapObj["bonus"]);

    while (i < bonusLoop.length){
      b = bonusLoop[i];

      // Remove o Elemento atual da busca
      otherBonus = [];
      otherBonus.addAll(bonusLoop);
      otherBonus.removeAt(i);

      List arryBonus = [];
      if(otherBonus.any((bo) => bo["idArranjo"] == b["idArranjo"] && b["idArranjo"] != "")){
        // Adiciona o Atual da Lista e o Separa do Loop
        arryBonus.add(b);
        bonusLoop.removeAt(i);

        // Puxa os Efeitos Alternativos do Mesmo 
        // Grupo de b
        while(bonusLoop.any((bo) => bo["idArranjo"] == b["idArranjo"])) {
          int iFound = bonusLoop.indexWhere(
            (bo) => bo["idArranjo"] == b["idArranjo"]
          );
          Map bonusFound = bonusLoop[iFound];

          arryBonus.add(bonusFound);

          // Remove id encontrado para não duplica consulta
          bonusLoop.removeAt(iFound);
        }
        bonusAlternativo.add(arryBonus);
      }else{
        // Deixo no Else porque caso encotre isso embaralhá 
        // a contagem
        i++;
      }      
    }

    // Em bonusAlternativo todos os Efeitos de arranjo estão separados
    // Em bonusLoop coneterá efeitos não oriundos de EA;

    // Calcula Bonus Fixo
    int bonusFixo = mapObj["valor"];
    for (Map b in bonusLoop){
      bonusFixo += b["valor"] as int;
    }


    // Faz o calculo recursivo de todos o possíveis bonus
    List<int> lenIdx = [];  // contem o indice arry
    // int x = 0; // Posição Atual no Arry
    int idxA = 0; // Idex do Arry Atual

    int inxTmp = 0;

    // inicializa lenIdx
    for(var b in bonusAlternativo){lenIdx.add(0);}

    List<int> bonusAlternativoTotal = [];
    
    // Icremento de bonus
    for (int bonusSumBase in bonusBase) {
      do{
        idxA = 0; // Incia no primeiro arry

        // Calcula o bonus
        int total = bonusFixo + bonusSumBase;
        for(int i=0; i<lenIdx.length; i++){
          total += bonusAlternativo[i][lenIdx[i]]["valor"] as int;          
        }
        bonusAlternativoTotal.add(total);

        // - Lógica de Incremento
        try { // Caso não haja EAs
          lenIdx[idxA]++;  
        } catch (e) {
          continue; 
        }
        
        while( idxA < bonusAlternativo.length
        && lenIdx[idxA] >= bonusAlternativo[idxA].length ){
          // Zerá o indice atual
          lenIdx[idxA] = 0;

          // Incrementa o Próximo se Existir
          idxA++;
          if(idxA < bonusAlternativo.length){ lenIdx[idxA]++; }
        }

      }while(idxA < bonusAlternativo.length);
    }
    
    return bonusAlternativoTotal;
  }

void main() {
  //
  // Teste com Força
  //
  Map forca = {
      "id": "FOR",
      "nome": "Força",
      "valor": 2,
      "bonus": 
      [
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
        // {
        //   "id": "FOR",
        //   "valor": 4,
        //   "nome": "Força",
        //   "idOrigem": "P194806498e4",
        //   "idArranjo": "A19480647dfc"
        // },
        // {
        //   "idOrigem": "P1948064d4dc",
        //   "idArranjo": "A19480647dfc",
        //   "id": "FOR",
        //   "valor": 2,
        //   "nome": "Força"
        // },
        // {
        //   "idOrigem": "P19480658417",
        //   "idArranjo": "A19480654a96",
        //   "id": "FOR",
        //   "valor": 1,
        //   "nome": "Força"
        // },
        // {
        //   "id": "FOR",
        //   "valor": 2,
        //   "nome": "Força",
        //   "idOrigem": "P19480655e0e",
        //   "idArranjo": "A19480654a96"
        // },
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
  
  List habilidades = _calculaBonusTotal(forca);
  dev.debugger();
  print(habilidades);
}
