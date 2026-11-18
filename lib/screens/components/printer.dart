// Geração do PDF da ficha.
//
// O desenho segue o modelo de ficha em
//   Desenvolvimento/Repositório de Regras/Alquimista.docx e Prodigio.docx:
//   nome e imagem, "NP X (gastos / disponíveis pontos)", e as seções
//   Habilidades, Defesas, Ofensiva, Vantagens, Poderes, Perícias,
//   Complicações & Notas, Equipamentos e a linha final de totais.
//   A ficha é preta: fundo preto e texto branco em todas as páginas.
//   Seções têm barra azul (#2a6099) com título em destaque; as tabelas de
//   Habilidades e Defesas têm moldura com cantos arredondados, cabeçalho
//   azul e células escuras; a letra é Arial (aqui Helvetica).
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/pericias/lib_pericias.dart';
import 'package:fabrica_do_multiverso/script/vantagens/lib_vantagens.dart';
import 'package:fabrica_do_multiverso/script/habilidades/lib_habilidades.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_custos.dart';

// Criação de PDFs
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'dart:typed_data';

// Importação da Lógica de processamento dos Widgets
import 'package:fabrica_do_multiverso/script/printer/poderes.dart';

class Printer {
  //
  // Medidas e cores do modelo
  //
  static const double margem = 56.7; // 2 cm
  static final double contentWidth = PdfPageFormat.a4.width - (margem * 2);
  // Ficha preta
  static const PdfColor corFundo = PdfColors.black;
  static const PdfColor corTexto = PdfColors.white;
  static const PdfColor corTextoSecundario = PdfColors.grey400;
  static const PdfColor corSecao = PdfColor.fromInt(0xff2a6099);
  static const PdfColor corCabecalho = PdfColor.fromInt(0xff1d4570);
  static const PdfColor corCelula = PdfColor.fromInt(0xff1a1a1a);
  // Moldura das tabelas (Habilidades e Defesas)
  static const PdfColor corMoldura = PdfColor.fromInt(0xff5b8fc7);
  static const PdfColor corDivisoria = PdfColor.fromInt(0xff3d3d3d);
  static const double raioMoldura = 6;
  static const double tamanhoTexto = 11;
  static const double tamanhoTitulo = 14; // barras de seção
  static const double tamanhoNome = 26; // nome do personagem

  static pw.TextStyle get negrito =>
      pw.TextStyle(fontWeight: pw.FontWeight.bold);

  //
  // Textos da ficha (funções puras, cobertas por teste)
  //

  static String comSinal(int valor) => valor >= 0 ? '+$valor' : '$valor';

  /// "ATAQUE À DISTÂNCIA" -> "Ataque à Distância"
  static String nomeProprio(String texto) {
    const List<String> minusculas = [
      'de', 'do', 'da', 'dos', 'das', 'a', 'à', 'em', 'no', 'na', 'com', 'e'
    ];
    String palavra(String p, bool primeira) {
      if (p.isEmpty) return p;
      String baixa = p.toLowerCase();
      if (!primeira && minusculas.contains(baixa)) return baixa;
      return baixa[0].toUpperCase() + baixa.substring(1);
    }

    List<String> palavras = texto.trim().split(' ');
    List<String> saida = [];
    for (int i = 0; i < palavras.length; i++) {
      // Mantém a maiúscula depois do hífen: "Corpo-a-Corpo", "Esconder-se"
      List<String> partes = palavras[i].split('-');
      saida.add([
        for (int j = 0; j < partes.length; j++)
          palavra(partes[j], i == 0 && j == 0)
      ].join('-'));
    }
    return saida.join(' ');
  }

  /// "NP 11 (162 / 165 pontos)"
  static String linhaNp() {
    Map<String, int> r = personagem.resumoPontos();
    return 'NP ${personagem.np} (${r["total"]} / ${r["disponivel"]} pontos)';
  }

