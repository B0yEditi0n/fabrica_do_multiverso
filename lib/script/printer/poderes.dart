import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

import 'dart:developer';

const int sizedWidgetColumn = 560;

class PowerGeneric{
  Efeito ef = Efeito();
  Map power = {};
  
  List<pw.TextSpan> title(){
    List<pw.TextSpan> powerTitle = [];
    // criação do Nome
    if(power["nome"] != ""){
      powerTitle.add(
        pw.TextSpan(text: '${power["nome"]}: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      );
      powerTitle.add(
        pw.TextSpan(text: power["efeito"])
      );
    }else{
      powerTitle.add(
        pw.TextSpan(text: '${power["efeito"]}: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      );
    }

    // Add graduação
    powerTitle.add(pw.TextSpan(text: ' ${ef.returnGraduacao()}'));
    return powerTitle;
  }
  
  pw.TextSpan modify(Map modify) => pw.TextSpan(
    text:
    ", ${modify["nome"]}",
    children:[
      pw.TextSpan(text: '${(modify["fixo"] || modify["grad"] > 2) ? modify["grad"] : ""}')
    ]
    // ${modify["desc"]}
    
  );

  pw.TextSpan custo() => pw.TextSpan(text: ' - ${ef.custearAlteracoes()} pontos');

  Future<pw.Widget> render(Map power)async{
    await init(power);

    List<pw.TextSpan> powerContent = [];

    powerContent.addAll(title());

    if(power["class"] == "EfeitoAflicao"){
      powerContent.add(const pw.TextSpan(text: ' ('));
      if(power["condicoes"][0] != ""){
        powerContent.add(pw.TextSpan(text: power["condicoes"][0]));
      }
          
      if(power["condicoes"][1] != ""){
        powerContent.add(pw.TextSpan(text: ", ${power["condicoes"][1]}, "));
      }
    
      if(power["condicoes"][2] != ""){
        powerContent.add(pw.TextSpan(text: power["condicoes"][2]));
      }
      powerContent.add(const pw.TextSpan(text:')'));
      
    }

    //#
    //# Modificadores
    //#

    if(power["class"] == "EfeitoBonus"){
      powerContent.add(const pw.TextSpan(text:' ('));
      for(Map alv in power["alvoAumento"]){
        powerContent.add(pw.TextSpan(text: "${alv["nome"]}: ${alv["valor"]}"));
      }
      powerContent.add(const pw.TextSpan(text:')'));
    }
    

    // checa se distância é padrão
    if(ef.returnObjDefault()["alcance"] != power["alcance"]){
      powerContent.add(modify({
        "nome": ef.returnStrAlcance(),
        "fixo": false,
        "grad": 0
      }));
    }
    // Modificadores
    for (Map m in power["modificadores"] ) {
      powerContent.add(modify(m));
    }
    // Duração
    if(ef.returnObjDefault()["duracao"] != power["duracao"]){
      powerContent.add(modify({
        "nome": ef.returnStrDuracao(),
        "fixo": false,
        "grad": 0
      }));
    }
    // Criar uma tratativa para reação
    // acao

    // Custo
    powerContent.add(custo());

    return pw.RichText( 
      overflow: pw.TextOverflow.clip,
      text: pw.TextSpan(text:'',
      children: powerContent 
    ));
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
        case "":
          break;
        default:
          wigetPoderes.add(await WidPdgPoderes.genericPower(pd));
      }
      
    }

    return wigetPoderes;
  }

}