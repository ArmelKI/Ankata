import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/company_logo_service.dart';

class CompanyLogoParams {
  final String companyName;
  final double width;
  final double height;
  final String? logoUrl;

  const CompanyLogoParams({
    required this.companyName,
    required this.width,
    required this.height,
    this.logoUrl,
  });
}

final companyLogoProvider =
    Provider.family<Widget, CompanyLogoParams>((ref, params) {
  if (params.logoUrl != null && params.logoUrl!.isNotEmpty) {
    return CompanyLogoService.getCompanyLogoFromUrl(
      logoUrl: params.logoUrl,
      companyName: params.companyName,
      width: params.width,
      height: params.height,
    );
  }

  return CompanyLogoService.getCompanyLogo(
    companyName: params.companyName,
    width: params.width,
    height: params.height,
  );
});

final companyColorProvider = Provider.family<Color, String>((ref, companyName) {
  return CompanyColors.getCompanyColor(companyName);
});
