import 'dart:developer';
import 'package:fabrica_do_multiverso/screens/poderes.dart';
import 'package:numberpicker/numberpicker.dart';

import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:flutter/material.dart';
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
    optionCompraSelecionado = optionsCompra.first["ID"];
    optSelecionado = optionsCompra.first;
    
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
            DropdownButton<String>(
              value: optionCompraSelecionado,
              //icon: const Icon(Icons.arrow_downward),
              //elevation: 16,
              style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              /*underline: Container(
                height: 2,
              ),*/
              onChanged: (String? value) {
                setState(() {
                  optionCompraSelecionado = value!;
                  // Atualiza o selecionado
                  var index = optionsCompra.indexWhere((mod) => mod["ID"] == optionCompraSelecionado);
                  optSelecionado = optionsCompra[index];
                  // Resta a Graduação
                  optGrad = 1;
                });
              },
              items: optionsCompra.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value["ID"], 
                  child: Text(value["desc"].toString()),
                );
              }).toList(),
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
      actions: <Widget>[
        TextButton(
          child: const Text('Adicionar'),
          onPressed: () async{
            // Atualiza a Classe
            
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
