import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../data/all_companies_data.dart';
import '../../services/ratings_service.dart';

class RatingScreen extends StatefulWidget {
  final String bookingId;
  final String? companyId;

  const RatingScreen({super.key, required this.bookingId, this.companyId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  String _comment = '';
  String? _selectedCompanyId;
  final Map<String, int> _categoryRatings = {
    'Confort': 0,
    'Propreté': 0,
    'Ponctualité': 0,
    'Service': 0,
  };

  @override
  void initState() {
    super.initState();
    _selectedCompanyId = widget.companyId;
  }

  @override
  Widget build(BuildContext context) {
    final companies = AllCompaniesData.getAllCompanies();

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        title: Text('Laisser un avis', style: AppTextStyles.h4),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Compagnie', style: AppTextStyles.bodyLarge),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCompanyId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Choisir une compagnie',
                        ),
                        items: companies
                            .map((company) => DropdownMenuItem(
                                  value: company.id,
                                  child: Text(company.name),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCompanyId = value),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Votre note', style: AppTextStyles.bodyLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          return IconButton(
                            onPressed: () =>
                                setState(() => _rating = starValue),
                            icon: Icon(
                              _rating >= starValue
                                  ? Icons.star
                                  : Icons.star_border,
                              color: AppColors.star,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Notes par catégorie',
                          style: AppTextStyles.bodyLarge),
                      const SizedBox(height: AppSpacing.sm),
                      ..._categoryRatings.entries.map((entry) =>
                          _buildCategoryRating(entry.key, entry.value)),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Commentaire', style: AppTextStyles.bodyLarge),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText:
                              'Dites-nous ce que vous avez pensé du trajet...',
                        ),
                        onChanged: (value) => _comment = value,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _rating == 0 || _selectedCompanyId == null
                      ? null
                      : () async {
                          await RatingsService.addRating(
                            companyId: _selectedCompanyId!,
                            tripId: widget.bookingId,
                            rating: _rating,
                            comment: _comment,
                            categories: _categoryRatings,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Merci pour votre avis.')),
                          );
                          Navigator.pop(context);
                        },
                  child: const Text('Envoyer mon avis'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRating(String category, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category, style: AppTextStyles.bodyMedium),
          Row(
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return IconButton(
                onPressed: () =>
                    setState(() => _categoryRatings[category] = starValue),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  value >= starValue ? Icons.star : Icons.star_border,
                  color: AppColors.star,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
