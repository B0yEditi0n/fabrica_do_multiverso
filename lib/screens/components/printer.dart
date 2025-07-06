// Arquivo de Ficha
import 'package:fabrica_do_multiverso/script/ficha.dart';

// Criação de PDFs
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:flutter/services.dart' show rootBundle;

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

  static void generatePDF() async{
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
            children: [
              pw.Row(
                children: [pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children:[
                    infoHeader(),
                    habilidades(),
                    defesas()
                  ]
                )
              ])
            ]
          );
        }
      )
    );

    await Printing.layoutPdf(onLayout: (format) async => await doc.save());
  }
}