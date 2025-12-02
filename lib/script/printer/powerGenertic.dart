import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

import 'dart:developer' as dev;
//
// Instnacia Genérica de funcionamento
//

class PowerGeneric{
  Efeito ef = Efeito();
  Map power = {};
  
  bool altenativo = false;

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

  pw.TextSpan custo() => pw.TextSpan(text: ' - ${ef.custearAlteracoes()} pontos', 
  style: pw.TextStyle(fontStyle: altenativo ? pw.FontStyle.italic : pw.FontStyle.normal));

  aflicaoEfeito(){
    List<pw.TextSpan> powerContent = [];

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

    return powerContent;
  }

  compra(){
    List<pw.TextSpan> powerContent = [];
    print(ef);
    return powerContent;
  }

  modificadores(){
    List<pw.TextSpan> powerContent = [];
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
    return powerContent;
  }

  Future<pw.Widget> render(Map power)async{
    await init(power);

    List<pw.TextSpan> powerContent = [];

    powerContent.addAll(title());

    // Especifico de efeitos
    powerContent.addAll(aflicaoEfeito());
    powerContent.addAll(compra());

    powerContent.addAll(modificadores());

    powerContent.add(custo());

    return pw.RichText( 
      overflow: pw.TextOverflow.clip,
      text: pw.TextSpan(text:'',
      children: powerContent 
    ));
  }

  init(powerImport) async{
    ef = await Efeito.init(powerImport);
    altenativo = !!powerImport["alternativo"];
    power = ef.retornaObj();
    return this;
  }
}