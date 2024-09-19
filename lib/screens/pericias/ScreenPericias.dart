import 'package:flutter/material.dart';
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
  List<Map> ListaPercias = []; // Pericias Adiconais
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
    List classPericias = personagem.pericias.ListaPercias;
    for (Map mapPericias in classPericias) {
      ListaPercias.add(mapPericias);
    }
  }
  Future<bool> _updateTextInputList(){
    setState(() {
      // Adiciona e Remove input Text
      // conforme a quantidade de perícias
      if(personagem.pericias.ListaPercias.length > listInputs.length){
        while(personagem.pericias.ListaPercias.length > listInputs.length){
          listInputs.add(TextEditingController(text: "0"));
        }
      }else if(personagem.pericias.ListaPercias.length < listInputs.length){
        while(personagem.pericias.ListaPercias.length < listInputs.length){
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
      for (Map p in ListaPercias) {
          listInputs.add(TextEditingController(text: p["valor"].toString()));
      }
    });
  }

  @override
  void dispose() {
    //! adição do Chat GPT ao código
    // Certifica-se de descartar todos os controladores ao finalizar
    for (var controller in listInputs) {
      controller.dispose();
    }
    super.dispose();
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            // Grid de Pericias
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: GridView.builder(
                  //; configurações de grid
                  //; para deixar mais proximo de uma ficha 2 colunas de pericias
                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // Define o número de colunas
                    crossAxisSpacing: 8,  // Espaço horizontal entre os itens
                    mainAxisSpacing: 1.0,  // Espaço vertical entre os itens
                    childAspectRatio: 2.5,
                                
                    
                  ),
                                
                  itemCount: ListaPercias.length,
                  itemBuilder: (context, index){
                    Pericia pericia = Pericia();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                
                      child: GestureDetector(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            
                            ListaPercias[index]["escopo"] != null
                              ? Text("${ListaPercias[index]["nome"]}: (${ListaPercias[index]["escopo"]})")
                              : Text(ListaPercias[index]["nome"]),
                            const SizedBox(height: 1),
                            SizedBox(
                              width: 150,
                              height: 100,
                              child: Row(
                                children: [
                              
                                  SizedBox(
                                    width: 50,
                                    // para evitar carregamentos asincronos
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
                                        if(int.tryParse(value) != null){
                                          personagem.pericias.ListaPercias[index]["valor"] = int.parse(value),
                                        },                                
                                        setState(() {
                                          custoTotal = personagem.pericias.calculaTotal();
                                        }),
                                      }
                                    ) : const SizedBox(),
                                  ),
                              
                                  const SizedBox(width: 10),
                                  // o metodo init pode não carregar a tempo da chamda de bonusTotal
                                  // para evitar problemas refiz a chamada
                                  pericia.init(ListaPercias[index])
                                    ? Text("Total: ${pericia.bonusTotal()}") 
                                    : const Text("Total: "), 
                                ],
                              ),
                            ),
                          ],
                        ),

                        onDoubleTap: () async {
                          //? efetua o loading novament para alteração de nomes
                          if(["PericiaAdiciona", "PericiaAddAcerto"].contains(ListaPercias[index]["classe"])){
                            Map mapPericiaReturn;
                            mapPericiaReturn = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PopUpAddSkill(obj: ListaPercias[index]))
                            );
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
                                  ListaPercias[index] = mntPericia.returnObj();
                                });
                              }else if(mapPericiaReturn["remove"] == true){ // caso remove venha true é um pedido de remoção
                                // Atualiza as Lista de perícias  
                                setState(() {
                                  personagem.pericias.ListaPercias.removeAt(index);
                                  _updateTextInputList();
                                  ListaPercias = personagem.pericias.ListaPercias;
                                });
            
                              }
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
        ),

      //# Botão de Adicionar novas Perícias
      floatingActionButton: FloatingActionButton(
          tooltip: 'Adicionar Poder',
          child: const Icon(Icons.add),
          // Ação e PopUP
          onPressed: () async => {
            mapPericiaReturn = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PopUpAddSkill(obj: {}))
            ),

            // anexa a lista
            mapPericiaReturn.isNotEmpty ?
            setState((){
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

              // Atualiza as Lista de perícias  
              personagem.pericias.ListaPercias.add(periAddicional.returnObj());
              _updateTextInputList();
              ListaPercias = personagem.pericias.ListaPercias;
            }) : null,
          },
        ),
    );
  }
}



