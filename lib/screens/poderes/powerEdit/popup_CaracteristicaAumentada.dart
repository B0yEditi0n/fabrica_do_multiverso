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

class AddCaractAumet extends StatefulWidget {
  Map caracteristica = {};
  AddCaractAumet({required this.caracteristica});

  @override
  _AddCaractAumetState createState() => _AddCaractAumetState();
}

class _AddCaractAumetState extends State<AddCaractAumet> {
  List caractCompra = [];
  Map caractSel = {};

  EfeitoBonus poderCompra = EfeitoBonus();

  TextEditingController inputValue = TextEditingController( text: '1' );

  @override  
  void initState() {
    // _title = widget.title;
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
    
  }
  Future<bool> _carregarDados() async {
    
    // força um cast na classe para acessar os metodos sem problemas
    // de sintaxe
    poderCompra = poder as EfeitoBonus;

    List listTemp = await poderCompra.returnListOpt();  
    // O popup pode ter sido fechado durante a leitura
    if(!mounted) return false;
    setState(() {   
      caractCompra = listTemp;
      // Lista vazia: o seletor fica desabilitado
      if(caractCompra.isNotEmpty){
        caractSel = caractCompra.first;
        caractSel["valor"] = 1;
      }
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Caracteristica Selecionada'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[             
            // Valor da Caracteristica (Atenção para Vantagens)
            SizedBox(
              width: 50,
              child: TextField(
                controller: inputValue,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (value) {
                  // Validar a entrada para evitar texto
                  // E Evita o máximo
                  setState((){
                    if(value.isNotEmpty){
                      caractSel["valor"] = int.parse(value);
                    }
                  });  
                }
              )
            ),

            const SizedBox(height: 30),

            // Escolha da Caracteristica 
            DropdownComBusca<Map>(
              opcoes: caractCompra.map((value) => OpcaoDropdown<Map>(
                valor: value,
                rotulo: value["nome"].toString(),
              )).toList(),
              valor: caractSel.isEmpty ? null : caractSel,
              aoMudar: (value) {
                setState(() {
                  caractSel = value;
                });
              },
            ),            
          ]
        )
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actions: <Widget>[
        TextButton(
          child: const Text('Adicionar'),
          onPressed: () async{
            // Fecha o Popup
            Navigator.of(context).pop(caractSel);
          },
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            // Fecha o popup
            Navigator.of(context).pop({});
          },
        ),
      ],
      );
  }
}
