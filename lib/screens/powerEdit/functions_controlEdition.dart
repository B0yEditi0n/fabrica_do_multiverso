import 'package:fabrica_do_multiverso/script/poderes/lib_efeitos.dart';

// Function para auxiliar a manipulação da Tela
int alteraAcao(int valorAtual, int passo){
  // passo pode ser positivo ou negativo
  int acaoID = poder.returnObjDefault()["acao"];
  List editID = <int>[];
  int index = -1;

  // Opções de Edião
  switch(acaoID){
    case 0:
      editID = [1, 2, 3];
    case 1:
      editID = [1, 4];
      break;
    case 2:
      editID = [1, 2];
      break;
    case 3 || 4:
      editID = [1, 2, 3, 4];
      break;
  }
  
  // Determina a posição do valor Atual
  index = editID.indexWhere((id) => id == valorAtual);
  // Progride em um passo
  if(index + passo < editID.length && (index + passo) >= 0){
    return editID[index + passo];
  }

  return valorAtual;
}

int alteraDuracao(int valorAtual, int passo){
  // passo pode ser positivo ou negativo
  int duracaoID = poder.returnObjDefault()["duracao"];
  List editID = <int>[];
  int index = -1;

  // Opções de Edião
  switch(duracaoID){
    case 1 || 2: 
      editID = [1, 2];
      break;
    case 0 || 3 || 4:
      editID = [0, 2, 3, 4];
      break;
  }
  
  
  

  // Determina a posição do valor Atual
  index = editID.indexWhere((id) => id == valorAtual);
  print(index + passo < editID.length && (index + passo) >= 0);
  // Progride em um passo
  if(index + passo < editID.length && (index + passo) >= 0){
    print(editID[index + passo]);
    return editID[index + passo];
  }

  return valorAtual;

}

int alteraAlcance(int valorAtual, int passo){
  // passo pode ser positivo ou negativo
  int alcanceID = poder.returnObjDefault()["alcance"];
  List editID = <int>[];
  int index = -1;

  // Opções de Edião
  switch(alcanceID){
    case 1 || 2 || 3:
      editID = [1, 2, 3];
      break;
  }

  // Determina a posição do valor Atual
  index = editID.indexWhere((id) => id == valorAtual);
  // Progride em um passo
  if(index + passo < editID.length && (index + passo) >= 0){
    return editID[index + passo];
  }

  return valorAtual;

}