  /// "Habilidades 62 + Defesas 27 + Vantagens 9 + Poderes 36 + Perícias 28 : 162 pontos"
  static String linhaTotais() {
    Map<String, int> r = personagem.resumoPontos();
    return 'Habilidades ${r["habilidades"]} + Defesas ${r["defesas"]} + '
        'Vantagens ${r["vantagens"]} + Poderes ${r["poderes"]} + '
        'Perícias ${r["pericias"]} : ${r["total"]} pontos';
  }

  /// "Ataque Preciso (Camuflagem, a Distância) [2]"
  /// O asterisco marca graduação que inclui bônus de poder.
  static String textoVantagem(Map mapVantagem) {
    Vantagem v = Vantagem().init(mapVantagem);
    String texto = nomeProprio(v.nome);
    if (v.txtDec.trim().isNotEmpty) {
      texto += ' (${v.txtDec.trim()})';
    }
    if (v.graduado) {
      texto += ' [${v.grad() != v.returnTotalGrad() ? '*' : ''}${v.returnTotalGrad()}]';
    }
    return texto;
  }

  /// "Furtividade [8] +10"
  static String textoPericia(Map mapPericia) {
    Pericia p = Pericia();
    p.init(mapPericia);
    return '${p.nome} [${p.onlyGrad()}] ${comSinal(p.bonusTotal())}';
  }

  /// Perícias que entram na ficha impressa: as que têm graduação
  static List<Map> periciasImpressas() {
    return List<Map>.from(personagem.pericias.ListaPercias.where((p) {
      Pericia obj = Pericia();
      obj.init(p);
      return obj.onlyGrad() > 0;
    }));
  }

  static String totalHabilidades(mapHabi) {
    String retValue = mapHabi["valor"].toString();

    if ((mapHabi["bonus"] as List).isNotEmpty) {
      retValue += " / ${Habilidade().reInit(mapHabi).valorTotal()}";
    }
    return retValue;
  }

  //
  // Widgets base
  //

  // Barra de seção: fundo azul, título branco em destaque, largura total
  static pw.Widget sectionHeader(String txt) => pw.Container(
        width: contentWidth,
        margin: const pw.EdgeInsets.only(top: 10, bottom: 5),
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: const pw.BoxDecoration(
          color: corSecao,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
        ),
        child: pw.Text(
          '$txt:',
          style: pw.TextStyle(
            fontSize: tamanhoTitulo,
            fontWeight: pw.FontWeight.bold,
            color: corTexto,
          ),
        ),
      );

