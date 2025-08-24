import 'dart:developer' as dev;

class Habilidade {
  String _id = "";
  String nome = "";
  int valor = 0;
  List bonus = []; // Caso venha de alguma pode ou modificador

  bool ausente = false;

  Habilidade init(id, valor, nome) {
    _id = id;
    this.valor = valor;
    this.nome = nome;

    return this;
  }

  Habilidade reInit(object){
    _id = object["id"];
    nome = object["nome"];
    ausente = object["ausente"];
    valor = object["valor"];
    bonus = object["bonus"];

    return this;
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
    int bonusFixo = 0;
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

    while(idxA < bonusAlternativo.length){
      idxA = 0; // Incia no primeiro arry

      print('Arry; $lenIdx');

      // Calcula o bonus
      int total = bonusFixo + valor;
      for(int i=0; i<lenIdx.length; i++){
        total += bonusAlternativo[i][lenIdx[i]]["valor"] as int;          
      }
      bonusAlternativoTotal.add(total);

      // - Lógica de Incremento
      lenIdx[idxA]++;
      while( idxA < bonusAlternativo.length
      && lenIdx[idxA] >= bonusAlternativo[idxA].length ){
        // Zerá o indice atual
        lenIdx[idxA] = 0;

        // Incrementa o Próximo se Existir
        idxA++;
        if(idxA < bonusAlternativo.length){ lenIdx[idxA]++; }
      }

    }
    
    return [bonusAlternativoTotal];
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
