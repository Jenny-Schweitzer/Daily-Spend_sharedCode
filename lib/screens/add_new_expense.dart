import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/utils/app_colors.dart';
import 'package:flutter_project/models/expenses.dart';
import 'package:flutter_project/models/icon.dart';
import 'package:flutter_project/screens/add_new_categorie.dart';
import 'package:flutter_project/screens/widgets/month_carusell_widget.dart';
import 'package:flutter_project/services/database_service.dart';
import 'package:flutter_project/models/category.dart';

class NewExpenseScreen extends StatefulWidget {
  const NewExpenseScreen({super.key});

  @override
  _NewExpenseScreenState createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  Category? _selectedCategory;
  int _selectedMonthIndex = DateTime.now().month - 1;
  double _amount = 0.0;
  Future<List<Category>> _fetchCategories() async {
    final categoriesMap = await DatabaseHelper.instance.getAllCategories();
    return categoriesMap.map((map) => Category.fromMap(map)).toList();
  }

  //erlaubt nur Ausgaben in gleichen Jahr, oder Ausgaben für Dezember im Januar
  bool _isValidYear(String year, int monthIndex) {
    final int? parsedYear = int.tryParse(year);
    final int currentYear = DateTime.now().year;
    final int currentMonthIndex = DateTime.now().month - 1;
    if (parsedYear != null &&
        year.length == 4 &&
        (parsedYear == currentYear ||
            (currentMonthIndex == 0 &&
                monthIndex == 11 &&
                parsedYear == currentYear - 1))) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _addNewExpense() async {
    final name = _nameController.text;
    final String yearText = _yearController.text;
    if (_selectedCategory == null ||
        name.isEmpty ||
        _amount == 0 ||
        !_isValidYear(yearText, _selectedMonthIndex)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter valide values")),
      );
      return;
    }
    // Prepare data for the database
    final int? categoryId = _selectedCategory!.id;
    final int? year = int.tryParse(yearText);
    final int month = _selectedMonthIndex + 1;
    Expenses newExpense = Expenses(
        name: name,
        amount: _amount,
        categoryId: categoryId,
        month: month,
        year: year);

    await DatabaseHelper.instance.insertExpenses(newExpense.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Expense added successfully")),
    );

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _yearController.text = DateTime.now().year.toString();
  }

  void _showCategoryPicker() async {
    final categories = await _fetchCategories();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: categories.length + 1, // +1 for the add-button
            itemBuilder: (context, index) {
              if (index == categories.length) {
                // Display the add-button as the last tile
                return GestureDetector(
                  onTap: () async {
                    // Navigate to AddCategoryScreen
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddCategoryScreen()),
                    );
                    Navigator.pop(context); // Close the bottom sheet
                    _showCategoryPicker(); // Re-open the bottom sheet with the updated categories
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Center(
                          child: Icon(Icons.add, size: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text('Add'),
                    ],
                  ),
                );
              } else {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: Center(
                          child: Icon(
                              CategorieIcons.toIconData(
                                  category.icon ?? 'Icons.question_mark'),
                              size: 40,
                              color: Color(
                                  int.parse(category.color ?? '0xFFFFFFFF'))),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(category.name ?? 'undefined'),
                    ],
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Expense',
          style: TextStyle(
            fontSize: AppFonds.appBar,
            fontWeight: FontWeight.bold,
            color: AppColors.onPrimaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onPrimaryColor,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 4,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode
                        .darken), // Leichte Abdunklung für bessere Lesbarkeit
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(int.parse(_selectedCategory?.color ??
                        '0xB3516066')), //backgroundColorDark
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _showCategoryPicker,
                        child: Column(
                          children: [
                            Text(_selectedCategory?.name ?? 'Category',
                                style: const TextStyle(
                                    color: AppColors.textColorBright)),
                            const SizedBox(height: 10),
                            Icon(
                              CategorieIcons.toIconData(
                                  _selectedCategory?.icon ??
                                      'Icons.question_mark'),
                              color: AppColors.textColorBright,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  'Enter Amount',
                                  style: TextStyle(
                                      color: AppColors.textColorDark,
                                      fontSize: AppFonds.meduim),
                                ),
                                content: TextField(
                                  style: const TextStyle(
                                    fontSize: AppFonds.meduim,
                                    color: AppColors.textColorDark,
                                  ),
                                  controller: _amountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  cursorColor: AppColors.primaryColor,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: 'Amount in €',
                                    hintStyle: TextStyle(
                                        color: AppColors.textColorDark50),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _amount = double.tryParse(
                                                _amountController.text) ??
                                            0.0;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: AppFonds.buttonNormal),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Column(
                          children: [
                            const Text(
                              'Amount',
                              style:
                                  TextStyle(color: AppColors.textColorBright),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$_amount €',
                              style: const TextStyle(
                                color: AppColors.textColorBright,
                                fontSize: AppFonds.big,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(
                    fontSize: AppFonds.meduim,
                    color: AppColors.textColorBright70,
                  ),
                  controller: _nameController,
                  cursorColor: AppColors.primaryColor,
                  decoration: const InputDecoration(
                    fillColor: AppColors.backgroundColorDark,
                    filled: true,
                    labelText: 'Expense Name',
                    labelStyle: TextStyle(color: AppColors.textColorBright70),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      // Rand im nicht fokussierten Zustand
                      borderSide: BorderSide(
                        color: AppColors
                            .backgroundColorDark, // Randfarbe ohne Fokus
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 20),
                // Horizontal month carousel
                const Text('Expense Month:',
                    style: TextStyle(
                        color: AppColors.textColorBright70,
                        fontSize: AppFonds.meduim)),
                const SizedBox(height: 10),
                MonthCarouselWidget(
                  selectedMonthIndex: _selectedMonthIndex,
                  onMonthChanged: (newIndex) {
                    setState(() {
                      _selectedMonthIndex = newIndex;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(
                    fontSize: AppFonds.meduim,
                    color: AppColors.textColorBright70,
                  ),
                  controller: _yearController,
                  cursorColor: AppColors.primaryColor,
                  decoration: const InputDecoration(
                    fillColor: AppColors.backgroundColorDark,
                    filled: true,
                    labelText: 'Expense Year',
                    labelStyle: TextStyle(color: AppColors.textColorBright70),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.backgroundColorDark,
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    onPressed: _addNewExpense,
                    child: const Text(
                      'Add New Expense',
                      style: TextStyle(
                          fontSize: AppFonds.buttonNormal,
                          color: AppColors.onPrimaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