  static pw.Widget headerRowTable(String txt) => pw.Container(
        color: corCabecalho,
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Text(
          txt,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: corTexto,
          ),
        ),
      );

  static pw.Widget cellRowTable(String txt) => pw.Container(
        color: corCelula,
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Text(txt, textAlign: pw.TextAlign.center),
      );

  // Tabela de rótulos e valores (Habilidades e Defesas)
  static pw.Widget tabelaValores(List<List<String>> linhas) {
    List<pw.TableRow> rows = [];
    for (int i = 0; i < linhas.length; i++) {
      rows.add(pw.TableRow(children: [
        for (String txt in linhas[i])
          i.isEven ? headerRowTable(txt) : cellRowTable(txt)
      ]));
    }
    // Moldura decorada: borda contínua com cantos arredondados por fora
    // e divisórias finas entre as células
    return pw.Container(
      foregroundDecoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(raioMoldura)),
        border: pw.Border.all(color: corMoldura, width: 1.5),
      ),
      child: pw.ClipRRect(
        horizontalRadius: raioMoldura,
        verticalRadius: raioMoldura,
        child: pw.Table(
          border: pw.TableBorder.symmetric(
            inside: pw.BorderSide(color: corDivisoria, width: 0.5),
          ),
          children: rows,
        ),
      ),
    );
  }

  // Lista de textos em duas colunas, preenchida de cima para baixo
  static pw.Widget duasColunas(List<String> itens) {
    int metade = (itens.length / 2).ceil();
    pw.Widget coluna(List<String> parte) => pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (String txt in parte)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2, right: 6),
                  child: pw.Text(txt),
                )
            ],
          ),
        );
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        coluna(itens.sublist(0, metade)),
        coluna(itens.sublist(metade)),
      ],
    );
  }

  //
  // Seções
  //

  static pw.Widget infoHeader() => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            personagem.nomePersonagem.isNotEmpty
                ? personagem.nomePersonagem
                : 'Personagem Sem Nome',
            style: pw.TextStyle(
                fontSize: tamanhoNome, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(linhaNp(), style: negrito),
        ],
      );

  static pw.Widget habilidades() => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          sectionHeader('Habilidades'),
          tabelaValores([
            ['Força', 'Agilidade', 'Luta', 'Prontidão'],
            [
              for (String id in ['FOR', 'AGI', 'LUT', 'PRO'])
                totalHabilidades(personagem.habilidades.getItem(id))
            ],
            ['Vigor', 'Destreza', 'Intelecto', 'Presença'],
            [
              for (String id in ['VIG', 'DES', 'INT', 'PRE'])
                totalHabilidades(personagem.habilidades.getItem(id))
            ],
          ]),
        ],
      );

  static pw.Widget defesas() => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          sectionHeader('Defesas'),
          tabelaValores([
            ['Aparar', 'Esquiva', 'Fortitude', 'Resistência', 'Vontade'],
            [
              for (String id in ['D002', 'D001', 'D003', 'D004', 'D005'])
                personagem.defesas.returnForPrint(id)
            ],
          ]),
        ],
      );

  //
  // Ofensiva - iniciativa e uma entrada por ataque:
  //   Nome: Acerto +11 | Dano 11
  //   CD: 26 Resistência
  // (mesma regra de bônus usada em ValidaNpPersonagem._efeitos())
  //
  static Future<pw.Widget> ofensiva() async {
    List<pw.Widget> itens = [];

    Habilidade objectHabilidade = Habilidade();
    objectHabilidade.initObject(personagem.habilidades.getItem("LUT"));
    int luta = objectHabilidade.valorTotal();

    objectHabilidade.initObject(personagem.habilidades.getItem("DES"));
    int destreza = objectHabilidade.valorTotal();

    objectHabilidade.initObject(personagem.habilidades.getItem("FOR"));
    int forca = objectHabilidade.valorTotal();

    // Bônus de Vantagens (Ataque Corpo a Corpo / a Distância)
    List vantagens = personagem.vantagens.listaVantagens;
    Vantagem objectVantagem = Vantagem();

    int vantagemCorpoACorpo = 0;
    if (vantagens.any((e) => e["id"] == "V013")) {
      objectVantagem.init(vantagens.firstWhere((v) => v["id"] == "V013"));
      vantagemCorpoACorpo = objectVantagem.returnTotalGrad();
    }

    int vantagemADistancia = 0;
    if (vantagens.any((e) => e["id"] == "V011")) {
      objectVantagem.init(vantagens.firstWhere((v) => v["id"] == "V011"));
      vantagemADistancia = objectVantagem.returnTotalGrad();
    }

    List poderes = ataquesOfensiva();

    for (int i = 0; i < poderes.length; i++) {
      itens.add(await _blocoAtaque(poderes[i], luta, destreza, forca,
          vantagemCorpoACorpo, vantagemADistancia));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        sectionHeader('Ofensiva'),
        pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(text: 'Iniciativa: ', style: negrito),
            pw.TextSpan(text: comSinal(personagem.iniciativa())),
          ]),
        ),
        pw.SizedBox(height: 4),
        ...itens,
      ],
    );
  }

  /// Ataques listados na Ofensiva: Desarmado (se incluído no menu
  /// Ofensiva) e Arremesso primeiro, como no modelo, depois os poderes.
  static List ataquesOfensiva() {
    // Efeitos Ofensivos: junta os de Perto (+ Desarmado) e a Distância (+ Arremesso)
    List poderes = [];
    poderes.addAll(personagem.pericias.returnOfensiveEfeitos(1));
    poderes.addAll(personagem.pericias.returnOfensiveEfeitos(2));

    List nativos = poderes
        .where((p) => p["noPower"] == true)
        .where((p) => p["idCriacao"] != "F1" || personagem.incluirDesarmado)
        .toList()
      ..sort((a, b) => a["idCriacao"] == "F1" ? -1 : 1);
    List outros = poderes.where((p) => p["noPower"] != true).toList();
    return [...nativos, ...outros];
  }

  static Future<pw.Widget> _blocoAtaque(Map p, int luta, int destreza,
      int forca, int vantagemCorpoACorpo, int vantagemADistancia) async {
    String nome;
    String strAcerto;
    String efeito;
    String cdValor = '';

    // Ataques "genéricos" que não vem de um poder cadastrado (Desarmado / Arremesso)
    if (p["noPower"] == true) {
      bool ePerto = p["idCriacao"] == "F1";
      int bonusAcerto =
          ePerto ? luta + vantagemCorpoACorpo : destreza + vantagemADistancia;

      nome = p["nome"];
      strAcerto = comSinal(bonusAcerto);
      efeito = 'Dano $forca';
      cdValor = '${forca + 15} Resistência';
    } else {
      // Instancia o efeito real de acordo com a classe salva no Map
      Efeito objectEfeito = await Efeito.init(p);
      Map objEfeitoJson = objectEfeito.retornaObj();

      int alcance = p["alcance"] ?? objEfeitoJson["alcance"];
      int totalAcerto = alcance == 1
          ? luta + vantagemCorpoACorpo
          : alcance == 2
              ? destreza + vantagemADistancia
              : 0;
      if (objectEfeito is EfeitoOfensivo) {
        totalAcerto += objectEfeito.totalBonusAcerto();
      }

      nome = objectEfeito.nome.isNotEmpty
          ? objectEfeito.nome
          : "${objEfeitoJson["efeito"]}";
      strAcerto = alcance == 3 ? 'Automático' : comSinal(totalAcerto);
      efeito = '${objEfeitoJson["efeito"]} ${objEfeitoJson["graduacao"]}';

      // A ficha só sabe qual defesa resiste ao Dano (Resistência).
      // Para os demais efeitos o PDF mostra apenas o valor da CD.
      if (objEfeitoJson["cd"] != null) {
        cdValor = '${objEfeitoJson["cd"]}';
        if (objEfeitoJson["class"] == "EfeitoDano") {
          cdValor += ' Resistência';
        }
      }

      if (objEfeitoJson["class"] == "EfeitoAflicao" &&
          objEfeitoJson["condicoes"] != null) {
        List condicoes = (objEfeitoJson["condicoes"] as List)
            .where((c) => c != null && c.toString().isNotEmpty)
            .toList();
        if (condicoes.isNotEmpty) {
          cdValor += ' (${condicoes.join(', ')})';
        }
      }

      if (objEfeitoJson["critico"] != null && objEfeitoJson["critico"] > 0) {
        cdValor +=
            ' Crítico (${20 - (objEfeitoJson["critico"] as int)}-20)';
      }
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(text: '$nome: ', style: negrito),
          pw.TextSpan(text: 'Acerto $strAcerto | $efeito'),
          if (cdValor.isNotEmpty) pw.TextSpan(text: '\nCD: ', style: negrito),
          if (cdValor.isNotEmpty) pw.TextSpan(text: cdValor.trim()),
        ]),
      ),
    );
  }

  static pw.Widget vantagens() {
    // Ordena uma cópia: a ordem da ficha não deve mudar ao gerar o PDF
    final List<Map> vantagensOrdenadas =
        List<Map>.from(personagem.vantagens.listaVantagens)
          ..sort((a, b) => "${a["nome"]}".compareTo("${b["nome"]}"));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        sectionHeader('Vantagens'),
        vantagensOrdenadas.isNotEmpty
            ? duasColunas(vantagensOrdenadas.map(textoVantagem).toList())
            : pw.Text('Nenhuma vantagem cadastrada.'),
      ],
    );
  }

  static pw.Widget pericias() {
    List<Map> lista = periciasImpressas();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        sectionHeader('Perícias'),
        lista.isNotEmpty
            ? duasColunas(lista.map(textoPericia).toList())
            : pw.Text('Nenhuma perícia com graduação.'),
      ],
    );
  }

  static Future<pw.Widget> poderes() async {
    // Equipamentos saem em seção própria, como no modelo
    List lista = personagem.poderes.poderesLista
        .where((p) => !CustoPoderes.eEquipamento(p))
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        sectionHeader('Poderes'),
        if (lista.isEmpty) pw.Text('Nenhum poder cadastrado.'),
        if (lista.isNotEmpty) ...await WidPdgPoderes.classificador(lista),
      ],
    );
  }

  static Future<pw.Widget> equipamentos() async {
    List lista = personagem.poderes.poderesLista
        .where((p) => CustoPoderes.eEquipamento(p))
        .toList();
    if (lista.isEmpty) return pw.SizedBox();

    Map<String, int> r = personagem.resumoPontos();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        sectionHeader('Equipamentos'),
        ...await WidPdgPoderes.classificador(lista),
        pw.Text(
            'Pontos de equipamento: ${r["equipamentoUsado"]} / ${r["equipamentoDisponivel"]}'),
      ],
    );
  }

  static pw.Widget complicacoes() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        sectionHeader('Complicações & Notas'),
        if (personagem.complicacoes.isEmpty)
          pw.Text('Nenhuma complicação cadastrada.'),
        for (Map c in personagem.complicacoes)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.RichText(
              text: pw.TextSpan(children: [
                pw.TextSpan(text: "${c["titulo"]}: ", style: negrito),
                pw.TextSpan(text: "${c["desc"] ?? ''}"),
              ]),
            ),
          ),
      ],
    );
  }

  static List<pw.Widget> _linhas(pw.Widget secao) =>
      secao is pw.Column ? secao.children : [secao];

  //
  // Montagem final do PDF
  //
  static Future<pw.Document> montar(Uint8List fileImg) async {
    pw.Document doc = pw.Document();

    // Pré-processa os widgets assíncronos antes de montar o documento
    pw.Widget pdfOfensiva = await ofensiva();
    pw.Widget pdfPoderes = await poderes();
    pw.Widget pdfEquipamentos = await equipamentos();

    doc.addPage(
      pw.MultiPage(
        // Ficha preta: fundo preto na página inteira e texto branco
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.portrait,
          margin: const pw.EdgeInsets.all(margem),
          theme: pw.ThemeData.base().copyWith(
            defaultTextStyle:
                const pw.TextStyle(fontSize: tamanhoTexto, color: corTexto),
          ),
          buildBackground: (pw.Context context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: corFundo),
          ),
        ),
        header: (pw.Context context) {
          // Repete o nome do personagem discretamente a partir da 2ª página
          if (context.pageNumber == 1) return pw.SizedBox();
          return pw.Container(
            alignment: pw.Alignment.centerLeft,
            margin: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Text(
              personagem.nomePersonagem,
              style: const pw.TextStyle(fontSize: 9, color: corTextoSecundario),
            ),
          );
        },
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 6),
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: corTextoSecundario),
          ),
        ),
        build: (pw.Context context) => [
          // Nome, NP e Habilidades à esquerda; imagem à direita
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    infoHeader(),
                    habilidades(),
                  ],
                ),
              ),
              if (fileImg.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 10),
                  child: pw.SizedBox(
                    width: 130,
                    height: 165,
                    child: pw.Image(
                      pw.MemoryImage(fileImg),
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
          // Cada seção entra linha a linha, para poder quebrar de página
          for (pw.Widget secao in [
            defesas(),
            pdfOfensiva,
            vantagens(),
            pdfPoderes,
            pericias(),
            complicacoes(),
            pdfEquipamentos,
          ])
            ..._linhas(secao),
          pw.SizedBox(height: 10),
          pw.Text(linhaTotais(), style: negrito),
        ],
      ),
    );

    return doc;
  }

  static Future<void> generatePDF(Uint8List fileImg) async {
    pw.Document doc = await montar(fileImg);
    await Printing.layoutPdf(onLayout: (format) async => await doc.save());
  }
}
