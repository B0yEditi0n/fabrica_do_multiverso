import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

/*
  Área de cópia de poderes (copiar e colar, como no app React).

  - Guarda UM poder por vez (efeito ou pacote), só na memória.
  - A cópia continua disponível depois de "Nova ficha" ou "Upload":
    serve para levar um poder de uma ficha para outra.
  - Colar cria um poder novo: ids de criação novos (inclusive dos efeitos
    internos), vínculo com o arranjo de destino e bônus aplicados na ficha.
  - O destino respeita as mesmas regras do "Adicionar":
      lista principal      - qualquer poder
      Efeitos Alternativos - efeitos e Efeitos Ligados  (E, D)
      Removível / Forma    - efeitos, Alternativos e Ligados (R, F)
      Efeitos Ligados      - só efeitos (L)
*/
class AreaDeCopia {
  static Map? _copiado;
  static const Uuid _uuid = Uuid();

  static const Map<String, List<String>> _aceitos = {
    "E": ["L"],
    "D": ["L"],
    "R": ["E", "D", "L"],
    "F": ["E", "D", "L"],
    "L": [],
  };

  static const Map<String, String> _nomesTipo = {
    "E": "Efeitos Alternativos",
    "D": "Efeitos Alternativos Dinâmicos",
    "R": "Pacote de Efeitos",
    "F": "Forma",
    "L": "Efeitos Ligados",
  };

  static bool get temCopia => _copiado != null;

  /// Nome exibido no botão "Colar"
  static String get nomeCopia {
    if (_copiado == null) return "";
    String nome = "${_copiado!["nome"] ?? ""}";
    String efeito = "${_copiado!["efeito"] ?? ""}";
    if (nome.isEmpty) return efeito;
    return efeito.isEmpty ? nome : "$nome ($efeito)";
  }

  static void copiar(Map poder) {
    _copiado = _copiaProfunda(poder);
  }

  static void limpar() {
    _copiado = null;
  }

  /// Motivo para não colar no destino (null = pode colar).
  /// tipoDestino: null para a lista principal ou o tipo do pacote.
  static String? motivoRecusa(String? tipoDestino) {
    if (_copiado == null) return "Nenhum poder copiado.";
    if (tipoDestino == null) return null;
    if (_copiado!["class"] != "PacotesEfeitos") return null;

    String tipo = "${_copiado!["tipo"]}";
    if ((_aceitos[tipoDestino] ?? []).contains(tipo)) return null;

    String destino = _nomesTipo[tipoDestino] ?? tipoDestino;
    String origem = _nomesTipo[tipo] ?? tipo;
    List<String> aceitos = _aceitos[tipoDestino] ?? [];
    String complemento = aceitos.isEmpty
        ? "só aceita efeitos"
        : "só aceita efeitos e ${aceitos.map((t) => _nomesTipo[t]).join(", ")}";
    return "$origem não pode ser colado em $destino: $destino $complemento.";
  }

  /// Cria o poder a partir da cópia.
  /// idPacoteDestino/tipoDestino: pacote que vai receber o poder (ou null).
  /// Aplica os bônus na ficha do personagem atual.
  static Map colar({String? idPacoteDestino, String? tipoDestino}) {
    String? recusa = motivoRecusa(tipoDestino);
    if (recusa != null) throw StateError(recusa);

    Map novo = _copiaProfunda(_copiado!);
    _renovaIds(novo, idPacoteDestino, tipoDestino);
    _aplicaBonus(novo);
    personagem.validador.updatePericiaBonus();
    return novo;
  }

  // ---------------------------------------------------------------------

  static Map _copiaProfunda(Map poder) => jsonDecode(jsonEncode(poder)) as Map;

  static bool _eBonus(Map p) =>
      ["EfeitoBonus", "EfeitoCrescimento"].contains(p["class"]);

  /// Novos ids de criação; efeitos de bônus ficam ligados ao arranjo
  /// que os contém (mesma regra de PacotesEfeitos.addPoder).
  static void _renovaIds(Map p, String? idPai, String? tipoPai) {
    if (p["class"] == "PacotesEfeitos") {
      String id = "A${_uuid.v4()}";
      p["idCriacao"] = id;
      p.remove("active"); // campo antigo, não é mais usado
      for (Map e in p["efeitos"] ?? []) {
        _renovaIds(e, id, "${p["tipo"]}");
      }
      return;
    }

    String id = "P${_uuid.v4()}";
    p["idCriacao"] = id;
    if (!_eBonus(p)) return;

    String idArranjo =
        ["L", "D", "E"].contains(tipoPai) && idPai != null ? idPai : "";
    p["idArranjo"] = idArranjo;
    p["active"] = true;
    for (Map alvo in p["alvoAumento"] ?? []) {
      alvo["idOrigem"] = id;
      alvo["idArranjo"] = idArranjo;
    }
  }

  static void _aplicaBonus(Map p) {
    if (p["class"] == "PacotesEfeitos") {
      for (Map e in p["efeitos"] ?? []) {
        _aplicaBonus(e);
      }
      return;
    }
    if (!_eBonus(p)) return;

    EfeitoBonus efeito = Efeito.doMapa(p) as EfeitoBonus;
    if (efeito is EfeitoCrescimento) {
      p["alvoAumento"] = efeito.returnBonusList();
    } else {
      efeito.configBonus();
    }
  }
}
