// Aflição: remover condições por Grau Limitado / Limitado a Terceiro Grau.

import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

Future<EfeitoAflicao> aflicao(int grad) async {
  EfeitoAflicao e = EfeitoAflicao();
  await e.instanciarMetodo("Sono", "E001");
  e.setGrad(grad);
  e.addCondicao(0, "Tonto");
  e.addCondicao(1, "Atordoado");
  e.addCondicao(2, "Incapacitado");
  return e;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    personagem = Ficha();
    await personagem.init();
  });

  test('sem limitação custa 1/grad', () async {
    EfeitoAflicao e = await aflicao(10);
    expect(e.custearAlteracoes(), 10);
    expect(e.limiteGrau(), EfeitoAflicao.semLimite);
  });

  test('remover 3ª condição: Grau Limitado -1/grad', () async {
    EfeitoAflicao e = await aflicao(10);
    e.setLimiteGrau(EfeitoAflicao.semTerceira);
    expect(e.custearAlteracoes(), 5); // 0/grad = 1 por 2 graduações
    expect(e.retornaObj()["condicoes"], ["Tonto", "Atordoado", ""]);
    expect(e.retornaObj()["modificadores"].single["nome"], "Grau Limitado");
  });

  test('remover 2ª e 3ª condição: Grau Limitado 2, -2/grad', () async {
    EfeitoAflicao e = await aflicao(10);
    e.setLimiteGrau(EfeitoAflicao.semSegundaTerceira);
    expect(e.custearAlteracoes(), 4); // -1/grad = 1 por 3 graduações
    expect(e.retornaObj()["condicoes"], ["Tonto", "", ""]);
    expect(e.limiteGrau(), EfeitoAflicao.semSegundaTerceira);
  });

  test('remover 1ª e 2ª condição: Limitado a Terceiro Grau -1/grad', () async {
    EfeitoAflicao e = await aflicao(10);
    e.setLimiteGrau(EfeitoAflicao.apenasTerceira);
    expect(e.custearAlteracoes(), 5);
    expect(e.retornaObj()["condicoes"], ["", "", "Incapacitado"]);
    expect(e.condicaoAtiva(2), isTrue);
    expect(e.condicaoAtiva(0), isFalse);
  });

  test('opções são exclusivas e desmarcar remove a falha', () async {
    EfeitoAflicao e = await aflicao(10);
    e.setLimiteGrau(EfeitoAflicao.semTerceira);
    e.setLimiteGrau(EfeitoAflicao.apenasTerceira);
    expect(e.retornaObj()["modificadores"].length, 1);
    e.setLimiteGrau(EfeitoAflicao.semLimite);
    expect(e.retornaObj()["modificadores"], isEmpty);
    expect(e.custearAlteracoes(), 10);
  });
}
