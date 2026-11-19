import 'dart:developer';
import 'package:fabrica_do_multiverso/screens/poderes/ScreenPoderes.dart';
import 'package:numberpicker/numberpicker.dart';

import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:flutter/material.dart';
import 'package:fabrica_do_multiverso/screens/components/dropdown_com_busca.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';
//
// Dialogo Adicionar Poderes
//

class AddOptCompra extends StatefulWidget {
  @override
  _AddOptCompraState createState() => _AddOptCompraState();
}

class _AddOptCompraState extends State<AddOptCompra> {
  List optionsCompra = [];
  Map optSelecionado = {};
  int optGrad = 1;

  EfeitoEscolha poderCompra = EfeitoEscolha();

  TextEditingController inputTextOpt = TextEditingController();
  String optionCompraSelecionado = '';
  @override
  
  void initState() {
    // _title = widget.title;
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
    
  }
  Future<bool> _carregarDados() async {
    // Carrega o Efeitos
    String jsonEfeitos = await rootBundle.loadString('assets/poderes/efeitos.json');
    List objEfeitos = jsonDecode(jsonEfeitos);
    // O popup pode ter sido fechado durante a leitura
    if(!mounted) return false;
    
    // força um cast na classe para acessar os metodos sem problemas
    // de sintaxe
    poderCompra = poder as EfeitoEscolha;

    String idEfeito = poderCompra.retornaObj()["e_id"];
    //int index = objEfeitos.indexWhere((efeito) => efeito["e_id"] == idEfeito);
    //Map efeito = objEfeitos[index];
    List efeitosOpt = [];
    //if (poderCompra.returnListOpt() != null){
    setState(() {      
        efeitosOpt = poderCompra.returnListOpt();        
    });
    //}
    optionsCompra = efeitosOpt;
    // Define o inicial da lista
    // Lista vazia: o seletor fica desabilitado
    if(optionsCompra.isNotEmpty){
      setState(() {
        optionCompraSelecionado = optionsCompra.first["ID"].toString();
        optSelecionado = optionsCompra.first;
      });
    }
    
    return true;

  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Poderes'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[ 
            // Escolha do modificador
            DropdownComBusca<String>(
              opcoes: optionsCompra.map((value) => OpcaoDropdown<String>(
                valor: value["ID"].toString(),
                rotulo: value["desc"].toString(),
              )).toList(),
              valor: optSelecionado.isEmpty ? null : optionCompraSelecionado,
              aoMudar: (String value) {
                setState(() {
                  optionCompraSelecionado = value;
                  // Atualiza o selecionado
                  int index = optionsCompra.indexWhere((mod) => mod["ID"].toString() == optionCompraSelecionado);
                  if(index >= 0) optSelecionado = optionsCompra[index];
                  // Resta a Graduação
                  optGrad = 1;
                });
              },
            ),
            // Controle de Graduação *se tiver
            /*optSelecionado["limite"] != null && optSelecionado["limite"] > 1 ? 
            NumberPicker(
              value: optGrad,
              minValue: 1,
              maxValue: optSelecionado["limite"], // parametrizar pelo NP posteriormente
              onChanged: (value) => setState(() => optGrad = value),
            )
            : const SizedBox()*/
          ]
        )
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actions: <Widget>[
        TextButton(
          child: const Text('Adicionar'),
          onPressed: () async{
            // Atualiza a Classe
            
            // Lista vazia: nada a adicionar
            if(optSelecionado.isEmpty) return;
            poderCompra.addOpt(optSelecionado);

            // Fecha o Popup
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            // Fecha o popup
            Navigator.of(context).pop();
          },
        ),
      ],
      );
  }
}
