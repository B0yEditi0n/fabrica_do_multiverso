import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

/*
  Custo de poderes compostos.

  Trabalha direto sobre os mapas salvos na ficha (efeitos e pacotes),
  de forma síncrona e sem alterar nada. As telas e o PDF devem consultar
  esta classe em vez de somar custos por conta própria.

  Regras (Modificadores, M&M 3ª edição):
  - Ligados e pacotes simples: soma dos custos dos efeitos.
  - Efeitos Alternativos: custo do efeito mais caro (o primário)
    + 1 ponto por efeito alternativo.
  - Efeitos Alternativos Dinâmicos: custo do mais caro + 1 ponto para
    tornar o efeito básico dinâmico + 2 pontos por alternativo.
  - Removível: -1 ponto a cada 5 pontos do custo final do poder;
    Facilmente Removível: -2 a cada 5.
  - Equipamento: pago com pontos de equipamento (5 por graduação da
    vantagem Equipamento), não com pontos de poder.
*/
class CustoPoderes {
  static const String classePacote = "PacotesEfeitos";

  static bool ePacote(Map item) =>
      [classePacote, "EfeitosAlternativos"].contains(item["class"]);

  static bool eEquipamento(Map item) =>
      ePacote(item) &&
      (item["efeito"] == "Equipamentos" || (item["removivel"] ?? 0) >= 4);

  /// Custo de um efeito isolado, recalculado a partir do mapa.
  static int custoEfeito(Map efeito) {
    if (Efeito.catalogoCarregado) {
      return Efeito.doMapa(efeito).custearAlteracoes();
    }
    // Catálogo ainda não lido: usa o último custo gravado na ficha
    return efeito["custo"] ?? 0;
  }

  /// Soma dos efeitos de um pacote, sem aplicar a regra do pacote.
  static int somaInterna(Map pacote) {
    int soma = 0;
    for (Map e in pacote["efeitos"] ?? []) {
      soma += custoBruto(e);
    }
    return soma;
  }

  /// Custo de um item ignorando se ele é equipamento
  /// (um equipamento vale aqui seus pontos de equipamento).
  static int custoBruto(Map item) {
    if (!ePacote(item)) return custoEfeito(item);

    List efeitos = item["efeitos"] ?? [];
    if (efeitos.isEmpty) return 0;

    switch (item["tipo"]) {
      case "E": // Efeitos Alternativos
        return _maiorCusto(efeitos) + (efeitos.length - 1);
      case "D": // Efeitos Alternativos Dinâmicos
        if (efeitos.length == 1) return _maiorCusto(efeitos);
        return _custoDinamico(efeitos);
      default: // Ligados, Removível, Formas e pacotes simples
        int soma = somaInterna(item);
        if (eEquipamento(item)) return soma;
        int removivel = item["removivel"] ?? 0;
        return soma - removivel * (soma ~/ 5);
    }
  }

  /// Arranjo dinâmico: o mais caro + 1 se ele for dinâmico,
  /// + 2 por alternativo dinâmico e + 1 por alternativo comum.
  /// Sem a marca "dinamico" (fichas feitas na Fábrica) todos os efeitos
  /// são dinâmicos; fichas importadas do app React trazem a marca efeito
  /// a efeito e são cobradas como no app de origem.
  static int _custoDinamico(List efeitos) {
    bool dinamico(Map e) => e["dinamico"] != false;
    int iMaior = 0;
    int maior = -1;
    for (int i = 0; i < efeitos.length; i++) {
      int custo = custoBruto(efeitos[i]);
      if (custo > maior) {
        maior = custo;
        iMaior = i;
      }
    }
    int total = maior + (dinamico(efeitos[iMaior]) ? 1 : 0);
    for (int i = 0; i < efeitos.length; i++) {
      if (i == iMaior) continue;
      total += dinamico(efeitos[i]) ? 2 : 1;
    }
    return total;
  }

  static int _maiorCusto(List efeitos) {
    int maior = 0;
    for (Map e in efeitos) {
      int custo = custoBruto(e);
      if (custo > maior) maior = custo;
    }
    return maior;
  }

  /// Custo em pontos de poder. Equipamentos custam 0 aqui.
  static int custoItem(Map item) => eEquipamento(item) ? 0 : custoBruto(item);

  /// Total em pontos de poder de uma lista de poderes.
  static int totalPoderes(List poderes) {
    int total = 0;
    for (Map p in poderes) {
      total += custoItem(p);
    }
    return total;
  }

  /// Total de pontos de equipamento usados na lista de poderes.
  static int pontosEquipamento(List poderes) {
    int total = 0;
    for (Map p in poderes) {
      if (eEquipamento(p)) total += custoBruto(p);
    }
    return total;
  }
}
