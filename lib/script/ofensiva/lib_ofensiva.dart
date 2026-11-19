// Ofensiva da ficha: a lista única de ataques e as linhas (acerto, efeito,
// CD e margem de crítico) consumidas pelo menu Ofensiva e pelo PDF.
// A tela e o PDF só formatam estas linhas; nenhum dos dois recalcula.
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/habilidades/lib_habilidades.dart';
import 'package:fabrica_do_multiverso/script/vantagens/lib_vantagens.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

class Ofensiva {
  static String comSinal(int valor) => valor >= 0 ? '+$valor' : '$valor';

  /// Ataques listados na Ofensiva: Desarmado e Arremesso (se incluídos no
  /// menu Ofensiva) primeiro, como no modelo, depois os poderes.
  static List ataques() {
    // Efeitos Ofensivos: junta os de Perto (+ Desarmado) e a Distância (+ Arremesso)
    List poderes = [];
    poderes.addAll(personagem.pericias.returnOfensiveEfeitos(1));
    poderes.addAll(personagem.pericias.returnOfensiveEfeitos(2));

    List nativos = poderes
        .where((p) => p["noPower"] == true)
        .where((p) => p["idCriacao"] != "F1" || personagem.incluirDesarmado)
        .where((p) => p["idCriacao"] != "F2" || personagem.incluirArremesso)
        .toList()
      ..sort((a, b) => a["idCriacao"] == "F1" ? -1 : 1);
    List outros = poderes.where((p) => p["noPower"] != true).toList();
    return [...nativos, ...outros];
  }

  static int _habilidade(String id) {
    Habilidade obj = Habilidade();
    obj.initObject(personagem.habilidades.getItem(id));
    return obj.valorTotal();
  }

  static int _vantagem(String id) {
    List vantagens = personagem.vantagens.listaVantagens;
    if (!vantagens.any((v) => v["id"] == id)) return 0;
    return Vantagem().init(vantagens.firstWhere((v) => v["id"] == id))
        .returnTotalGrad();
  }

  /// Uma linha por ataque:
  ///   nome, acerto (int; null = Automático), efeito ("Dano 8"),
  ///   cd (int ou null), cdTexto ("23 Resistência (…)"),
  ///   ameaca (20 = sem melhoria) e critico ("Crítico 18-20" ou "").
  /// Mesma regra de bônus usada em ValidaNpPersonagem._efeitos().
  static List<Map> linhas() {
    int luta = _habilidade("LUT");
    int destreza = _habilidade("DES");
    int forca = _habilidade("FOR");
    int corpoACorpo = _vantagem("V013"); // Ataque Corpo-a-Corpo
    int aDistancia = _vantagem("V011"); // Ataque à Distância

    List<Map> saida = [];
    for (Map p in ataques()) {
      // Desarmado / Arremesso: não vêm de um poder cadastrado
      if (p["noPower"] == true) {
        bool ePerto = p["idCriacao"] == "F1";
        saida.add({
          "nome": p["nome"],
          "acerto": ePerto ? luta + corpoACorpo : destreza + aDistancia,
          "efeito": 'Dano $forca',
          "cd": forca + 15,
          "cdTexto": '${forca + 15} Resistência',
          "ameaca": 20,
          "critico": "",
        });
        continue;
      }

      // Síncrono: o catálogo já foi carregado em Ficha.init
      Efeito objectEfeito = Efeito.doMapa(p);
      Map objEfeitoJson = objectEfeito.retornaObj();

      int alcance = p["alcance"] ?? objEfeitoJson["alcance"];
      int totalAcerto = alcance == 1
          ? luta + corpoACorpo
          : alcance == 2
              ? destreza + aDistancia
              : 0;
      if (objectEfeito is EfeitoOfensivo) {
        totalAcerto += objectEfeito.totalBonusAcerto();
      }

      // A ficha só sabe qual defesa resiste ao Dano (Resistência).
      // Para os demais efeitos mostra apenas o valor da CD.
      int? cd = objEfeitoJson["cd"];
      String cdTexto = '';
      if (cd != null) {
        cdTexto = '$cd';
        if (objEfeitoJson["class"] == "EfeitoDano") cdTexto += ' Resistência';
      }
      if (objEfeitoJson["class"] == "EfeitoAflicao" &&
          objEfeitoJson["condicoes"] != null) {
        List condicoes = (objEfeitoJson["condicoes"] as List)
            .where((c) => c != null && c.toString().isNotEmpty)
            .toList();
        if (condicoes.isNotEmpty) cdTexto += ' (${condicoes.join(', ')})';
      }

      int ameaca = EfeitoOfensivo.ameacaCritico(p);
      saida.add({
        "nome": objectEfeito.nome.isNotEmpty
            ? objectEfeito.nome
            : "${objEfeitoJson["efeito"]}",
        "acerto": alcance == 3 ? null : totalAcerto,
        "efeito": '${objEfeitoJson["efeito"]} ${objEfeitoJson["graduacao"]}',
        "cd": cd,
        "cdTexto": cdTexto,
        "ameaca": ameaca,
        "critico": EfeitoOfensivo.textoCritico(ameaca),
      });
    }
    return saida;
  }

  /// "Garras +12 (Dano 8, CD 23, Crítico 18-20)"
  static String resumo(Map linha) {
    String acerto =
        linha["acerto"] == null ? 'Automático' : comSinal(linha["acerto"]);
    List<String> partes = [
      "${linha["efeito"]}",
      if (linha["cd"] != null) 'CD ${linha["cd"]}',
      if ("${linha["critico"]}".isNotEmpty) "${linha["critico"]}",
    ];
    return '${linha["nome"]} $acerto (${partes.join(', ')})';
  }
}
