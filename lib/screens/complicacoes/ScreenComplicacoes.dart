import 'package:flutter/material.dart';
import 'package:fabrica_do_multiverso/screens/components/abrir_popup.dart';

// Instancia de Poderes
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:flutter/widgets.dart';

class ScreenComplicacoes extends StatefulWidget {
  const ScreenComplicacoes({super.key});

  @override
  State<ScreenComplicacoes> createState() => _ScreenComplicacoesState();
}

class _ScreenComplicacoesState extends State<ScreenComplicacoes> {
  List editComplicacoes = [];
  Map<String, String> complicacaoObj = {};

  @override
  void initState() {
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
  }
  Future<void> _carregarDados() async {
    editComplicacoes = personagem.complicacoes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,          
          title: const Text("Complicações"),
        ),

        body: ListView.builder(
          // Espaço no fim para o botão flutuante não cobrir o último item
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: editComplicacoes.length,
          itemBuilder: (BuildContext context, int index){
            return InkWell(
            child: Column(
              children: [
                Card(
                  child: 
                  Row( children: <Widget> [
                    Expanded(
                      child:
                        //# Card de Exibição
                        // Exibe os poderes ativos
                        ListTile(
                          title: Text(editComplicacoes[index]["titulo"].toString()),
                          subtitle: Text(editComplicacoes[index]["desc"].toString()),
                        ) ,
                    ),
                
                    IconButton(
                      icon: const  Icon(Icons.delete),
                      onPressed: () =>{
                        personagem.complicacoes.removeAt(index),
                        setState(() {
                          editComplicacoes = personagem.complicacoes;
                        })
                      }
                    ),
                  ],
                  )
                ),
              ],
            ),
            onTap: () async{
               atualizarValores(){
                setState(() {
                  editComplicacoes = personagem.complicacoes;
                });
              }
              Map<String, String>? editada = await abrirPopup<Map<String, String>>(
                context,
                PopUpAddComplicacao(
                  title: editComplicacoes[index]["titulo"].toString(),
                  desc: editComplicacoes[index]["desc"].toString()
                ),
              );
              // Cancelar ou voltar do sistema devolve null: mantém a complicação
              if(editada == null) return;
              personagem.complicacoes[index] = editada;   
              atualizarValores();
            },
            );
          },
          
        ),

        //# Icone de Adicionar Novos Poderes

        floatingActionButton: FloatingActionButton(
          tooltip: 'Adicionar Complicação',
          child: const Icon(Icons.add),
          // Ação e PopUP
          onPressed: () async => {
            complicacaoObj = {},
            complicacaoObj = await abrirPopup<Map<String, String>>(
              context,
              PopUpAddComplicacao(title: "", desc: ""),
            ) ?? {},
            //! Atualiza a Lista de poderes
            if(complicacaoObj.isNotEmpty){
              personagem.complicacoes.add(complicacaoObj),
              setState(() {
                editComplicacoes = personagem.complicacoes;
              }),
            }            
          },
        ),
    );
  }
}


class PopUpAddComplicacao extends StatefulWidget {
  String title = "";
  String desc = "";

  PopUpAddComplicacao({super.key, required this.title, required this.desc});

  @override
  _PopUpAddComplicacaoState createState() => _PopUpAddComplicacaoState();
}

class _PopUpAddComplicacaoState extends State<PopUpAddComplicacao> {
  Map<String, String> complicacao = {};
  TextEditingController txtTitle = TextEditingController();
  TextEditingController txtDesc = TextEditingController();
  
  @override  
  void initState() {
    // _title = widget.title;
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar o estado
  }
  Future<void> _carregarDados() async {
    complicacao["titulo"] = widget.title;
    complicacao["desc"]  = widget.desc;
    // Coloca nos campos de texto
    setState(() {
      txtTitle.text = widget.title;
      txtDesc.text  = widget.desc;  
    });
    
  }

  @override
  Widget build(BuildContext context) {
    // Tamanho e centralização vêm de abrirPopup
    return AlertDialog(
        title: const Text('Complicação'),
        content: SingleChildScrollView(
          child: 
            Column(
              children: <Widget>[
                SizedBox(
                  child: TextField(
                    controller: txtTitle,
                    decoration: const InputDecoration(
                      hintText: 'Complicação',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
      
                const SizedBox(height: 10),
      
                SizedBox(                
                  child: TextField(
                    controller: txtDesc,
                    maxLines: 15,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Descrição da Complicação',
                      border: OutlineInputBorder(),
                    ),
                  ),
                )
              ]
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            //? Botões de cancelar e adicionar
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Adicionar'),
              onPressed: () async{
                //? Pont de Atenção
                complicacao["titulo"] = txtTitle.text;
                complicacao["desc"]  =  txtDesc.text;
                Navigator.of(context).pop(complicacao);
              },
            ),
          ],
        );
  }
}

