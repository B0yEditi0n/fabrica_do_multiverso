//# Abertura padrão dos popups da ficha
//
// Os popups eram abertos com Navigator.push(MaterialPageRoute), uma rota
// opaca: a tela de baixo deixava de ser desenhada e o popup aparecia sobre
// um fundo vazio. Aqui o popup vira um diálogo (showDialog), com a tela de
// baixo visível atrás de um véu escuro.

import 'dart:math';

import 'package:flutter/material.dart';

// Largura: a tela menos 16 de cada lado, até 560. Altura: até 85% da tela.
BoxConstraints restricoesPopup(Size tela) {
  final double largura = max(0, min(tela.width - 32, 560));
  return BoxConstraints(
    minWidth: largura,
    maxWidth: largura,
    maxHeight: tela.height * 0.85,
  );
}

// Abre o popup centralizado. Tocar fora não fecha (não perde o que foi
// digitado); fecha pelos botões do popup ou pelo voltar do sistema, que
// devolve null.
Future<T?> abrirPopup<T>(BuildContext context, Widget popup) {
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (ctx) {
      // Calculado no builder: acompanha rotação e redimensionamento da janela
      final ThemeData tema = Theme.of(ctx);
      return Theme(
        data: tema.copyWith(
          dialogTheme: tema.dialogTheme.copyWith(
            constraints: restricoesPopup(MediaQuery.sizeOf(ctx)),
          ),
        ),
        child: popup,
      );
    },
  );
}
