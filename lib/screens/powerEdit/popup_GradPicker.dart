import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

//****************************************** */
// Pop Up Seta Nivel da Graduação do Poder
//****************************************** */


class GradPowerDialog extends StatefulWidget {
  final int gradValue;
  final String titulo;
  GradPowerDialog({super.key, required this.gradValue, required this.titulo});

  @override
  _GradPowerDialogState createState() => _GradPowerDialogState();
}

class _GradPowerDialogState extends State<GradPowerDialog> {
  // Declaração de Variáveis  
  final efeitos = [];
  int _gradValue = 1;
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
      _gradValue = widget.gradValue;
      titulo     = widget.titulo;
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
              value: _gradValue,
              minValue: 1,
              maxValue: 20, // parametrizar pelo NP posteriormente
              onChanged: (value) => setState(() => _gradValue = value),
            ),
          ]
        )
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Ok'),
          onPressed: () async{
            // Atualiza a Classe
            poder.graduacao = _gradValue;
            // Fecha o popup
            Navigator.of(context).pop();
          },
        ),
      ],
      );
  }
}

