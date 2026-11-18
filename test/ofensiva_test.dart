// Menu de Ofensiva: ataque desarmado opcional na ficha, no PDF e no limite de NP.

import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/screens/components/printer.dart';
import 'package:fabrica_do_multiverso/script/ficha.dart';

List<String> nomesNaOfensiva() =>
    Printer.ataquesOfensiva().map((a) => "${a["nome"]}").toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    personagem = Ficha();
    await personagem.init();
  });

  test('desarmado entra na ofensiva do PDF só quando incluído', () {
    personagem.incluirDesarmado = true;
    expect(nomesNaOfensiva(), contains('Desarmado'));

    personagem.incluirDesarmado = false;
    expect(nomesNaOfensiva(), isNot(contains('Desarmado')));
  });

  test('desarmado incluído respeita acerto + dano <= 2 x NP', () {
    personagem.np = 10;
    personagem.habilidades.getItem("FOR")["valor"] = 12; // dano 12
    personagem.habilidades.getItem("LUT")["valor"] = 9; // acerto 9
    bool desarmadoForaDoLimite() => ValidaNpPersonagem()
        .validacaoGeral()
        .any((e) => e["nome"] == "Desarmado");

    personagem.incluirDesarmado = true;
    expect(desarmadoForaDoLimite(), isTrue);

    personagem.incluirDesarmado = false;
    expect(desarmadoForaDoLimite(), isFalse);
  });

  test('desarmado dentro do limite não gera alerta', () {
    personagem.np = 10;
    personagem.habilidades.getItem("FOR")["valor"] = 10;
    personagem.habilidades.getItem("LUT")["valor"] = 10;
    expect(
        ValidaNpPersonagem()
            .validacaoGeral()
            .any((e) => e["nome"] == "Desarmado"),
        isFalse);
  });

  test('a escolha é salva na ficha; ficha antiga inclui o desarmado', () async {
    personagem.incluirDesarmado = false;
    Map json = personagem.returnObjJson();

    Ficha recarregada = Ficha();
    await recarregada.reInit(json);
    expect(recarregada.incluirDesarmado, isFalse);

    json.remove("ofensiva"); // versões anteriores não tinham o campo
    Ficha antiga = Ficha();
    await antiga.reInit(json);
    expect(antiga.incluirDesarmado, isTrue);
  });
}
