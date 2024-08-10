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
        brightness: Brightness.dark,
        primarySwatch: purpleSwatch,
        visualDensity: VisualDensity.adaptivePlatformDensity,

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
            fillColor: Colors.white

          ),
          textStyle: TextStyle(
            color: Colors.white
          )
        ),

        // temas de texto
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Color.fromARGB(255, 109, 46, 46),
            fontFamily: 'Impact',
            fontSize: 20,
          ),

          //bodyText2: TextStyle(color: Colors.grey),
        )));
}