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
      inputIntVantagem.text = widget.obj["graduacao"].toString();
      textDesc.text = widget.obj["txtDec"];
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vantagens'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async => {
          }),
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
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: inputIntVantagem,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],

                        onChanged: (value) => {                          
                          // Tem que ser numérico
                          if(RegExp(r'^[0-9]').hasMatch(value)){

                            // Minimo                            
                            if(int.parse(value) >= 1 && selectVantagem["limite"] != null){
                              // Dentro do Máximo                              
                              if ( selectVantagem["limite"] == 0 || int.parse(value) <= selectVantagem["limite"] ){
                                setState(() {
                                  valueVantagem = int.parse(value);
                                })
                              } else{ // Fora do Máximo
                                setState(() {
                                  valueVantagem = selectVantagem["limite"];
                                })
                              }
                            }
                            else if(selectVantagem["limite"]){
                              // é graduado mas o limite não é defnido
                              // Valor provavelmente será alertado nos limites de NP
                              setState(() {
                                valueVantagem = int.parse(value);
                              })
                              
                            }
                            else{ // Fora do minimo
                              setState(() {
                                valueVantagem = 1;
                              })
                            }
                          //   || int.parse(value) <= selectVantagem["limite"] )
                          // && int.parse(value) >= 1){
                            
                          },
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          //hintText: 'Nº Grad.',
                          helperText: 'Nº Grad.',
                        ),
                      ),
                    ) : const SizedBox(),
                  ],
                ),
              
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        
                        //? Seleciona a Vantagem
                        widget.obj.isEmpty ?
                        DropdownButton<Map>(
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
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  crossAxisAlignment: CrossAxisAlignment.center,
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
