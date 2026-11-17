import 'package:pdf/widgets.dart' as pw;
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

//
// Instnacia Genérica de funcionamento
//

class PowerGeneric{
  Efeito ef = Efeito();
  Map power = {};
  
  bool altenativo = false;
  String prefixo = ''; // "EA: ", "EAD: ", "Ligado: "

  List<pw.TextSpan> title(){
    List<pw.TextSpan> powerTitle = [];
    if(prefixo.isNotEmpty){
      powerTitle.add(pw.TextSpan(text: prefixo, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)));
    }
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
    ", ${modify["nome"]}"
    "${(modify["grad"] ?? 0) > 1 ? " ${modify["grad"]}" : ""}"
    "${"${modify["text_desc"] ?? ''}".isNotEmpty ? " (${modify["text_desc"]})" : ""}",
  );

  pw.TextSpan custo() => pw.TextSpan(text: ' - ${ef.custearAlteracoes()} pontos', 
  style: pw.TextStyle(fontStyle: altenativo ? pw.FontStyle.italic : pw.FontStyle.normal));

  aflicaoEfeito(){
    List<pw.TextSpan> powerContent = [];

    if(power["class"] == "EfeitoAflicao"){
      List condicoes = ((power["condicoes"] ?? []) as List)
          .where((c) => c != null && "$c".isNotEmpty).toList();
      if(condicoes.isNotEmpty){
        powerContent.add(pw.TextSpan(text: ' (${condicoes.join(", ")})'));
      }
      
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
      List alvos = power["alvoAumento"] ?? [];
      powerContent.add(pw.TextSpan(text: alvos.map((alv) => "${alv["nome"]}: ${alv["valor"]}").join(", ")));
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
    for (Map m in power["modificadores"] ?? [] ) {
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

  Future<pw.Widget> render(Map power, [String prefixo = ''])async{
    this.prefixo = prefixo;
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

    altenativo = powerImport["alternativo"] == true;
    power = ef.retornaObj();
    return this;
  }
}