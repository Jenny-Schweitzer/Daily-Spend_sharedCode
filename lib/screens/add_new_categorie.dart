import 'package:flutter/material.dart';
import 'package:flutter_project/utils/app_colors.dart';
import 'package:flutter_project/models/icon.dart';
import 'package:flutter_project/services/database_service.dart';
import 'package:flutter_project/models/category.dart';
import 'package:flutter_project/utils/helper.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}
//ToDO: Fehlermeldung abfangen, wenn Kategorie oder Bild bereits vorhenden

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _categoryNameController = TextEditingController();
  IconData? _selectedIcon;

  Future<void> _addCategory() async {
    final categoryName = _categoryNameController.text;
    if (categoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a category name")),
      );
      return;
    }
    if (_selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a icon")),
      );
      return;
    }
    //convert Icon to String
    var selectedIconAsName = CategorieIcons.toName(_selectedIcon);
    //select Category Color
    var selectedColor = Helper.randomColorString();

    // create a new instance of Catgoriy
    Category newCategory = Category(
      name: categoryName,
      icon: selectedIconAsName,
      color: selectedColor,
    );

    // Insert the new category into the database
    await DatabaseHelper.instance.insertCategory(newCategory.toMap());
    if (context.mounted) {
      // Return the new category to the previous screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onPrimaryColor,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 4,
      ),
      // Ensures the content is not resized when the keyboard appears
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(
                fontSize: AppFonds.meduim,
                color: AppColors.onPrimaryColor,
              ),
              controller: _categoryNameController,
              cursorColor: AppColors.primaryColor,
              decoration: const InputDecoration(
                fillColor: AppColors.backgroundColorBright,
                filled: true,
                labelText: 'Category Name',
                labelStyle: TextStyle(color: AppColors.textColorDark),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        AppColors.backgroundColorDark, 
                    width: 1.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select an Icon:',
              style: TextStyle(
                  color: AppColors.textColorDark, fontSize: AppFonds.smal),
            ),
            const SizedBox(height: 10),
            Wrap(
              runSpacing: 25,
              spacing: 25,
              children: CategorieIcons.availableIcons.map((iconData) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconData;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedIcon == iconData
                            ? AppColors.primaryColor
                            : AppColors.backgroundColorBright),
                    child: Icon(
                      iconData,
                      size: 35,
                      color: _selectedIcon == iconData
                          ? AppColors.onPrimaryColor
                          : AppColors.onSecondaryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: const Text(
                  'Add Category',
                  style: TextStyle(
                      fontSize: AppFonds.buttonNormal,
                      color: AppColors.onPrimaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
