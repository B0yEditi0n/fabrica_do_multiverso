import 'dart:developer';
import 'package:numberpicker/numberpicker.dart';

import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';
import 'package:flutter/material.dart';
import 'package:fabrica_do_multiverso/screens/components/dropdown_com_busca.dart';
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
  List<OpcaoDropdown<Map>> opcoes = [];
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
    // O popup pode ter sido fechado durante a leitura
    if(!mounted) return;
    
    setState(() {
      // Grupos da busca: próprios do efeito primeiro, depois extras e falhas
      opcoes = [
        for(Map mod in efeitosMod)
          OpcaoDropdown<Map>(valor: mod, rotulo: mod["nome"].toString(),
            grupo: Efeito.grupoModificador(mod, proprioDoEfeito: true)),
        // O seletor junta os itens do mesmo grupo (extras, depois falhas)
        for(Map mod in modsGerais)
          OpcaoDropdown<Map>(valor: mod, rotulo: mod["nome"].toString(),
            grupo: Efeito.grupoModificador(mod)),
      ];
      modificadores = opcoes.map((o) => o.valor).toList();

      if(modificadores.isNotEmpty){
        modSelecionado = modificadores.first;
        // Alguns modificadores próprios usam e_id em vez de m_id (EC001, ES01, E044/E045)
        modificadorSelecionado = modSelecionado["m_id"] ?? modSelecionado["e_id"] ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Modificador'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[ 
            // Escolha do modificador
            DropdownComBusca<Map>(
              opcoes: opcoes,
              valor: modSelecionado.isEmpty ? null : modSelecionado,
              aoMudar: (Map value) {
                setState(() {
                  modSelecionado = value;
                  modificadorSelecionado = value["m_id"] ?? value["e_id"] ?? '';
                  // Resta a Graduação
                  modGrad = 1;
                });
              },
            ),
            // Controle de Graduação *se tiver
            modSelecionado.isNotEmpty && Efeito.limiteModificador(modSelecionado, poder.retornaObj()["graduacao"] ?? 1) > 1 ?
            NumberPicker(
              value: modGrad,
              minValue: 1,
              maxValue: Efeito.limiteModificador(modSelecionado, poder.retornaObj()["graduacao"] ?? 1),
              onChanged: (value) => setState(() => modGrad = value),
            )
            : const SizedBox()
          ]
        )
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actions: <Widget>[
        TextButton(
          child: const Text('Adicionar'),
          onPressed: () async{
            // Lista vazia: nada a adicionar
            if(modSelecionado.isEmpty) return;

            // Define a graduação
            modSelecionado["grad"] = modGrad;
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
