import 'package:flutter/material.dart';

const int _purplePrimaryValue = 0xFF9C27B0;
const MaterialColor purpleSwatch = MaterialColor(
  _purplePrimaryValue,
  <int, Color>{
    50: Color(0xFFF3E5F5),
    100: Color(0xFFE1BEE7),
    200: Color(0xFFCE93D8),
    300: Color(0xFFBA68C8),
    400: Color(0xFFAB47BC),
    500: Color(_purplePrimaryValue),
    600: Color(0xFF8E24AA),
    700: Color(0xFF7B1FA2),
    800: Color(0xFF6A1B9A),
    900: Color(0xFF4A148C),
  },
);

ThemeData temaPadrao(){
  return (ThemeData(
        fontFamily: 'Roboto',
        primaryColorLight: const Color.fromARGB(255, 89, 15, 216),
        primaryColorDark: const Color.fromARGB(255, 152, 97, 248),
        brightness: Brightness.dark,
        primarySwatch: purpleSwatch,
        secondaryHeaderColor: const Color.fromARGB(255, 53, 53, 53),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Área de toque mínima de 48px em qualquer plataforma
        materialTapTargetSize: MaterialTapTargetSize.padded,

        // Botões maiores para uso com o dedo (texto centralizado por padrão)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            minimumSize: const Size(120, 52),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(160, 56),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            minimumSize: const Size(52, 52),
            iconSize: 28,
          ),
        ),
        // Diálogos usam quase toda a largura em celulares (padrão: 40 de margem)
        dialogTheme: const DialogThemeData(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          sizeConstraints: BoxConstraints.tightFor(width: 64, height: 64),
          iconSize: 30,
        ),

        drawerTheme: const DrawerThemeData(          
          //box: Color.fromARGB(255, 89, 15, 216),
          //backgroundColor: 
          surfaceTintColor: Color.fromARGB(255, 89, 15, 216),
        ),

        dropdownMenuTheme: const DropdownMenuThemeData(
          //inputDecorationTheme:
          menuStyle: MenuStyle(
//            backgroundColor: Color.fromARGB(255, 89, 15, 216),
            //surfaceTintColor: purpleSwatch,
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.white,
          ),
          textStyle: TextStyle(
            color: Colors.white
          )
        ),

        // temas de texto
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(8),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Color.fromARGB(255, 109, 46, 46),
            fontFamily: 'Impact',
            fontSize: 20,
          ),

          //bodyText2: TextStyle(color: Colors.grey),
        ),

      ));
}