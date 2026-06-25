import 'package:categoriseit_fe/core/theme/app_colors.dart';
import 'package:categoriseit_fe/domain/models/budget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'budget_form.dart';

class AddBudgetScreen extends StatelessWidget {
  final Budget? budget;
  const AddBudgetScreen({super.key, this.budget});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    budget != null ? 'Edit budget' : 'Add budget',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: BudgetForm(
                  existingBudget: budget,
                  onCompleted: () => context.pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}