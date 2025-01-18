class Habilidade {
  String _id = "";
  String nome = "";
  int valor = 0;
  List bonus = []; // Caso venha de alguma pode ou modificador

  bool ausente = false;

  init(id, valor, nome) {
    _id = id;
    this.valor = valor;
    this.nome = nome;
  }

  int initObject(object) {
    _id = object["id"];
    nome = object["nome"];
    ausente = object["ausente"];
    valor = object["valor"];
    bonus = object["bonus"];

    return 1;
  }

  int custoTotal() {
    /* Retorna o custo */
    if (!ausente) {
      return valor * 2;
    } else {
      return -10;
    }
  }

  int valorTotal() {
    /* Retorna o bonus total */
    int bonusTotal = 0;
    for (Map b in bonus) {
      bonusTotal += int.parse("${b["valor"]}");
    }

    return bonusTotal + valor;
  }

  List valoresTotais() {
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

    bonusLoop.addAll(bonus);

    do {
      b = bonus[i];

      // Remove o Elemento atual da busca
      otherBonus = [];
      otherBonus.addAll(bonusLoop);
      otherBonus.removeAt(i);

      if (otherBonus.any((bo) => bo["idOrigem"] == b["idOrigem"])) {
        int iFound =
            otherBonus.indexWhere((bo) => bo["idOrigem"] == b["idOrigem"]);
        Map bonusFound = otherBonus[iFound];

        bonusAlternativo.add({
          b,
          bonusFound,
        });

        // Remove id encontrado para não duplica consulta
        bonusLoop.removeAt(iFound);
      }
      i++;
    } while (i < bonusLoop.length);

    // 2 - Checar se a herança possui lista de bonus (se Houver);

    // 3 - Retornar uma lista pra cada indice
    //  Somar não indices
    //  Somar Indices

    return [];
  }

  Map objHabilidade() {
    return {
      "id": _id,
      "nome": nome,
      "valor": valor,
      "bonus": bonus,
      "ausente": ausente,
    };
  }
}
