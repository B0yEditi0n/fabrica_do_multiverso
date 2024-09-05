import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

// Instancia de Poderes
//import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

//****************************************** */
// Pop Up Seta Nivel da Graduação do Poder
//****************************************** */


class PoupInputIntValue extends StatefulWidget {
  final int intValue;
  final String titulo;
  final int iniValor;
  PoupInputIntValue({super.key, required this.intValue, required this.titulo, this.iniValor = 0});

  @override
  _PoupInputIntValueState createState() => _PoupInputIntValueState();
}

class _PoupInputIntValueState extends State<PoupInputIntValue> {
  // Declaração de Variáveis  
  final efeitos = [];
  int _valueInt = 1;
  int iniValor = 0; 
  String titulo = '';

  TextEditingController inputTextPoder = TextEditingController();
  String EfeitoSelecionado = '';
  @override
  
  void initState() {
    // _title = widget.title;
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
  }
  Future<void> _carregarDados() async {
    setState(() {
      titulo     = widget.titulo;
      _valueInt  = widget.intValue;
      iniValor   = widget.iniValor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            NumberPicker(
              value: _valueInt,
              minValue: iniValor,
              maxValue: 20, // parametrizar pelo NP posteriormente
              onChanged: (value) => setState(() => _valueInt = value),
            ),
          ]
        )
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Ok'),
          onPressed: () async{
            // Fecha o popup
            Navigator.of(context).pop(_valueInt);
          },
        ),
      ],
      );
  }
}

