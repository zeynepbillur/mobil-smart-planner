import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rashad_frontend/providers/task_provider.dart';
import 'package:rashad_frontend/models/category.dart';
import 'package:rashad_frontend/services/category_service.dart';
import 'package:rashad_frontend/utils/app_colors.dart';

class CategoriesGridWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const CategoriesGridWidget({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = CategoryService.categories;
    final allTasks = context.watch<TaskProvider>().tasks;
    
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryId = category.id;
        
        final categoryTasks = allTasks.where((t) {
          if (t.categoryId == null || t.categoryId!.isEmpty) {
            return categoryId == '1'; // Default category
          }
          return t.categoryId == categoryId;
        }).toList();
        
        final completedTasks =
            categoryTasks.where((t) => t.status == 'completed').length;
        
        return Card(
          elevation: 0,
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () {
              _showCategoryDetail(context, category, categoryTasks);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon ?? Icons.grid_view_rounded,
                      color: category.color,
                      size: 28,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${categoryTasks.length} görev',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (categoryTasks.isNotEmpty)
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: completedTasks / categoryTasks.length,
                          backgroundColor: AppColors.background,
                          color: category.color,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${((completedTasks / categoryTasks.length) * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCategoryDetail(
      BuildContext context, category, List categoryTasks) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon ?? Icons.grid_view_rounded,
                      color: category.color,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (category.description != null)
                          Text(
                            category.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      'Toplam',
                      categoryTasks.length.toString(),
                      Icons.task_alt_rounded,
                    ),
                    _buildStat(
                      'Tamamlanan',
                      categoryTasks
                          .where((t) => t.status == 'completed')
                          .length
                          .toString(),
                      Icons.check_circle_rounded,
                    ),
                    _buildStat(
                      'Bekleyen',
                      categoryTasks
                          .where((t) => t.status == 'pending')
                          .length
                          .toString(),
                      Icons.pending_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
