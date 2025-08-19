import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

import 'dart:developer';

class PowerGeneric{
  Efeito ef = Efeito();
  Map power = {};
  
  List<pw.Widget> title(){
    List<pw.Widget> powerTitle = [];
    // criação do Nome
    if(power["nome"] != ""){
      powerTitle.add(
        pw.Text('${power["nome"]}: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      );
      powerTitle.add(
        pw.Text(power["efeito"])
      );
    }else{
      powerTitle.add(
        pw.Text('${power["efeito"]}: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      );
    }

    // Add graduação
    powerTitle.add(pw.Text(' ${ef.returnGraduacao()}'));
    return powerTitle;
  }
  
  pw.Text modify(Map modify) => pw.Text(
    ", ${modify["nome"]}" + // ${modify["desc"]}
    '${(modify["fixo"] || modify["grad"] > 2) ? modify["grad"] : ""}'
  );

  pw.Text custo() => pw.Text(' - ${ef.custearAlteracoes()} pontos');

  render(Map power)async{
    await init(power);

    List<pw.Widget> powerContent = [];

    powerContent.addAll(title());

    if(power["class"] == "EfeitoAflicao"){
      powerContent.add(pw.Text(' ['));
      if(power["condicoes"][0] != ""){
        powerContent.add(pw.Text(power["condicoes"][0]));
      }
          
      if(power["condicoes"][1] != ""){
        powerContent.add(pw.Text(", ${power["condicoes"][1]}, "));
      }
    
      if(power["condicoes"][2] != ""){
        powerContent.add(pw.Text(power["condicoes"][2]));
      }
      powerContent.add(pw.Text(']'));
      
    }

    // Modificadores
    for (Map m in power["modificadores"] ) {
      powerContent.add(modify(m));
    }

    // Custo
    powerContent.add(custo());

    return pw.Row( children: powerContent );
  }

  init(powerImport) async{
    ef = await Efeito.init(powerImport);
    power = ef.retornaObj();
    return this;
  }
}

class WidPdgPoderes{
  static pdfBlack() => const PdfColor(0, 0, 0);

  static decorationBorder() => pw.BoxDecoration( 
    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
    border: pw.Border.all(color: WidPdgPoderes.pdfBlack(), style: pw.BorderStyle.solid, width: 0.5)
  );

  // Construção para poderes genéricos
  static Future<pw.Widget> genericPower(Map power)async => await PowerGeneric().render(power);

  static Future<pw.Widget> packege(Map packged) async => pw.Column(
    children: [
      pw.Text(packged["nome"]),
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
          wigetPoderes.add(await WidPdgPoderes.genericPower(pd));
      }
      
    }

    return wigetPoderes;
  }

}