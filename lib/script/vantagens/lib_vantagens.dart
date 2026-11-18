import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';

class Vantagem {
  String id = "";
  String nome = "";
  bool desc = false;  
  bool graduado = false;

  // Especifico
  String txtDec = ""; // texto inputado pelo usuário
  int _graduacao = 0;
  int limite = 0;

  String idOrigem = ''; // ID do Poder criador
  bool addByPower = false; // Adicionado por poder?
  List bonus = []; // vantagem adicionada por bonus

  List alvoBonus = []; // alvo de bonus da vantagem


  init(obj){
    id = obj["id"];
    nome = obj["nome"];
    graduado = obj["graduado"];
    desc = obj["desc"];

    //; Atributos Especificos
    if(obj["graduacao"] != null){
      _graduacao = obj["graduacao"];
    }
    if(obj["limite"] != null){
      limite = obj["limite"];
    }
    if(obj["txtDec"] != null){
      txtDec = obj["txtDec"];
    }

    if(obj["alvo_bonus"] != null){
      //bonus.addAll();
      alvoBonus.addAll(obj["alvo_bonus"].map((e) => e.toString() ).toList());
    }

    if(obj["idOrigem"] != null){idOrigem = obj["idOrigem"];}
    addByPower = obj["addByPower"] == true;
    if(obj["bonus"] != null){bonus.addAll(obj["bonus"]);}

    return this;
  }

  int grad() => _graduacao;

  //; Catálogo de vantagens (assets/vantagens.json)
  static List? _catalogo;

  static Future<List> carregarCatalogo() async {
    _catalogo ??= jsonDecode(await rootBundle.loadString('assets/vantagens.json'));
    return _catalogo!;
  }

  int? graduacaoMaxima() {
    /*
      Teto oficial de graduação. Não graduada: 1. Graduada com teto no
      catálogo: o teto. Graduada sem teto: null (limitada só pelo NP).
      Teto pela metade do NP (Sorte): "limite_meio_np" no catálogo.
      O catálogo prevalece sobre o "limite" salvo na ficha.
    */
    if (!graduado) return 1;
    Map? doCatalogo = _catalogo?.cast<Map?>().firstWhere(
        (v) => v!["id"] == id, orElse: () => null);
    if (doCatalogo?["limite_meio_np"] == true) return personagem.np ~/ 2;
    int teto = doCatalogo != null ? (doCatalogo["limite"] ?? 0) : limite;
    return teto > 0 ? teto : null;
  }

  int limitaGraduacao(int valor) {
    // Graduação válida mais próxima: entre 1 e o teto oficial
    int? teto = graduacaoMaxima();
    if (valor < 1) return 1;
    return teto != null && valor > teto ? teto : valor;
  }

  bool acimaDoLimite() => limitaGraduacao(_graduacao) < _graduacao;

  int returnTotalGrad(){
    int totalBonus = 0;
    for (Map b in bonus){
      totalBonus += b["valor"] as int;
    }

    return _graduacao + totalBonus;
  }

  int returnTotalCusto(){
    // Só as graduações dentro do teto oficial custam pontos.
    return acimaDoLimite() ? graduacaoMaxima()! : _graduacao;

  }

  Map returnObj(){
    return{
      "id": id,
      "nome": nome,
      "desc": desc,
      "txtDec": txtDec,
      "graduado": graduado,
      "graduacao": _graduacao,
      "limite": limite,
      "idOrigem": idOrigem,
      "bonus": bonus,      
      "addByPower" : addByPower,
      "alvo_bonus": alvoBonus,
      "class": "Vantagem",
    };
  }
}