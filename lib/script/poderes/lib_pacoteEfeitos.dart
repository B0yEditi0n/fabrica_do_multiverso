import 'dart:async';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:uuid/uuid.dart';

class PacotesEfeitos {
  // Os efeitos anexados a esse pacote
  List efeitos = [];

  // Nome a ser exibido nos widgets
  String nomePacote = "";

  // Descrição do Pacote
  String _efeito = '';

  // Aqui deve ser inserido o valor do abate no custo
  // Exemplo Facilmente Removivel = 2 (abate 2 a cada 5 pontos)
  int removivel = 0;

  // F - Repertório (Forma)
  // L - Ligado
  // E - Efeito Alternativo
  // D - Efeito Alternativo Dinamico
  // R - Removivel
  int _groupType = 0;

  // Id de Criação
  String _idCriacao = "";

  // Controle de Efeitos Ativos (EAs)
  int _indexPoderAtivo = 0;

  // ***************************
  // Methodos de Inicialização *
  // ***************************
  Future<bool> instanciarMetodo(Map mapObject) async {
    /*
      Carrega os atributos básicos do efeito 
      o algoritimo que o chamar precisa usar await
      para carregar o json

      Args:
        Map mapObject - mapa para carregamento da classe
      Return:
        Map Json - o Arquivo json
    */

    nomePacote = mapObject["nome"];
    setType(mapObject["tipo"]);
    removivel = mapObject["removivel"];
    _efeito = mapObject["efeito"];

    if (mapObject["efeitos"] != null) {
      for (Map efeito in mapObject["efeitos"]) {
        efeitos.add(efeito);
      }
    }

    if (mapObject["idCriacao"] != null) {
      _idCriacao = mapObject["idCriacao"];
    } else {
      const uuid = Uuid();
      _idCriacao = "A${uuid.v4()}";
    }

    if(mapObject["active"] != null){
      _indexPoderAtivo = mapObject["active"];      
    }

    return true;
  }

  setType(String char) {
    /*
      Flutter não trabalha com char1, portanto esse método
      será usado para converter string em tipo e vice versa
      
      Parm:
        - Args:
          String char | caractere unico a ser convertido
    */

    _groupType = char.codeUnitAt(0);
  }

  String getType() {
    /*
      Flutter não trabalha com char1, portanto esse método
      será usado para converter string em tipo e vice versa
      
      Returns: String | caractere unico convertido
    */

    return String.fromCharCode(_groupType);
  }

  void addPoder(Map objPoder) {
    /*
      Adiciona poderes a lista de pacotes
      e podem haver tratativas
    */

    // Tratativa para Efeitos Alternativos e Efeitos Bonus
    // Efeitos ligados apenas porque são subtipos de EAs
    if (["L", "D", "E"].contains(getType()) &&
        (objPoder["class"] == "EfeitoBonus" ||
         objPoder["class"] == "EfeitoCrescimento")) {

      // Sobreescrever o Valor do id de criação
      objPoder["idArranjo"] = _idCriacao;
    }

    efeitos.add(objPoder);
  }

  int activeEfeito() => _indexPoderAtivo;
  Future<bool> defineActive(int index) async{
    /*
      define qual o efeito ativo
      e faz a validação correta dentre os Ids.
    */

    // Replica alteração em efeitos de Bonus
    EfeitoBonus poderActive = EfeitoBonus();
    // - Limpa o Atual (se houver)
    while(efeitos.any(
      (e) => e["active"] == true && ["EfeitoBonus", "EfeitoCrescimento"].contains(e["class"])
    )){
    int eIdx = efeitos.indexWhere(
      (e) => e["active"] == true && ["EfeitoBonus", "EfeitoCrescimento"].contains(e["class"])
    );
    // if(eIdx > -1){
    switch(efeitos[eIdx]["class"]){
      case "EfeitoCrescimento":
        poderActive = EfeitoCrescimento();
        break;
      case "EfeitoBonus":
        poderActive = EfeitoBonus();
        break;
      // }
    }
      await poderActive.reinstanciarMetodo(efeitos[eIdx]);
      poderActive.active = false;
      poderActive.configBonus(); // Recarrega os Bonus
      efeitos[eIdx] = poderActive.retornaObj();
    }

    // - Ativa se for bonus
    if(index > -1){
      if(["EfeitoBonus", "EfeitoCrescimento"].contains(efeitos[index]["class"])){
        await poderActive.reinstanciarMetodo(efeitos[index]);
        poderActive.active = true;
        poderActive.configBonus(); // Recarrega os Bonus
        efeitos[index] = poderActive.retornaObj();
      }
    }

    _indexPoderAtivo = index;

    return true;
  }

  int custearAlteracoes() {
    /*
      Define o custo do pacote de efeitos

      Return:
        int | custo do pacote
    */

    return 0;
  }

  void destrutor() {
    for (var e in efeitos) {
      if(e["class"] != "PacotesEfeitos"){
        switch (e["class"]) {
          case "EfeitoCrescimento":
            poder = EfeitoCrescimento();
            break;
          case "EfeitoBonus":
            poder = EfeitoBonus();
            break;
          case "EfeitoAflicao":
            poder = EfeitoAflicao();
            break;
          case "EfeitoDano":
            poder = EfeitoDano();
            break;
          case "EfeitoCompra":
            poder = EfeitoCompra();
            break;
          case "EfeitoCustoVaria":
            poder = EfeitoCustoVaria();
            break;
          case "EfeitoOfensivo":
            poder = EfeitoOfensivo();
            break;
          case "PacotesEfeitos": // Efeitos Alternativos podem conter
            break;
          case "Efeito":
          default:
            poder = Efeito();
            break;
        }

        poder.reinstanciarMetodo(e);
        poder.destrutor();

      }else{
        PacotesEfeitos pacote = PacotesEfeitos();
        pacote.instanciarMetodo(e);
        pacote.destrutor();
      }
    }
  }

  Map<String, dynamic> retornaObj() {
    /*
      Retorna um json com os dados montados

      Return:
        Map Json - o Arquivo json
    */
    return {
      "nome": nomePacote,
      "efeito": _efeito,
      "tipo": getType(),
      "removivel": removivel,
      "custo": custearAlteracoes(),
      "class": "PacotesEfeitos",
      "efeitos": efeitos,
      "idCriacao": _idCriacao,
      "active": _indexPoderAtivo,
    };
  }
}

class EfeitosAlternativos extends PacotesEfeitos {}

class extractPacote {
  // Classe de Extração de Pacotes Para Contabilização dos Efeitos
  List getEfeitos(Map mapPacote) {
    List efeitos = [];

    efeitos.addAll(linearizarPacote(mapPacote));

    return efeitos;
  }

  List linearizarPacote(Map pacote) {
    List efeitos = [];
    // Extrai os Elementos Ofensivos
    for (Map p in pacote["efeitos"]) {
      // Checa é Ofensivo
      if (["EfeitoAflicao", "EfeitoOfensivo", "EfeitoDano"]
          .contains(p["class"])) {
        efeitos.add(p);
      }
      // Checa se há pacotes encapsulados
      if (["PacotesEfeitos", "EfeitosAlternativos"].contains(p["class"])) {
        efeitos.addAll(getEfeitos(p));
      }
    }

    return efeitos;
  }
}
