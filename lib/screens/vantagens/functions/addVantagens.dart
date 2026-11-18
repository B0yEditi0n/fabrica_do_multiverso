//# Dialogo de Adição de Perícias

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Biblioteca de Pericias
import 'package:fabrica_do_multiverso/script/vantagens/lib_vantagens.dart';

class PopUpAddVantagem extends StatefulWidget {
  List repertorioVantagens = [];
  Map obj = {};
  PopUpAddVantagem(
      {super.key, required this.repertorioVantagens, required this.obj});

  @override
  _PopUpAddVantagemState createState() => _PopUpAddVantagemState();
}

class _PopUpAddVantagemState extends State<PopUpAddVantagem> {
  Map selectVantagem = {};
  List repertorioVantagens = [];
  int valueVantagem = 1;
  Vantagem vantagemObj = Vantagem();

  TextEditingController inputIntVantagem = TextEditingController();
  TextEditingController textDesc = TextEditingController();

  @override
  void initState() {
    // _title = widget.title;
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
  }

  void _carregarDados() async {
    repertorioVantagens = widget.repertorioVantagens;
    if(widget.obj.isEmpty){
      selectVantagem = repertorioVantagens.first;
      inputIntVantagem.text = '1';
    }else{
      selectVantagem = widget.obj;
      // Parte da graduação já comprada (antes a edição voltava para 1)
      valueVantagem = widget.obj["graduacao"] ?? 1;
      inputIntVantagem.text = valueVantagem.toString();
      textDesc.text = widget.obj["txtDec"] ?? "";
    }
    
  }

  // Teto oficial da vantagem selecionada (null: sem teto)
  int? _graduacaoMaxima() => Vantagem().init(selectVantagem).graduacaoMaxima();

  void _defineGraduacao(int valor) {
    valor = Vantagem().init(selectVantagem).limitaGraduacao(valor);
    setState(() {
      valueVantagem = valor;
      if (inputIntVantagem.text != '$valor') {
        // Mantém o cursor no fim ao corrigir o valor digitado
        inputIntVantagem.value = TextEditingValue(
          text: '$valor',
          selection: TextSelection.collapsed(offset: '$valor'.length),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int? teto = _graduacaoMaxima();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vantagens'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop({})),
      ),

      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.center,
                
                children: [
                //? Descrição da Vantagem (se tiver)
                Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  spacing: 10.0,
                  runSpacing: 15.0,
                  children: [
                    
                    //; se tiver descrição
                    selectVantagem["desc"] ? 
                    SizedBox(
                      width: 600,
                      child: TextField(
                        controller: textDesc,
                        decoration: const InputDecoration(
                          //border: OutlineInputBorder(),
                          hintText: 'Descrição',
                        ),
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
              
                      ),
                    ): const SizedBox(),
                                  
                    //; se for graduado
                    selectVantagem["graduado"] ? 
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Diminuir graduação',
                          icon: const Icon(Icons.remove),
                          onPressed: valueVantagem > 1
                            ? () => _defineGraduacao(valueVantagem - 1)
                            : null,
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: inputIntVantagem,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value) {
                              if (value.isNotEmpty) _defineGraduacao(int.parse(value));
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              helperText: teto == null
                                ? 'Nº Grad.'
                                : 'Máx. $teto',
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Aumentar graduação',
                          icon: const Icon(Icons.add),
                          // Desabilitado ao atingir o teto oficial
                          onPressed: teto == null || valueVantagem < teto
                            ? () => _defineGraduacao(valueVantagem + 1)
                            : null,
                        ),
                      ],
                    ) : const SizedBox(),
                  ],
                ),
              
                // Largura limitada e lista expandida: nomes longos não estouram a tela
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),

                        //? Seleciona a Vantagem
                        widget.obj.isEmpty ?
                        DropdownButton<Map>(
                          isExpanded: true,
                          itemHeight: 56,
                          value: selectVantagem,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                          underline: Container(
                            height: 2,
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectVantagem = value!;
                            });
                            _defineGraduacao(1);
                          },
                          items: repertorioVantagens.map<DropdownMenuItem<Map>>((value) {
                            return DropdownMenuItem<Map>(
                              value: value,
                              child: Text(value["nome"].toString()),
                            );
                          }).toList(),
                        ) : const SizedBox(),
                      ],
                    ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      child: const Text("Cancelar"),
                      onPressed: (){
                        vantagemObj.init(selectVantagem);
                        Navigator.of(context).pop({});
                      }
                    ),

                    TextButton(
                      child: const Text("Adicionar"),
                      onPressed: (){
                        // Checa se tem descrição
                        if(selectVantagem["desc"]){
                          selectVantagem["txtDec"] = textDesc.text;
                        }

                        // Checa se tem graduação
                        if(selectVantagem["graduado"]){
                          selectVantagem["graduacao"] = valueVantagem;
                        }else{
                          selectVantagem["graduacao"] = 1;
                        }

                        vantagemObj.init(selectVantagem);
                        Navigator.of(context).pop(vantagemObj.returnObj());
                      }
                    )
                  ],
                ),
              ]
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
