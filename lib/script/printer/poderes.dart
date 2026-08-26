import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

//
// Importação das Classes de abstração
//
import 'package:fabrica_do_multiverso/script/printer/powerGenertic.dart';


import 'dart:developer';

// Largura útil da página A4 retrato com as margens de 25pt usadas em
// Printer.generatePDF (595.28pt - 25pt - 25pt). Mantido como fonte única
// para não haver caixas maiores que a área imprimível.
// Se um dia mudar as margens em Printer.generatePDF, ajuste aqui também.
const double sizedWidgetColumn = 545;


class WidPdgPoderes{
  static pdfBlack() => const PdfColor(0, 0, 0);

  static decorationBorder() => pw.BoxDecoration( 
    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
    border: pw.Border.all(color: WidPdgPoderes.pdfBlack(), style: pw.BorderStyle.solid, width: 0.5)
  );

  // Construção para poderes genéricos
  static Future<pw.Widget> genericPower(Map power)async => await PowerGeneric().render(power);
  static Future<pw.Widget> customPower(PowerGeneric objPower, Map power)async => await objPower.render(power);

  static Future<pw.Widget> packege(Map packged) async => pw.Column(
    mainAxisAlignment: pw.MainAxisAlignment.start,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(
      child: pw.Container(
        decoration: decorationBorder(),
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(packged["nome"]),
      )),
      
      pw.SizedBox(
        child: pw.Container(
          decoration: decorationBorder(),
          padding: const pw.EdgeInsets.all(5),
          width: sizedWidgetColumn,
          //margin: const pw.EdgeInsets.all(),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: await WidPdgPoderes.classificador(packged["efeitos"])
          )
        )
      )
    ]
  );


  static Future<List<pw.Widget>> classificador(List poder) async{
    List<pw.Widget> wigetPoderes = [];

    for(int i = 0; i < poder.length; i++){
      Map pd = poder[i];

      switch (pd["class"]){
        case "PacotesEfeitos":
          wigetPoderes.add(await packege(pd));
          break; 
        default:
          wigetPoderes.add(await WidPdgPoderes.customPower(PowerGeneric(), pd));
          //wigetPoderes.add(await WidPdgPoderes.genericPower(pd));
      }
      
    }

    return wigetPoderes;
  }

}