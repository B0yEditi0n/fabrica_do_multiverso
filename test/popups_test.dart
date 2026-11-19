// Popups da ficha: abrem como diálogo sobre a tela de origem (que continua
// visível), ficam centralizados e o seletor tem busca sem acento.
// Especificação Técnica, seção "Popups de inclusão e edição".

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fabrica_do_multiverso/script/armazenamento.dart';
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/theme/theme.dart';
import 'package:fabrica_do_multiverso/screens/components/abrir_popup.dart';
import 'package:fabrica_do_multiverso/screens/components/dropdown_com_busca.dart';
import 'package:fabrica_do_multiverso/screens/complicacoes/ScreenComplicacoes.dart';
import 'package:fabrica_do_multiverso/screens/pericias/ScreenPericias.dart';
import 'package:fabrica_do_multiverso/screens/pericias/functions/addPericias.dart';
import 'package:fabrica_do_multiverso/screens/poderes/ScreenControlePacote.dart';
import 'package:fabrica_do_multiverso/screens/poderes/ScreenEditorPoderes.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/screens/poderes/ScreenPoderes.dart';
import 'package:fabrica_do_multiverso/screens/poderes/poderes/popup_addPoderes.dart';
import 'package:fabrica_do_multiverso/screens/vantagens/ScreenVantagens.dart';

Future<void> usarTela(WidgetTester tester, Size tamanho) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = tamanho;
  addTearDown(tester.view.reset);
}

