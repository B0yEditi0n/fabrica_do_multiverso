import 'dart:developer';
import 'package:numberpicker/numberpicker.dart';

import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';

import 'package:fabrica_do_multiverso/script/ficha.dart' ;

//
// Dialogo Adicionar Poderes
//

class AddModificadorSelecionador extends StatefulWidget {
  List etiquetas = [];
  AddModificadorSelecionador({super.key, required this.etiquetas});
  @override
  _AddModificadorSelecionadorState createState() => _AddModificadorSelecionadorState();
}

class _AddModificadorSelecionadorState extends State<AddModificadorSelecionador> {
  List modificadores = [];
  Map modSelecionado = {};
  int modGrad = 1;

  TextEditingController inputTextPoder = TextEditingController();
  String modificadorSelecionado = '';
  @override
  
  void initState() {
    // _title = widget.title;
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
    
  }
  Future<void> _carregarDados() async {
    // Carrega o Efeitos
    String jsonEfeitos = await rootBundle.loadString('assets/poderes/efeitos.json');
    String jsonMod = await rootBundle.loadString('assets/poderes/modificadores.json');
    List objEfeitos = jsonDecode(jsonEfeitos);
    Map objMod = jsonDecode(jsonMod);
    

    Future<List> pegaEfeito() async{
      String idEfeito = poder.retornaObj()["e_id"];
      int index = objEfeitos.indexWhere((efeito) => efeito["e_id"] == idEfeito);
      Map efeito = objEfeitos[index];
      List efeitosMod = [];

      if (efeito["modificadores"] != null){
        efeitosMod = efeito["modificadores"];
      }

      return efeitosMod;
      
    }

    Future<List> pegaModificadores() async{
      String etiqueta = '';
      List listMods = [];

      for(etiqueta in widget.etiquetas){
        var currentMod = objMod[etiqueta];
        listMods += currentMod;
      }
      return listMods;
    } 

    List efeitosMod = await pegaEfeito();
    List modsGerais = await pegaModificadores();
    
    setState(() {
      modificadores = efeitosMod;
      modificadores += modsGerais;

      modificadorSelecionado = modificadores.first["m_id"];
    });
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
              value: modificadorSelecionado,
              //icon: const Icon(Icons.arrow_downward),
              //elevation: 16,
              style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              /*underline: Container(
                height: 2,
              ),*/
              onChanged: (String? value) {
                setState(() {
                  modificadorSelecionado = value!;
                  // Atualiza o selecionado
                  var index = modificadores.indexWhere((mod) => mod["m_id"] == modificadorSelecionado);
                  modSelecionado = modificadores[index];
                  // Resta a Graduação
                  modGrad = 1;
                });
              },
              items: modificadores.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value["m_id"], 
                  child: Text(value["nome"].toString()),
                );
              }).toList(),
            ),
            // Controle de Graduação *se tiver
            modSelecionado["limite"] != null && modSelecionado["limite"] > 1 ? 
            NumberPicker(
              value: modGrad,
              minValue: 1,
              maxValue: modSelecionado["limite"], // parametrizar pelo NP posteriormente
              onChanged: (value) => setState(() => modGrad = value),
            )
            : const SizedBox()
          ]
        )
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Adicionar'),
          onPressed: () async{
            // Atualiza a Classe

            /*var index = modificadores.indexWhere((mod) => mod["m_id"] == modificadorSelecionado);
            modSelecionado = modificadores[index];*/
            poder.addModificador(modSelecionado); 

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
