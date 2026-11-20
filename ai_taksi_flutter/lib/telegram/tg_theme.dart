import 'package:flutter/material.dart';

/// Telegram-inspired visual grammar, but independent AI Taksi branding.
/// Deliberately simple surfaces and line icons instead of neon/glass overload.
class TgColors {
  static const blue=Color(0xFF3390EC);
  static const cyan=Color(0xFF59C7EE);
  static const navy=Color(0xFF132334);
  static const cloud=Color(0xFFF1F3F6);
  static const darkCanvas=Color(0xFF0E1621);
  static const darkSurface=Color(0xFF17212B);
  static const darkSecondary=Color(0xFF242F3D);
  static const divider=Color(0xFFE8EAEF);
  static const green=Color(0xFF39A96B);
}

ThemeData tgTheme({bool dark=false}) {
  final base=ThemeData(brightness:dark?Brightness.dark:Brightness.light,useMaterial3:true);
  final surface=dark?TgColors.darkSurface:Colors.white;
  final canvas=dark?TgColors.darkCanvas:TgColors.cloud;
  final text=dark?const Color(0xFFF3F6FA):const Color(0xFF132337);
  final scheme=ColorScheme.fromSeed(seedColor:TgColors.blue,
      brightness:dark?Brightness.dark:Brightness.light).copyWith(
      primary:dark?const Color(0xFF67B5FB):TgColors.blue,
      surface:surface, onSurface:text);
  return base.copyWith(
    colorScheme:scheme,scaffoldBackgroundColor:canvas,
    appBarTheme:AppBarTheme(backgroundColor:surface,foregroundColor:text,
      surfaceTintColor:Colors.transparent,centerTitle:false,elevation:0,
      titleTextStyle:TextStyle(fontFamily:'Roboto',fontSize:20,fontWeight:FontWeight.w700,color:text,letterSpacing:-.3)),
    dividerTheme:DividerThemeData(color:dark?const Color(0xFF273746):TgColors.divider,
      space:1,thickness:1),
    cardTheme:CardThemeData(color:surface,surfaceTintColor:Colors.transparent,
      elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15))),
    inputDecorationTheme:InputDecorationTheme(
      filled:true,fillColor:dark?TgColors.darkSecondary:const Color(0xFFF0F2F5),
      contentPadding:const EdgeInsets.symmetric(horizontal:15,vertical:12),
      border:OutlineInputBorder(borderSide:BorderSide.none,borderRadius:BorderRadius.circular(13)),
      enabledBorder:OutlineInputBorder(borderSide:BorderSide.none,borderRadius:BorderRadius.circular(13)),
      focusedBorder:OutlineInputBorder(borderSide:BorderSide(color:scheme.primary,width:1.4),
        borderRadius:BorderRadius.circular(13)),
      hintStyle:TextStyle(color:dark?const Color(0xFF8E9BA9):const Color(0xFF89939E))),
    filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(
      backgroundColor:scheme.primary,foregroundColor:Colors.white,
      minimumSize:const Size(40,50),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(13)),
      textStyle:const TextStyle(fontSize:15,fontWeight:FontWeight.w700))),
    outlinedButtonTheme:OutlinedButtonThemeData(style:OutlinedButton.styleFrom(
      minimumSize:const Size(40,48),side:BorderSide(color:dark?const Color(0xFF3A4C5B):const Color(0xFFE0E6EF)),
      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(13)))),
    listTileTheme:ListTileThemeData(iconColor:scheme.primary,contentPadding:const EdgeInsets.symmetric(horizontal:16)),
    snackBarTheme:SnackBarThemeData(backgroundColor:dark?TgColors.darkSecondary:TgColors.navy,
      contentTextStyle:const TextStyle(color:Colors.white),behavior:SnackBarBehavior.floating,
      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
    switchTheme:SwitchThemeData(thumbColor:WidgetStateProperty.resolveWith((states)=>
      states.contains(WidgetState.selected)?Colors.white:null)),
    bottomSheetTheme:BottomSheetThemeData(backgroundColor:surface,showDragHandle:true,
      shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24)))),
  );
}

extension TgContext on BuildContext {
  bool get isNight=>Theme.of(this).brightness==Brightness.dark;
  Color get pageSurface=>isNight?TgColors.darkSurface:Colors.white;
  Color get pageCanvas=>isNight?TgColors.darkCanvas:TgColors.cloud;
  Color get primaryInk=>isNight?const Color(0xFFF1F5F9):const Color(0xFF132337);
  Color get secondaryInk=>isNight?const Color(0xFFA0ACB9):const Color(0xFF768595);
  Color get quietLine=>isNight?const Color(0xFF283744):TgColors.divider;
  Color get accent=>Theme.of(this).colorScheme.primary;
  Color get softBlue=>isNight?const Color(0xFF233B55):const Color(0xFFE9F3FE);
}
