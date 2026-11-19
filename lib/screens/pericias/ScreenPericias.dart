import 'package:flutter/material.dart';
import 'package:fabrica_do_multiverso/screens/components/abrir_popup.dart';
import 'package:flutter/services.dart';

// Popups
import 'package:fabrica_do_multiverso/screens/pericias/functions/addPericias.dart';

// Biblioteca de Pericias
import 'package:fabrica_do_multiverso/script/ficha.dart';
import 'package:fabrica_do_multiverso/script/pericias/lib_pericias.dart';

class ScreenPericias extends StatefulWidget {
  const ScreenPericias({super.key});
  @override
  _ScreenPericiasState createState() => _ScreenPericiasState();
}

class _ScreenPericiasState extends State<ScreenPericias> {
  List<Map> listaPercias = []; // Pericias Adiconais
  Pericia pericia = Pericia(); // Classe de Manipulação
  Map mapPericiaReturn = {};   // Mapa de Retorno
  int custoTotal = 0;          // Custo total

  List<TextEditingController> listInputs = [];

  //* Constante de estilo
  TextStyle headPericias = const TextStyle(fontFamily: "Impact", height: 45);

  @override
  void initState() {
    super.initState();
    _initProg();
    _initialStete();
  }

  void _initProg() {
    listaPercias = personagem.pericias.ListaPercias;
  }
  Future<bool> _updateTextInputList(){
    setState(() {
      // Adiciona e Remove input Text
      // conforme a quantidade de perícias
      if(listaPercias.length > listInputs.length){
        while(listaPercias.length > listInputs.length){
          listInputs.add(TextEditingController(text: "0"));
        }
      }else if(listaPercias.length < listInputs.length){
        while(listaPercias.length < listInputs.length){
          listInputs.removeLast();
        }
      }
    });
    
    return Future<bool>.value(true);
  }

  void _initialStete() {
    setState(() {
      // define custo total
      custoTotal = personagem.pericias.calculaTotal();

      // Instancia campos de input
      for (Map p in listaPercias) {
          listInputs.add(TextEditingController(text: p["valor"].toString()));
      }
    });
  }

