import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/utils/app_colors.dart';
import 'package:flutter_project/models/income.dart';
import 'package:flutter_project/screens/widgets/month_carusell_widget.dart';
import 'package:flutter_project/services/database_service.dart';

class NewIncomeScreen extends StatefulWidget {
  const NewIncomeScreen({super.key});

  @override
  _NewIncomeScreenState createState() => _NewIncomeScreenState();
}

class _NewIncomeScreenState extends State<NewIncomeScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  int _selectedMonthIndex = DateTime.now().month - 1;

  @override
  void initState() {
    super.initState();
    // Set the current year as default
    _yearController.text = DateTime.now().year.toString();
  }

  // Validate the input for the year (ensure it's in 'YYYY' format)
  bool _isValidYear(String year) {
    final int? parsedYear = int.tryParse(year);
    final int currentYear = DateTime.now().year;
    return parsedYear != null &&
        year.length == 4 &&
        parsedYear >= currentYear &&
        parsedYear <= currentYear + 1;
  }

  // Save income to the database
  Future<void> _setNewIncome() async {
    final String amountText = _amountController.text;
    final String yearText = _yearController.text;
    // Validate inputs
    if (amountText.isEmpty || !_isValidYear(yearText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid values")),
      );
      return;
    }
    // Prepare data for the database
    final double? amount = double.tryParse(amountText);
    final int? year = int.tryParse(yearText);
    if (amount != null && year != null) {
      Income newIncome = Income(
          amount: amount, startMonth: _selectedMonthIndex + 1, startYear: year);
      await DatabaseHelper.instance.insertIncome(newIncome.toMap());
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Income updated successfully")),
      );
      Navigator.pop(context); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Income',
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
          onPressed: () {
            Navigator.pop(context);
          },
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
                const Text(
                  'If your income has changed, it will be updated here for the selected month.',
                  style: TextStyle(
                      fontSize: AppFonds.meduim,
                      color: AppColors.onPrimaryColor),
                ),
                const SizedBox(height: 20),

                TextField(
                  style: const TextStyle(
                    fontSize: AppFonds.meduim,
                    color: AppColors.textColorBright70,
                  ),
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  cursorColor: AppColors.primaryColor,
                  decoration: const InputDecoration(
                    fillColor: AppColors.backgroundColorDark,
                    filled: true,
                    labelText: 'Amount',
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
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
                const SizedBox(height: 20),

                TextField(
                  style: const TextStyle(
                    fontSize: AppFonds.meduim,
                    color: AppColors.textColorBright70,
                  ),
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  cursorColor: AppColors.primaryColor,
                  decoration: const InputDecoration(
                    fillColor: AppColors.backgroundColorDark,
                    filled: true,
                    labelText: 'Year',
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
                const SizedBox(height: 20),
                // Horizontal month carousel widget
                const Text('Select Month:'),
                const SizedBox(height: 10),
                MonthCarouselWidget(
                  selectedMonthIndex: _selectedMonthIndex,
                  onMonthChanged: (newIndex) {
                    setState(() {
                      _selectedMonthIndex = newIndex;
                    });
                  },
                ),
                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _setNewIncome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text(
                      'Set New Income',
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
