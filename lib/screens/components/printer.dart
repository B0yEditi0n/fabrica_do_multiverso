// Arquivo de Ficha
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/pericias/lib_pericias.dart';
import 'package:fabrica_do_multiverso/script/vantagens/lib_vantagens.dart';
import 'package:fabrica_do_multiverso/script/habilidades/lib_habilidades.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:flutter/material.dart';

// Criação de PDFs
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

// Importação da Lógica de processamento dos Widgets
import 'package:fabrica_do_multiverso/script/printer/poderes.dart';

import 'dart:developer' as dev;

class Printer {
  //
  // Configurações de Fontes & Texto
  //
  static pw.Font robotFont = pw.Font();
  static pw.Font headerFont = pw.Font();
  static pw.TextStyle headerTxtStyle = const pw.TextStyle();

  // Largura de conteúdo útil da página (A4 portrait - margens de 25 em cada lado)
  static final double contentWidth = PdfPageFormat.a4.width - (25 * 2);

  //
  // Widgets base de Tabela
  //
  static pw.Widget headerRowTable(String txt) => pw.Container(
        decoration: const pw.BoxDecoration(color: PdfColor(0, 0, 0)),
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Text(
          txt,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: const PdfColor(1, 1, 1),
          ),
        ),
      );

  static pw.Text cellRowTable(String txt) => pw.Text(
        txt,
        textAlign: pw.TextAlign.center,
      );

  // Cabeçalho de seção estilo "Separador" do modelo (fundo preto, texto branco)
  static pw.Widget sectionHeader(String txt) => pw.Container(
        width: contentWidth,
        margin: const pw.EdgeInsets.only(top: 8, bottom: 5),
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: pw.BoxDecoration(
          color: const PdfColor(0.07, 0.07, 0.07),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Text(
          txt.toUpperCase(),
          style: pw.TextStyle(
            font: headerFont,
            fontSize: 14,
            color: PdfColors.white,
          ),
        ),
      );

  static const int sizedWidgetColumn = 560;

  //
  // Widgets que compõe o PDF
  //

  static pw.Widget infoHeader() => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            personagem.nomePersonagem.isNotEmpty
                ? personagem.nomePersonagem
                : 'Personagem Sem Nome',
            style: pw.TextStyle(
              font: headerFont,
              fontSize: 22,
              decoration: pw.TextDecoration.underline,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Container(
            margin: const pw.EdgeInsets.all(1),
            padding: const pw.EdgeInsets.all(3),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
            ),
            child: pw.Text(
                "NP ${personagem.np} (${personagem.np * 15} pontos)"),
          ),
        ],
      );

  static String totalHabilidades(mapHabi) {
    String retValue = mapHabi["valor"].toString();

    if ((mapHabi["bonus"] as List).isNotEmpty) {
      retValue += " / ${Habilidade().reInit(mapHabi).valorTotal()}";
    }
    return retValue;
  }

  static pw.Widget habilidades() => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          sectionHeader('Habilidades'),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: const {
              0: pw.FixedColumnWidth(70),
              1: pw.FixedColumnWidth(70),
              2: pw.FixedColumnWidth(70),
              3: pw.FixedColumnWidth(70),
            },
            children: [
              pw.TableRow(children: [
                headerRowTable('Força'),
                headerRowTable('Agilidade'),
                headerRowTable('Luta'),
                headerRowTable('Prontidão'),
              ]),
              pw.TableRow(children: [
                cellRowTable(
                    totalHabilidades(personagem.habilidades.getItem("FOR"))),
                cellRowTable(
                    totalHabilidades(personagem.habilidades.getItem("AGI"))),
                cellRowTable(
                    totalHabilidades(personagem.habilidades.getItem("LUT"))),
                cellRowTable(
                    totalHabilidades(personagem.habilidades.getItem("PRO"))),
              ]),
              pw.TableRow(children: [
                headerRowTable('Vigor'),
                headerRowTable('Destreza'),
                headerRowTable('Intelecto'),
                headerRowTable('Presença'),
              ]),
              pw.TableRow(children: [
                cellRowTable(
                    totalHabilidades(personagem.habilidades.getItem("VIG"))),
                cellRowTable(
                    totalHabilidades(personagem.habilidades.getItem("DES"))),
                cellRowTable(
                    totalHabilidades(personagem.habilidades.getItem("INT"))),
                cellRowTable(
                    totalHabilidades(personagem.habilidades.getItem("PRE"))),
              ]),
            ],
          ),
        ],
      );

  static pw.Widget defesas() => pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          sectionHeader('Defesas'),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: const {
              0: pw.FixedColumnWidth(96),
              1: pw.FixedColumnWidth(96),
              2: pw.FixedColumnWidth(96),
              3: pw.FixedColumnWidth(96),
              4: pw.FixedColumnWidth(96),
            },
            children: [
              pw.TableRow(children: [
                headerRowTable('Aparar'),
                headerRowTable('Esquiva'),
                headerRowTable('Fortitude'),
                headerRowTable('Resistência'),
                headerRowTable('Vontade'),
              ]),
              pw.TableRow(children: [
                cellRowTable(personagem.defesas.returnForPrint('D002')),
                cellRowTable(personagem.defesas.returnForPrint('D001')),
                cellRowTable(personagem.defesas.returnForPrint('D003')),
                cellRowTable(personagem.defesas.returnForPrint('D004')),
                cellRowTable(personagem.defesas.returnForPrint('D005')),
              ]),
            ],
          ),
        ],
      );

  //
  // Ofensiva - resumo de ataque de cada efeito ofensivo/dano/aflição
  // (mesma regra de bônus usada em ValidaNpPersonagem._efeitos())
  //
  static Future<pw.Widget> ofensiva() async {
    List<pw.TableRow> linhas = [];

    // Bônus de Habilidades
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

    // Efeitos Ofensivos: junta os de Perto (+ Desarmado) e a Distância (+ Arremesso)
    List poderes = [];
    poderes.addAll(personagem.pericias.returnOfensiveEfeitos(1));
    poderes.addAll(personagem.pericias.returnOfensiveEfeitos(2));

    for (Map p in poderes) {
      linhas.add(await _linhaOfensiva(
          p, luta, destreza, forca, vantagemCorpoACorpo, vantagemADistancia));
    }

    if (linhas.isEmpty) {
      linhas.add(pw.TableRow(children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text('Nenhum efeito ofensivo cadastrado.'),
        ),
      ]));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        sectionHeader('Ofensiva'),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(4),
          },
          children: [
            pw.TableRow(children: [
              headerRowTable('Ataque'),
              headerRowTable('Alcance'),
              headerRowTable('Acerto'),
              headerRowTable('Efeito / CD'),
            ]),
            ...linhas,
          ],
        ),
      ],
    );
  }

  static Future<pw.TableRow> _linhaOfensiva(Map p, int luta, int destreza,
      int forca, int vantagemCorpoACorpo, int vantagemADistancia) async {
    pw.Widget padded(pw.Widget child) =>
        pw.Padding(padding: const pw.EdgeInsets.all(3), child: child);

    // Ataques "genéricos" que não vem de um poder cadastrado (Desarmado / Arremesso)
    if (p["noPower"] == true) {
      bool ePerto = p["idCriacao"] == "F1";
      int bonusAcerto = ePerto
          ? luta + vantagemCorpoACorpo
          : destreza + vantagemADistancia;

      return pw.TableRow(children: [
        padded(cellRowTable(p["nome"])),
        padded(cellRowTable(ePerto ? 'Perto' : 'À Distância')),
        padded(cellRowTable('+$bonusAcerto')),
        padded(cellRowTable('Dano $forca (CD ${forca + 15})')),
      ]);
    }

    // Instancia o efeito real de acordo com a classe salva no Map
    Efeito objectEfeito = await Efeito.init(p);
    Map objEfeitoJson = objectEfeito.retornaObj();

    int alcance = p["alcance"] ?? objEfeitoJson["alcance"];
    int bonusVantagem = alcance == 1
        ? luta + vantagemCorpoACorpo
        : alcance == 2
            ? destreza + vantagemADistancia
            : 0;

    int totalAcerto = bonusVantagem;
    if (objectEfeito is EfeitoOfensivo) {
      totalAcerto += objectEfeito.totalBonusAcerto();
    }

    String nome = objectEfeito.nome.isNotEmpty
        ? objectEfeito.nome
        : objEfeitoJson["efeito"];

    String strAlcance = objectEfeito.returnStrAlcance();
    String strAcerto = alcance == 3 ? 'Automático' : '+$totalAcerto';

    // Descrição do efeito: nome do efeito + graduação + CD + condições + crítico
    StringBuffer descEfeito = StringBuffer();
    descEfeito.write('${objEfeitoJson["efeito"]} ${objEfeitoJson["graduacao"]}');

    if (objEfeitoJson["cd"] != null) {
      descEfeito.write(' (CD ${objEfeitoJson["cd"]})');
    }

    if (objEfeitoJson["class"] == "EfeitoAflicao" &&
        objEfeitoJson["condicoes"] != null) {
      List condicoes = (objEfeitoJson["condicoes"] as List)
          .where((c) => c != null && c.toString().isNotEmpty)
          .toList();
      if (condicoes.isNotEmpty) {
        descEfeito.write(' [${condicoes.join(', ')}]');
      }
    }

    if (objEfeitoJson["critico"] != null && objEfeitoJson["critico"] > 0) {
      descEfeito.write(' - Crítico ${20 - (objEfeitoJson["critico"] as int)}');
    }

    return pw.TableRow(children: [
      padded(cellRowTable(nome)),
      padded(cellRowTable(strAlcance)),
      padded(cellRowTable(strAcerto)),
      padded(cellRowTable(descEfeito.toString())),
    ]);
  }

  //
  // Painel de Condições (referência para preenchimento manual durante o jogo)
  //
  static pw.Widget condicoes() {
    const List<String> primeiroGrau = [
      'Tonto',
      'Em Transe',
      'Fadigado',
      'Impedido',
      'Prejudicado',
      'Vulnerável',
    ];
    const List<String> segundoGrau = [
      'Compelido',
      'Indefeso',
      'Desabilitado',
      'Exausto',
      'Imóvel',
      'Caído',
      'Atordoado',
    ];
    const List<String> terceiroGrau = [
      'Adormecido',
      'Controlado',
      'Incapacitado',
      'Paralisado',
      'Transformado',
      'Desatento',
    ];

    pw.Widget checkItem(String txt) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(
                width: 7,
                height: 7,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.75),
                ),
              ),
              pw.SizedBox(width: 3),
              pw.Text(txt, style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
        );

    pw.Widget coluna(List<String> lista) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: lista.map(checkItem).toList(),
        );

    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.75),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Condições',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              coluna(primeiroGrau),
              pw.SizedBox(width: 10),
              coluna(segundoGrau),
              pw.SizedBox(width: 10),
              coluna(terceiroGrau),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(children: [
            pw.Text('Ferimentos: ',
                style: pw.TextStyle(
                    fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.Container(
              width: 90,
              height: 12,
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
            ),
          ]),
        ],
      ),
    );
  }

  static pw.Widget vantagens() {
    List<pw.TableRow> tablesRows = [];
    List<pw.Widget> contentRows;

    // Ordena Vantagens por Ordem Alfábetica
    personagem.vantagens.listaVantagens
        .sort((a, b) => a["nome"].compareTo(b["nome"]));

    pw.Widget descVantagem(mapVantagem) {
      Vantagem objVantagem = Vantagem().init(mapVantagem);
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Text(
          "${objVantagem.nome} ${objVantagem.graduado ? "[${objVantagem.grad() != objVantagem.returnTotalGrad() ? "*" : ''}${objVantagem.returnTotalGrad()}]" : ''}",
        ),
      );
    }

    int nMax = personagem.vantagens.listaVantagens.length;

    for (int i = 0; i < nMax / 2; i++) {
      contentRows = [];

      Map leftVantagem = personagem.vantagens.listaVantagens[i];
      contentRows.add(descVantagem(leftVantagem));

      if ((nMax / 2).ceil() + i < nMax) {
        Map rightVantagem =
            personagem.vantagens.listaVantagens[(nMax / 2).ceil() + i];
        contentRows.add(descVantagem(rightVantagem));
      } else {
        contentRows.add(pw.SizedBox());
      }
      tablesRows.add(pw.TableRow(children: contentRows));
    }

    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.max,
      children: [
        sectionHeader('Vantagens'),
        nMax > 0
            ? pw.Table(
                columnWidths: const {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(1),
                },
                children: tablesRows,
              )
            : pw.Text('Nenhuma vantagem cadastrada.'),
      ],
    );
  }

  static pw.Widget pericias() {
    List<pw.TableRow> tablesRows = [];
    List<pw.Widget> contentRows;

    int nMax = personagem.pericias.ListaPercias.length;

    pw.Widget descPericia(Map mapPericia) {
      Pericia objPericia = Pericia();
      objPericia.init(mapPericia);

      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Text(
          "${objPericia.nome}(${objPericia.onlyGrad()}) +${objPericia.bonusTotal()}",
        ),
      );
    }

    for (int i = 0; i < nMax / 2; i++) {
      contentRows = [];

      Map mapPericiaEsquerda = personagem.pericias.ListaPercias[i];
      contentRows.add(descPericia(mapPericiaEsquerda));

      if ((nMax / 2).ceil() + i < nMax) {
        Map mapPericiaDireita =
            personagem.pericias.ListaPercias[(nMax / 2).ceil() + i];
        contentRows.add(descPericia(mapPericiaDireita));
      } else {
        contentRows.add(pw.SizedBox());
      }

      tablesRows.add(pw.TableRow(children: contentRows));
    }

    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        sectionHeader('Perícias'),
        nMax > 0
            ? pw.Table(
                columnWidths: const {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(1),
                },
                children: tablesRows,
              )
            : pw.Text('Nenhuma perícia cadastrada.'),
      ],
    );
  }

  static Future<pw.Widget> poderes() async {
    List<pw.Widget> content = [];

    content.add(sectionHeader('Poderes'));

    if (personagem.poderes.poderesLista.isEmpty) {
      content.add(pw.Text('Nenhum poder cadastrado.'));
    } else {
      content.addAll(
          await WidPdgPoderes.classificador(personagem.poderes.poderesLista));
    }

    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: content,
    );
  }

  static pw.Widget complicacoes() {
    List<pw.Widget> containerRows = [];

    for (int i = 0; i < personagem.complicacoes.length; i++) {
      containerRows.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 5),
          child: pw.RichText(
            overflow: pw.TextOverflow.clip,
            text: pw.TextSpan(text: "", children: [
              pw.TextSpan(
                text: "${personagem.complicacoes[i]["titulo"]}: ",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(text: personagem.complicacoes[i]["desc"]),
            ]),
          ),
        ),
      );
    }

    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        sectionHeader('Complicações'),
        personagem.complicacoes.isEmpty
            ? pw.Text('Nenhuma complicação cadastrada.')
            : pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: const PdfColor(0, 0, 0),
                    style: pw.BorderStyle.solid,
                    width: 1,
                  ),
                ),
                width: contentWidth,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisSize: pw.MainAxisSize.max,
                  children: containerRows,
                ),
              ),
      ],
    );
  }

  //
  // Montagem final do PDF
  //
  static void generatePDF(Uint8List fileImg) async {
    pw.Document doc = pw.Document();

    // Carrega as Fontes
    headerFont = pw.Font.ttf(await rootBundle.load('fonts/Impact.ttf'));
    robotFont = await PdfGoogleFonts.robotoLight();
    headerTxtStyle = pw.TextStyle(font: headerFont, fontSize: 20);

    // Pré-processa os widgets assíncronos antes de montar o documento
    pw.Widget pdfOfensiva = await ofensiva();
    pw.Widget pdfPoderes = await poderes();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.portrait,
        margin: const pw.EdgeInsets.all(25),
        header: (pw.Context context) {
          // Repete o nome do personagem discretamente a partir da 2ª página
          if (context.pageNumber == 1) return pw.SizedBox();
          return pw.Container(
            alignment: pw.Alignment.centerLeft,
            margin: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Text(
              personagem.nomePersonagem,
              style: pw.TextStyle(font: headerFont, fontSize: 10, color: PdfColors.grey700),
            ),
          );
        },
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 6),
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
        build: (pw.Context context) => [
          // Cabeçalho: Nome, NP, Habilidades <-> Imagem
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    infoHeader(),
                    pw.SizedBox(height: 4),
                    habilidades(),
                  ],
                ),
              ),
              fileImg.isNotEmpty
                  ? pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 10),
                      child: pw.Container(
                        width: 130,
                        height: 165,
                        padding: const pw.EdgeInsets.all(3),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 2),
                        ),
                        child: pw.Image(
                          pw.MemoryImage(fileImg),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    )
                  : pw.SizedBox(),
            ],
          ),

          defesas(),

          // Ofensiva + Painel de Condições lado a lado
          pw.SizedBox(height: 4),
          pdfOfensiva,
          pw.SizedBox(height: 6),
          condicoes(),

          pw.SizedBox(height: 4),
          pdfPoderes,

          pw.SizedBox(height: 4),
          vantagens(),

          pw.SizedBox(height: 4),
          pericias(),

          pw.SizedBox(height: 4),
          complicacoes(),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => await doc.save());
  }
}