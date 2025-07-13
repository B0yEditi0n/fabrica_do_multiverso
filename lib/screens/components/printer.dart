// Arquivo de Ficha
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/pericias/lib_pericias.dart';
import 'package:fabrica_do_multiverso/script/vantagens/lib_vantagens.dart';
import 'package:flutter/material.dart';

// Criação de PDFs
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

// Importação da Lógica de processamento dos Widgets
import 'package:fabrica_do_multiverso/script/defesas/lib_defesas.dart';

import 'dart:developer' as dev;

class Printer{
  //
  //TODO: Configurações de Fontes & Texto
  // 
  static pw.Font headerFont = pw.Font();
  static pw.TextStyle headerTxtStyle = const pw.TextStyle();
  
  // Configuração da Fonte
  static pw.Text headerRowTable (String txt) => pw.Text(
    txt,
    textAlign: pw.TextAlign.center,
    style: pw.TextStyle(
      fontWeight: pw.FontWeight.bold
    )
  );

  static pw.Text cellRowTable (String txt) => pw.Text(
    txt,
    textAlign: pw.TextAlign.center,
  );

  // TODO: Wigets para compor o PDF

  static pw.Widget infoHeader() => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        personagem.nomePersonagem, 
        style: headerTxtStyle,
      ),

      pw.SizedBox(height: 5),

      pw.Container(
        margin: const pw.EdgeInsets.all(1),
        padding: const pw.EdgeInsets.all(3),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(),
        ),
        child: pw.Text("${personagem.np} (${personagem.np * 15})")
        
      )
      
    ]
  );

  static pw.Widget habilidades() => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [  
      pw.Text('Habilidades', style: headerTxtStyle),
      pw.SizedBox(height: 10),
      pw.Table(
        border: pw.TableBorder.all(),

        columnWidths: {
          0: const pw.FixedColumnWidth(70),
          1: const pw.FixedColumnWidth(70), 
          2: const pw.FixedColumnWidth(70),
          3: const pw.FixedColumnWidth(70),
          4: const pw.FixedColumnWidth(70)
        },

        children: [
          pw.TableRow(
            children: [              
              headerRowTable('Força'),
              headerRowTable('Agilidade'),
              headerRowTable('Luta'),
              headerRowTable('Prontidão')
            ]
          ),

          pw.TableRow(children: [
            cellRowTable(personagem.habilidades.getItem("FOR")["valor"].toString()),
            cellRowTable(personagem.habilidades.getItem("AGI")["valor"].toString()),
            cellRowTable(personagem.habilidades.getItem("LUT")["valor"].toString()),
            cellRowTable(personagem.habilidades.getItem("PRO")["valor"].toString())
          ]),

          pw.TableRow(
            children: [              
              headerRowTable('Vigor'),
              headerRowTable('Destreza'),
              headerRowTable('Intelecto'),
              headerRowTable('Presença')
            ]
          ),

          pw.TableRow(children: [
            cellRowTable(personagem.habilidades.getItem("VIG")["valor"].toString()),
            cellRowTable(personagem.habilidades.getItem("DES")["valor"].toString()),
            cellRowTable(personagem.habilidades.getItem("INT")["valor"].toString()),
            cellRowTable(personagem.habilidades.getItem("PRE")["valor"].toString())
          ]),

        ]
      )
    ]);

  static pw.Widget defesas() => pw.Column(
    mainAxisAlignment: pw.MainAxisAlignment.start,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('Defesas', style: headerTxtStyle),
      pw.Table(
        border: pw.TableBorder.all(),

        columnWidths: {
          0: const pw.FixedColumnWidth(80),
          1: const pw.FixedColumnWidth(80), 
          2: const pw.FixedColumnWidth(80),
          3: const pw.FixedColumnWidth(80),
          4: const pw.FixedColumnWidth(80),
          5: const pw.FixedColumnWidth(80)
        },
        children: [
          pw.TableRow(
            children: [              
              headerRowTable('Aparar'),
              headerRowTable('Esquiva'),
              headerRowTable('Fortitude'),
              headerRowTable('Resistência'),
              headerRowTable('Vontade')
            ]
          ),
          pw.TableRow(
            children: [
              cellRowTable(personagem.defesas.returnForPrint('D001')),
              cellRowTable(personagem.defesas.returnForPrint('D002')),
              cellRowTable(personagem.defesas.returnForPrint('D003')),
              cellRowTable(personagem.defesas.returnForPrint('D004')),
              cellRowTable(personagem.defesas.returnForPrint('D005'))
            ]
          )
        ]
      )

    ]
    
  );

  static pw.Widget ofensiva() => pw.Column(
    children: [
      pw.Text('Ofensiva', style: headerTxtStyle),
    ]
  );

  static pw.Widget vantagens() {
    List<pw.TableRow> tablesRows = [];
    List<pw.Text> contentRows;
    // Ordena Vantagens por Ordem Alfábetica
    personagem.vantagens.listaVantagens.sort((a, b) => a["nome"].compareTo(b["nome"]));

    pw.Text descVantagem(mapVantagem){
      Vantagem objVantagem = Vantagem().init(mapVantagem);
      return pw.Text(
        "${objVantagem.nome} ${objVantagem.graduado
        ? "[${objVantagem.grad() != objVantagem.returnTotalGrad() ? "*" : ''}${objVantagem.returnTotalGrad()}]" 
        : ''}"
      );
    } 

    int nMax = personagem.vantagens.listaVantagens.length;

    for (int i = 0; i < nMax / 2; i++) {
      contentRows = [];

      Map leftVantagem = personagem.vantagens.listaVantagens[i];
      contentRows.add(descVantagem(leftVantagem));

      if(nMax ~/ 2 + 1 + i < nMax){
        Map rightVantagem = personagem.vantagens.listaVantagens[nMax ~/ 2 + 1 + i];
        contentRows.add(descVantagem(rightVantagem));
      }
      tablesRows.add(pw.TableRow(children: contentRows));
    }
    
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,  
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.max,
      children: [
        pw.Text('Vantagens', style: headerTxtStyle),
        pw.Table(
          children: tablesRows          
        )
      ]
    );
  }

  static pw.Widget pericias() {
    List<pw.TableRow> tablesRows = [];
    List<pw.Text> contentRows;

    int nMax = personagem.pericias.ListaPercias.length;

    pw.Text descPericia(Map mapPericia){
      Pericia objPericia = Pericia();
      objPericia.init(mapPericia);
      
      return pw.Text(
        "${objPericia.nome}(${objPericia.onlyGrad()}) +${objPericia.bonusTotal()}"
      );
    }

    for(int i = 0; i <= nMax / 2; i++){
      contentRows = [];

      Map mapPericiaRight = personagem.pericias.ListaPercias[i];
      contentRows.add(descPericia(mapPericiaRight));

      if(nMax ~/ 2 + 1 + i < nMax){
        Map mapPericiaLeft = personagem.pericias.ListaPercias[nMax ~/ 2 + 1 + i];
        contentRows.add(descPericia(mapPericiaLeft));
      }

      tablesRows.add(pw.TableRow(children:contentRows));
    }

    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Perícias', style: headerTxtStyle),
        pw.Table(
          children: tablesRows
        )
      ] 
    );
  }
  


  static void generatePDF(Uint8List fileImg) async{
    pw.Document doc = pw.Document();

    // Carrega as Fontes
    headerFont = pw.Font.ttf(await rootBundle.load('fonts/Impact.ttf'));
    headerTxtStyle = pw.TextStyle(font: headerFont, fontSize: 20);   

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.portrait,
        margin: const pw.EdgeInsets.all(25),
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Flexible(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children:[
                        infoHeader(),
                        habilidades(),
                      ]
                  )),
                  // Cabeçalho Inicial
                  
                  // Imagem 
                  fileImg.isNotEmpty ?
                    pw.Flexible(
                      flex: 1,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Image(
                          pw.MemoryImage(fileImg),
                          height: 150,
                          alignment: pw.Alignment.center

                      ))
                    ) : pw.SizedBox()
                  
              ]),
              defesas(),
              ofensiva(),
              vantagens(),
              pericias()
            ]
          );
        }
      )
    );

    await Printing.layoutPdf(onLayout: (format) async => await doc.save());
  }
}