  void appendNewListFields(){
    // anexa a lista
    if(mapPericiaReturn.isNotEmpty){
      // updateNewFields(){
      Pericia periAddicional;
      if(mapPericiaReturn["class"] == "PericiaAdiciona"){
        periAddicional = PericiaAdiciona();
      }else if(mapPericiaReturn["class"] == "PericiaAddAcerto"){
        periAddicional = PericiaAddAcerto();
      }else{
        // caso haja futuras Implementações
        periAddicional = Pericia();
      }

      periAddicional.init(mapPericiaReturn);

      setState((){
        listaPercias.add(periAddicional.returnObj());
      });
      _updateTextInputList();
      
      // Atualiza Lista de Bonus de Adição
      personagem.validador.updatePericiaBonus();

    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //print(screenWidth); // deixar guardado para futuros debug
    int crossAxisCount = 2;
    crossAxisCount = screenWidth > 700 ? 2 : 1;
    return Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Pericias'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async => {
                    // Fecha A Aplicação & passando alterações
                    Navigator.of(context).pop()
                  }),
        ),
        body: SafeArea(child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            // Grid de Pericias
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: GridView.builder(
                  // Espaço no fim para o botão flutuante não cobrir o último item
                  padding: const EdgeInsets.only(bottom: 88),
                  //; configurações de grid
                  //; para deixar mais proximo de uma ficha 2 colunas de pericias
                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // Define o número de colunas
                    crossAxisSpacing: 8,  // Espaço horizontal entre os itens
                    mainAxisSpacing: 1.0,  // Espaço vertical entre os itens
                    // Altura fixa: a proporção cortava o item em celulares estreitos
                    mainAxisExtent: 150,
                                
                    
                  ),
                                
                  itemCount: listaPercias.length,
                  itemBuilder: (context, index){
                    Pericia pericia = Pericia();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                
                      child: GestureDetector(
                        // Área inteira do item responde ao toque
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //# Titulo da Perícia
                            Flexible(child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                Text(
                                  listaPercias[index]["escopo"] != null
                                    ? "${listaPercias[index]["nome"]}: (${listaPercias[index]["escopo"]})"
                                    : listaPercias[index]["nome"],
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                SizedBox(
                                  height: 80,
                                  child: Row(
                                    // Largura conforme o conteúdo: o total não é cortado
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      SizedBox(
                                        width: 80,
                                        // # preenchimento da graduação
                                        child: index < listInputs.length ? 
                                        TextField(
                                          controller: listInputs[index],
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.digitsOnly
                                          ],
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) =>{
                                            if(RegExp(r'^[0-9]').hasMatch(value)){
                                              listaPercias[index]["valor"] = int.parse(value),
                                            },                                
                                            setState(() {
                                              custoTotal = personagem.pericias.calculaTotal();
                                            }),

                                            // Atualiza Lista de Bonus de Adição
                                            personagem.validador.updatePericiaBonus()
                                          }
                                        ) : const SizedBox(),
                                      ),
                                  
                                      const SizedBox(width: 10),
                                      // o metodo init pode não carregar a tempo da chamda de bonusTotal
                                      // para evitar problemas refiz a chamada
                                      pericia.init(listaPercias[index])
                                        ? Text("Total: ${pericia.bonusTotal()}") 
                                        : const Text("Total: "), 
                                    ],
                                  ),
                                ),
                              ],
                            )),
                            listaPercias[index]["classe"] != "Pericia" ?
                            IconButton(
                              icon: const Icon(Icons.delete),

                              onPressed: (){
                                // Remove dos Poderes associados a esse bonus
                                // (especialidades não têm idCriacao nem bônus em poderes)
                                final String? idCriacao = listaPercias[index]["idCriacao"];
                                if(idCriacao != null){
                                  personagem.validador.deletePericiaWhere(idCriacao);
                                }

                                setState(() {
                                  listaPercias.removeAt(index);
                                  // Mantém os campos alinhados com a lista e o custo atualizado
                                  if(index < listInputs.length){ listInputs.removeAt(index); }
                                  custoTotal = personagem.pericias.calculaTotal();
                                });
                                  
                              },
                            ) : const SizedBox(),
                          ],
                        ),

                        onTap: () async {
                          //? efetua o loading novament para alteração de pericias adicionais
                          if(["PericiaAdiciona", "PericiaAddAcerto"].contains(listaPercias[index]["classe"])){
                            Map mapPericiaReturn;
                            mapPericiaReturn = await abrirPopup<Map>(
                              context, PopUpAddSkill(obj: listaPercias[index])
                            ) ?? {};
                            if(mapPericiaReturn.isNotEmpty){
                              if(mapPericiaReturn["remove"] == null || mapPericiaReturn["remove"] == false){
                                Pericia mntPericia;
                                if(mapPericiaReturn["class"] == "PericiaAddAcerto"){
                                  mntPericia = PericiaAddAcerto();
                                }else if(mapPericiaReturn["class"] == "PericiaAdiciona"){
                                  mntPericia = PericiaAdiciona();
                                }else{
                                  mntPericia = Pericia();
                                }

                                mntPericia.init(mapPericiaReturn);

                                setState(() {                                    
                                  listaPercias[index] = mntPericia.returnObj();
                                });

                              }else if(mapPericiaReturn["remove"] == true){ // caso remove venha true é um pedido de remoção
                                // Atualiza as Lista de perícias  
                                setState(() {
                                  listaPercias.removeAt(index);
                                });
                                _updateTextInputList();
                              }


                              // Atualiza Lista de Bonus de Adição
                              personagem.validador.updatePericiaBonus();
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                child: Text('Total: ${custoTotal.toString()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))
              ),
            )
          ]
                ),
        )),

      //# Botão de Adicionar novas Perícias
      floatingActionButton: FloatingActionButton(
          tooltip: 'Adicionar Poder',
          child: const Icon(Icons.add),
          // Ação e PopUP
          onPressed: () async => {
            mapPericiaReturn = await abrirPopup<Map>(
              context, PopUpAddSkill(obj: {})
            ) ?? {},

            appendNewListFields()
          }
        ),
    );
  }
}



