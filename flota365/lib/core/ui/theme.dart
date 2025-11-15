import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryBlue,
    onPrimary: AppColors.textBlack,
    secondary: AppColors.secondaryYellow,
    onSecondary: AppColors.textBlack,
    error: AppColors.secondaryRed1,
    onError: AppColors.textWhite,
    background: AppColors.primaryWhite,
    onBackground: AppColors.textBlack,
    surface: AppColors.primaryWhite,
    onSurface: AppColors.textBlack,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.background,
    primaryColor: colorScheme.primary,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
 
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryWhite,
      foregroundColor: AppColors.textBlack,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        color: AppColors.textBlack,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    ),

    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textBlack,
        disabledBackgroundColor: AppColors.gray1,
        disabledForegroundColor: AppColors.gray2,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textBlack,
        side: const BorderSide(color: AppColors.gray2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    ),

   
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gray1.withOpacity(.35),

      
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),

      // Labels y hints
      hintStyle: const TextStyle(
        color: AppColors.gray2,
      ),
      labelStyle: const TextStyle(
        color: AppColors.gray2,
      ),

      // Iconos
      prefixIconColor: AppColors.textBlack,
      suffixIconColor: AppColors.textBlack,
    ),

    // -------------------------
    // CHIP
    // -------------------------
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.secondaryYellow3,
      selectedColor: AppColors.secondaryGreen1,
      disabledColor: AppColors.gray1,
      labelStyle: const TextStyle(color: AppColors.textBlack),
    ),

   
    textTheme: const TextTheme(
      bodyMedium: TextStyle(                       
        color: AppColors.textBlack,
        fontSize: 16,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColors.gray2,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: AppColors.textBlack,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: AppColors.textBlack,
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textBlack,
      ),
    ),

  
    dividerColor: AppColors.gray1,
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: AppColors.primaryBlue),

  
    switchTheme: SwitchThemeData(
      thumbIcon: MaterialStateProperty.resolveWith<Icon?>((states) {
        return states.contains(MaterialState.selected)
            ? const Icon(Icons.check)
            : const Icon(Icons.close);
      }),
      thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {
        return states.contains(MaterialState.selected)
            ? AppColors.secondaryGreen1
            : AppColors.gray2;
      }),
      trackColor: const MaterialStatePropertyAll<Color>(AppColors.gray1),
    ),
  );
}