/// Deixa terminar as leituras de catálogo (disco real) e redesenha.
Future<void> assentar(WidgetTester tester) async {
  for (int i = 0; i < 5; i++) {
    await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Widget embrulhar(Widget tela) => MaterialApp(theme: temaPadrao(), home: tela);

/// Tela simples com um botão que abre [popup] por abrirPopup.
Future<void> abrirComoPopup(WidgetTester tester, Widget popup,
    {void Function(Object?)? aoFechar}) async {
  await tester.pumpWidget(embrulhar(Builder(
    builder: (context) => Scaffold(
      appBar: AppBar(title: const Text('Tela de baixo')),
      body: Center(
        child: TextButton(
          child: const Text('abrir'),
          onPressed: () async {
            final Object? r = await abrirPopup<Object>(context, popup);
            aoFechar?.call(r);
          },
        ),
      ),
    ),
  )));
  await tester.tap(find.text('abrir'));
  await assentar(tester);
}

AlertDialog popupSimples() => AlertDialog(
      title: const Text('Popup'),
      content: const Text('conteúdo'),
      actions: [
        Builder(
          builder: (context) => TextButton(
            child: const Text('Ok'),
            onPressed: () => Navigator.of(context).pop('ok'),
          ),
        ),
      ],
    );

/// A caixa visível do diálogo (o widget Dialog ocupa a tela toda, com o recuo).
Finder caixaDoDialogo() => find
    .descendant(of: find.byType(Dialog), matching: find.byType(Material))
    .first;

/// Título da AppBar da tela de origem, só se estiver sendo desenhado.
Finder tituloDaTela(String titulo) => find.descendant(
    of: find.byType(AppBar), matching: find.text(titulo));

/// Cria o poder na ficha e abre o editor dele.
Future<void> abrirEditor(WidgetTester tester, String eId, String classe,
    {int? graduacao}) async {
  await tester.runAsync(
      () => personagem.poderes.novoPoder("Teste", eId, classe));
  final Map obj = personagem.poderes.poderesLista.last;
  if (graduacao != null) obj["graduacao"] = graduacao;
  await tester.pumpWidget(embrulhar(powerEdit(objEfeito: obj)));
  await assentar(tester);
}

/// Toca num botão do editor (rolando até ele) e espera o popup carregar.
Future<void> tocarNoEditor(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await assentar(tester);
}

/// Espera o seletor do popup ter opções (catálogos lidos do disco).
Future<void> esperarOpcoes<T>(WidgetTester tester) async {
  for (int i = 0; i < 40; i++) {
    final Finder f = find.byType(DropdownComBusca<T>);
    if (f.evaluate().isNotEmpty &&
        tester.widget<DropdownComBusca<T>>(f.last).opcoes.isNotEmpty) {
      return;
    }
    await assentar(tester);
  }
}

/// Abre o seletor, busca [termo] e escolhe o item [rotulo].
Future<void> escolherPelaBusca<T>(
    WidgetTester tester, String termo, String rotulo) async {
  await esperarOpcoes<T>(tester);
  await tester.tap(find.byType(DropdownComBusca<T>).last);
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).last, termo);
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(
      of: find.byType(ListTile), matching: find.text(rotulo)));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory pasta;

  setUpAll(() async {
    final String? raiz = Platform.environment['FLUTTER_ROOT'];
    if (raiz == null) return;
    final FontLoader roboto = FontLoader('Roboto');
    for (final String peso in ['regular', 'medium', 'bold']) {
      final File arq = File(
          '$raiz/bin/cache/artifacts/material_fonts/roboto-$peso.ttf');
      if (!arq.existsSync()) return;
      roboto.addFont(arq
          .readAsBytes()
          .then((b) => ByteData.sublistView(Uint8List.fromList(b))));
    }
    await roboto.load();
  });

  setUp(() async {
    pasta = await Directory.systemTemp.createTemp('fabrica_popups_');
    Armazenamento.pastaTeste = pasta;
    personagem = Ficha();
    await personagem.init();
    // O cache do rootBundle guarda leituras feitas no relógio falso de um
    // teste anterior, que nunca completam no seguinte
    rootBundle.clear();
  });

  tearDown(() async {
    Armazenamento.pastaTeste = null;
    if (await pasta.exists()) await pasta.delete(recursive: true);
  });

  group('A. Tela de origem continua visível', () {
    final Map<String, Widget Function()> telas = {
      'Pericias': () => const ScreenPericias(),
      'Vantagens': () => const ScreenVantagens(),
      'Complicações': () => const ScreenComplicacoes(),
      'Poderes': () => const ScreenPoderes(),
    };
    telas.forEach((titulo, criar) {
      testWidgets('$titulo: popup de inclusão abre sobre a tela', (tester) async {
        await usarTela(tester, const Size(360, 740));
        await tester.pumpWidget(embrulhar(criar()));
        await assentar(tester);
        expect(tituloDaTela(titulo), findsOneWidget);

        await tester.tap(find.byType(FloatingActionButton));
        await assentar(tester);

        expect(find.byType(Dialog), findsOneWidget);
        // Com a rota opaca, a tela de baixo saía da árvore desenhada
        expect(tituloDaTela(titulo), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('A2. Telas de poder continuam visíveis', () {
    testWidgets('Controle de Pacote: popup de inclusão abre sobre a tela',
        (tester) async {
      await usarTela(tester, const Size(360, 740));
      // Mapa mutável: a tela acrescenta efeitos nele
      final Map pacote = {
        "nome": "Arranjo",
        "efeito": "Efeitos Alternativos",
        "e_id": "P003",
        "tipo": "E",
        "removivel": 0,
        "class": "PacotesEfeitos",
        "efeitos": [],
        "idCriacao": "A-teste",
      };
      await tester.pumpWidget(embrulhar(ControladorDePacotes(objPacote: pacote)));
      await assentar(tester);
      expect(tituloDaTela('Arranjo'), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await assentar(tester);
      expect(find.byType(Dialog), findsOneWidget);
      expect(tituloDaTela('Arranjo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Editor de Poder: popup de modificador abre sobre a tela',
        (tester) async {
      await usarTela(tester, const Size(360, 740));
      await abrirEditor(tester, "E013", "EfeitoDano");
      await tocarNoEditor(tester, find.text('Adicionar Modificador'));
      expect(find.byType(Dialog), findsOneWidget);
      expect(tituloDaTela('Edição do Poder'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('B. Voltar do sistema não altera a ficha', () {
    testWidgets('graduação continua igual', (tester) async {
      await usarTela(tester, const Size(360, 740));
      await abrirEditor(tester, "E013", "EfeitoDano", graduacao: 3);
      expect(poder.retornaObj()["graduacao"], 3);
      await tocarNoEditor(tester, find.text('Dano 3'));
      expect(find.text('Valor de Graduação'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await assentar(tester);
      expect(tester.takeException(), isNull);
      expect(poder.retornaObj()["graduacao"], 3);
    });

    testWidgets('graduação 0 não vira 1 ao voltar', (tester) async {
      await usarTela(tester, const Size(360, 740));
      await abrirEditor(tester, "E013", "EfeitoDano", graduacao: 0);
      await tocarNoEditor(tester, find.text('Dano 0'));
      await tester.binding.handlePopRoute();
      await assentar(tester);
      expect(poder.retornaObj()["graduacao"], 0);
    });

    testWidgets('acerto continua igual', (tester) async {
      await usarTela(tester, const Size(360, 740));
      await abrirEditor(tester, "E013", "EfeitoDano");
      final Object? antes = poder.retornaObj()["acerto"];
      await tocarNoEditor(tester, find.textContaining('Acerto '));
      expect(find.text('Valor de Acerto'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await assentar(tester);
      expect(tester.takeException(), isNull);
      expect(poder.retornaObj()["acerto"], antes);
    });

    testWidgets('complicação editada continua igual', (tester) async {
      await usarTela(tester, const Size(360, 740));
      personagem.complicacoes.add({"titulo": "Motivação", "desc": "Justiça"});
      await tester.pumpWidget(embrulhar(const ScreenComplicacoes()));
      await assentar(tester);

      await tester.tap(find.text('Motivação'));
      await assentar(tester);
      expect(find.text('Cancelar'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await assentar(tester);

      expect(tester.takeException(), isNull);
      expect(personagem.complicacoes.single,
          {"titulo": "Motivação", "desc": "Justiça"});
    });

    testWidgets('Cancelar na complicação nova não grava nada', (tester) async {
      await usarTela(tester, const Size(360, 740));
      await tester.pumpWidget(embrulhar(const ScreenComplicacoes()));
      await assentar(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await assentar(tester);
      await tester.tap(find.text('Cancelar'));
      await assentar(tester);

      expect(tester.takeException(), isNull);
      expect(personagem.complicacoes, isEmpty);
    });
  });

  group('C. Centralização e tamanho', () {
    test('restricoesPopup: 320→288, 360→328, 1280→560, altura 85%', () {
      expect(restricoesPopup(const Size(320, 568)).maxWidth, 288);
      expect(restricoesPopup(const Size(360, 740)).maxWidth, 328);
      expect(restricoesPopup(const Size(1280, 800)).maxWidth, 560);
      expect(restricoesPopup(const Size(1280, 800)).minWidth, 560);
      expect(restricoesPopup(const Size(1280, 800)).maxHeight, 680);
    });

    for (final Size tela in const [
      Size(320, 568),
      Size(360, 740),
      Size(1280, 800)
    ]) {
      testWidgets(
          'abrirPopup centraliza em ${tela.width.toInt()}x${tela.height.toInt()}',
          (tester) async {
        await usarTela(tester, tela);
        await abrirComoPopup(tester, popupSimples());

        final Rect caixa = tester.getRect(caixaDoDialogo());
        expect(caixa.center.dx, closeTo(tela.width / 2, 1));
        expect(caixa.center.dy, closeTo(tela.height / 2, 1));
        expect(caixa.width, restricoesPopup(tela).maxWidth);
        expect(caixa.height, lessThanOrEqualTo(tela.height * 0.85));
      });
    }

    testWidgets('altura fica em 85% com conteúdo longo', (tester) async {
      await usarTela(tester, const Size(360, 740));
      await abrirComoPopup(tester,
          PopUpAddComplicacao(title: "", desc: List.filled(80, 'linha').join('\n')));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(caixaDoDialogo()).height,
          lessThanOrEqualTo(740 * 0.85));
    });

    testWidgets('abrirPopup não fecha ao tocar fora', (tester) async {
      await usarTela(tester, const Size(360, 740));
      await abrirComoPopup(tester, popupSimples());
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('abrirPopup devolve null no voltar do sistema', (tester) async {
      await usarTela(tester, const Size(360, 740));
      Object? retorno = 'nada';
      await abrirComoPopup(tester, popupSimples(), aoFechar: (r) => retorno = r);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(retorno, isNull);
    });

    testWidgets('abrirPopup sobe com o teclado sem estouro', (tester) async {
      await usarTela(tester, const Size(360, 740));
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await abrirComoPopup(tester, PopUpAddComplicacao(title: "", desc: ""));
      expect(tester.takeException(), isNull);
      expect(tester.getRect(caixaDoDialogo()).bottom,
          lessThanOrEqualTo(740 - 300));
    });
  });

  group('D. Busca no seletor', () {
    test('normalizarBusca remove acentos e caixa', () {
      expect(normalizarBusca('Ação'), 'acao');
      expect(normalizarBusca('ATAQUE À DISTÂNCIA'), 'ataque a distancia');
    });

    test('filtrarOpcoes por trecho, sem acento', () {
      const opcoes = [
        OpcaoDropdown(valor: 1, rotulo: 'Comunicação'),
        OpcaoDropdown(valor: 2, rotulo: 'Aflição'),
        OpcaoDropdown(valor: 3, rotulo: 'Natação'),
      ];
      expect(filtrarOpcoes(opcoes, 'acao').map((o) => o.valor), [1, 3]);
      expect(filtrarOpcoes(opcoes, '').length, 3);
    });

    Widget seletor(List<OpcaoDropdown<int>> opcoes, ValueChanged<int> aoMudar) =>
        embrulhar(Scaffold(
          body: DropdownComBusca<int>(
              opcoes: opcoes, valor: null, aoMudar: aoMudar),
        ));

    const sintetica = [
      OpcaoDropdown(valor: 1, rotulo: 'Alfa', grupo: 'Grupo A'),
      OpcaoDropdown(valor: 2, rotulo: 'Beta', grupo: 'Grupo B'),
      OpcaoDropdown(valor: 3, rotulo: 'Gama', grupo: 'Grupo B', habilitado: false),
    ];

    testWidgets('grupos sem resultado somem e cabeçalhos ficam', (tester) async {
      await usarTela(tester, const Size(360, 740));
      await tester.pumpWidget(seletor(sintetica, (_) {}));
      await tester.tap(find.byType(DropdownComBusca<int>));
      await tester.pumpAndSettle();
      expect(find.text('Grupo A'), findsOneWidget);
      expect(find.text('Grupo B'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'bet');
      await tester.pumpAndSettle();
      expect(find.text('Grupo A'), findsNothing);
      expect(find.text('Grupo B'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets("'Nenhum resultado'", (tester) async {
      await usarTela(tester, const Size(360, 740));
      await tester.pumpWidget(seletor(sintetica, (_) {}));
      await tester.tap(find.byType(DropdownComBusca<int>));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('Nenhum resultado'), findsOneWidget);
    });

    testWidgets('item desabilitado não seleciona', (tester) async {
      await usarTela(tester, const Size(360, 740));
      int? escolhido;
      await tester.pumpWidget(seletor(sintetica, (v) => escolhido = v));
      await tester.tap(find.byType(DropdownComBusca<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gama'));
      await tester.pumpAndSettle();
      expect(escolhido, isNull);

      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      expect(escolhido, 2);
    });

    testWidgets('busca com foco ao abrir', (tester) async {
      await usarTela(tester, const Size(360, 740));
      await tester.pumpWidget(seletor(sintetica, (_) {}));
      await tester.tap(find.byType(DropdownComBusca<int>));
      await tester.pumpAndSettle();
      final EditableText campo = tester.widget(find.byType(EditableText));
      expect(campo.focusNode.hasFocus, isTrue);
    });

    testWidgets('rótulo longo não estoura em 320x568', (tester) async {
      await usarTela(tester, const Size(320, 568));
      const longa = OpcaoDropdown(
          valor: 1,
          rotulo: 'Uma opção com um nome muito comprido para quebrar a linha do campo');
      await tester.pumpWidget(embrulhar(Scaffold(
        body: DropdownComBusca<int>(opcoes: const [longa], valor: 1, aoMudar: (_) {}),
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets("efeitos: 'acao' filtra sem acento e devolve o efeito escolhido",
        (tester) async {
      await usarTela(tester, const Size(360, 740));
      Object? retorno;
      await abrirComoPopup(tester, DynamicDialog(tipo: "", descNome: true),
          aoFechar: (r) => retorno = r);
      // O catálogo de efeitos é lido do disco depois de abrir
      for (int i = 0; i < 40; i++) {
        if (tester
            .widget<DropdownComBusca<String>>(find.byType(DropdownComBusca<String>))
            .opcoes
            .isNotEmpty) {
          break;
        }
        await assentar(tester);
      }

      await tester.tap(find.byType(DropdownComBusca<String>));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'acao');
      await tester.pumpAndSettle();
      final Finder lista = find.byType(ListTile);
      final List<String> nomes = tester
          .widgetList<ListTile>(lista)
          .map((t) => (t.title as Text).data!)
          .toList();
      expect(nomes, ['Comunicação', 'Escavação', 'Natação', 'Regeneração']);
      expect(nomes, isNot(contains('Aflição')));

      await tester.tap(find.text('Natação'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar'));
      await assentar(tester);
      expect((retorno as Map)["efeito"], 'Natação');
    });
  });

  group('D2. Busca nos popups do editor e de perícia', () {
    testWidgets("modificadores: grupos e filtro 'dissip'", (tester) async {
      await usarTela(tester, const Size(360, 740));
      await abrirEditor(tester, "E013", "EfeitoDano");
      await tocarNoEditor(tester, find.text('Adicionar Modificador'));
      await esperarOpcoes<Map>(tester);

      await tester.tap(find.byType(DropdownComBusca<Map>));
      await tester.pumpAndSettle();
      // Falhas fica abaixo, fora da tela (lista preguiçosa): conferida no filtro
      for (final String grupo in ['Próprios do efeito', 'Extras']) {
        expect(find.text(grupo), findsOneWidget);
      }
      // Os próprios do Dano vêm primeiro, antes do primeiro extra
      final List<String> linhas = tester
          .widgetList<Text>(find.descendant(
              of: find.byType(ListView), matching: find.byType(Text)))
          .map((t) => t.data!)
          .toList();
      expect(linhas.take(3), ['Próprios do efeito', 'Incurável', 'Sonífero']);

      await tester.enterText(find.byType(TextField).last, 'dissip');
      await tester.pumpAndSettle();
      expect(find.text('Próprios do efeito'), findsNothing);
      expect(find.text('Extras'), findsNothing);
      expect(find.text('Falhas'), findsOneWidget);
      await tester.tap(find.descendant(
          of: find.byType(ListTile), matching: find.text('Dissipação')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Adicionar').last);
      await assentar(tester);
      expect((poder.retornaObj()["modificadores"] as List)
          .map((m) => m["nome"]), contains('Dissipação'));
    });

    testWidgets('perícia: escolha pela busca devolve a perícia', (tester) async {
      await usarTela(tester, const Size(360, 740));
      Object? retorno;
      await abrirComoPopup(tester, PopUpAddSkill(obj: const {}),
          aoFechar: (r) => retorno = r);
      await escolherPelaBusca<Map>(tester, 'presen', 'Especialidade de Presença');
      await tester.tap(find.text('Adicionar'));
      await assentar(tester);
      expect((retorno as Map)["id"], 'PA05');
    });

    testWidgets('característica: escolha pela busca vira bônus do poder',
        (tester) async {
      await usarTela(tester, const Size(360, 740));
      await abrirEditor(tester, "PB01", "EfeitoBonus");
      await tocarNoEditor(
          tester, find.text('Adicionar Compra de Habilidade Aumentada'));
      await esperarOpcoes<Map>(tester);
      final String alvo = tester
          .widget<DropdownComBusca<Map>>(find.byType(DropdownComBusca<Map>))
          .opcoes
          .last
          .rotulo;
      await escolherPelaBusca<Map>(tester, alvo.substring(0, 3), alvo);
      await tester.tap(find.text('Adicionar').last);
      await assentar(tester);
      expect(tester.takeException(), isNull);
      expect((poder as EfeitoBonus).returnBonusList().map((b) => b["nome"]),
          contains(alvo));
    });

    testWidgets('opção de compra: escolha pela busca é comprada',
        (tester) async {
      await usarTela(tester, const Size(360, 740));
      await abrirEditor(tester, "E035", "EfeitoCompra");
      await tocarNoEditor(tester, find.text('Adicionar Compra de Sentidos'));
      await esperarOpcoes<String>(tester);
      final OpcaoDropdown<String> alvo = tester
          .widget<DropdownComBusca<String>>(find.byType(DropdownComBusca<String>))
          .opcoes
          .last;
      await escolherPelaBusca<String>(
          tester, alvo.rotulo.substring(0, 4), alvo.rotulo);
      await tester.tap(find.text('Adicionar').last);
      await assentar(tester);
      expect(tester.takeException(), isNull);
      expect((poder.retornaObj()["opt"] as List).map((o) => o["ID"].toString()),
          contains(alvo.valor));
    });
  });

  group('E. Vantagem como diálogo', () {
    testWidgets("vantagens: 'ataq' acha Ataque Acurado e a tela continua",
        (tester) async {
      await usarTela(tester, const Size(360, 740));
      await tester.pumpWidget(embrulhar(const ScreenVantagens()));
      await assentar(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await assentar(tester);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.descendant(
          of: find.byType(AlertDialog), matching: find.byType(AppBar)),
          findsNothing);
      // A tela de Vantagens (AppBar) continua desenhada atrás do popup
      expect(tituloDaTela('Vantagens'), findsOneWidget);

      await tester.tap(find.byType(DropdownComBusca<Map>));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'ataq');
      await tester.pumpAndSettle();
      expect(find.text('ATAQUE ACURADO'), findsOneWidget);
    });

    testWidgets('vantagens: editar mantém a graduação', (tester) async {
      await usarTela(tester, const Size(360, 740));
      personagem.vantagens.listaVantagens.add({
        "id": "V999",
        "nome": "Teste graduado",
        "desc": false,
        "graduado": true,
        "limite": 0,
        "graduacao": 3,
        "txtDec": "",
      });
      await tester.pumpWidget(embrulhar(const ScreenVantagens()));
      await assentar(tester);
      await tester.tap(find.textContaining('Teste graduado'));
      await assentar(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      final TextField campo = tester.widget(find.descendant(
          of: find.byType(AlertDialog), matching: find.byType(TextField)));
      expect(campo.controller!.text, '3');
    });
  });
}
