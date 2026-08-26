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

  //
  // Efeitos de Escolha (EfeitoCompra / EfeitoCustoVaria)
  // Imprime as opções que foram efetivamente selecionadas em "opt"
  //
  List<pw.TextSpan> compra(){
    List<pw.TextSpan> powerContent = [];

    // Apenas EfeitoEscolha e suas filhas (EfeitoCompra, EfeitoCustoVaria) possuem "opt"
    if(power["opt"] == null || (power["opt"] as List).isEmpty){
      return powerContent;
    }

    List opt = power["opt"] as List;

    powerContent.add(const pw.TextSpan(text: ' ('));
    for(int i = 0; i < opt.length; i++){
      Map o = opt[i];

      // Nome da opção escolhida - tenta os campos mais prováveis do
      // json de origem (grupoOpt) antes de cair no ID puro
      String nomeOpt = (o["nome"] ?? o["name"] ?? o["desc"] ?? o["ID"] ?? '')
          .toString();

      // Texto livre digitado pelo usuário para essa opção (quando existir)
      String textoLivre = (o["text_desc"] ?? '').toString();

      // Valor/graduação individual da opção, quando fizer sentido exibir
      String valorOpt = (o["valor"] != null && (o["valor"] as num) > 1)
          ? ' ${o["valor"]}'
          : '';

      powerContent.add(pw.TextSpan(
        text:
            '${i > 0 ? ", " : ""}$nomeOpt$valorOpt${textoLivre.isNotEmpty ? " ($textoLivre)" : ""}',
      ));
    }
    powerContent.add(const pw.TextSpan(text: ')'));

    return powerContent;
  }

  modificadores(){
    List<pw.TextSpan> powerContent = [];
    //#
    //# Modificadores
    //#

    if(power["class"] == "EfeitoBonus" || power["class"] == "EfeitoCrescimento"){
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
    dev.debugger();
    ef = await Efeito.init(powerImport);
    
    print(powerImport);
    altenativo = powerImport["alternativo"] == true;
    power = ef.retornaObj();
    return this;
  }
}