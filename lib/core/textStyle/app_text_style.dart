import 'package:coffee_shop/core/colors/app_colors.dart';
import 'package:coffee_shop/core/textStyle/app_text_weight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

extension CustomTextSize on Text {
  Text indieFlowerLoginStyleffFDF7F7() {
    return Text(
      data ?? '',
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
          fontSize: 30.sp,
          color: AppColors.ffFDF7F7,
          fontWeight: AppTextWeight.medium,
        ),
      ),
    );
  }

  Text montserratRegularSize20FFFBFB() {
    return Text(
      data ?? '',
      style: GoogleFonts.montserrat(
        textStyle: TextStyle(
          fontSize: 14.sp,
          color: AppColors.ffFFFBFB,
          fontWeight: FontWeight.w400, // Regular font weight
        ),
      ),
    );
  }

  Text poppinsRegularSize14FFFBFB() {
    return Text(
      data ?? '',
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
          fontSize: 14.sp,
          color: AppColors.ffFFFBFB,
          fontWeight: FontWeight.w400, // Regular font weight
        ),
      ),
    );
  }

  Text poppinsMediumSize20FFFFFF() {
    return Text(
      data ?? '',
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
          fontSize: 20.sp,
          color: AppColors.ffFFFFFF,
          fontWeight: FontWeight.w500, // Medium font weight
        ),
      ),
    );
  }

  Text indieFlowerLoginStyleFFFBFB() {
    return Text(
      data ?? '',
      style: GoogleFonts.indieFlower(
        textStyle: TextStyle(
          fontSize: 40.sp,
          color: AppColors.ffFFFBFB,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Text robotoBoldSize20Color1D272F() {
    return Text(
      data ?? '',
      style: GoogleFonts.roboto(
        textStyle: const TextStyle(
          fontSize: 20.0,

          fontWeight: FontWeight.bold, // FontWeight for "Bold"
        ),
      ),
    );
  }

  Text robotoItalicSize14ColorA7A9B7() {
    return Text(
      data ?? '',
      style: GoogleFonts.roboto(
        textStyle: const TextStyle(
          fontSize: 14.0,

          fontStyle: FontStyle.italic, // Italic style
        ),
      ),
    );
  }
}
