import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

class WidPdgPoderes{
  static pdfBlack() => const PdfColor(0, 0, 0);

  static decorationBorder() => pw.BoxDecoration( 
    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
    border: pw.Border.all(color: WidPdgPoderes.pdfBlack(), style: pw.BorderStyle.solid, width: 0.5)
  );


  //
  // Construção para poderes genéricos
  //

  static pw.Text modify(Map modify) => pw.Text(
    ", ${modify["nome"]}" + // ${modify["desc"]}
    '${(modify["fixo"] || modify["grad"] > 2) ? modify["grad"] : ""}'
  );
  static Future<pw.Widget> genericPower(Map power)async{
    Efeito ef = Efeito();
    await ef.reinstanciarMetodo(power);
    
    List<pw.Widget> powerContent = [];

    // criação do Nome
    if(power["nome"] != ""){
      powerContent.add(
        pw.Text(power["nome"] + ': ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      );
      powerContent.add(
        pw.Text(power["efeito"])
      );
    }else{
      powerContent.add(
        pw.Text(power["efeito"] + ': ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      );
    }

    // Modificadores
    for (Map m in power["modificadores"] ) {
      powerContent.add(WidPdgPoderes.modify(m));
    }

    // Custo
    powerContent.add(pw.Text(' - total: ${ef.custearAlteracoes()}'));

    return pw.Row( children: powerContent );
  }

  static Future<pw.Widget> packege(Map packged) async =>
  pw.SizedBox(
    child: pw.Container(
      decoration: decorationBorder(),
      padding: const pw.EdgeInsets.all(5),
      width: 560,
      //margin: const pw.EdgeInsets.all(),
      child: pw.Column(
        children: await WidPdgPoderes.classificador(packged["efeitos"])
      )
    )
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
          wigetPoderes.add(await WidPdgPoderes.genericPower(pd));
      }
      
    }

    return wigetPoderes;
  }

}