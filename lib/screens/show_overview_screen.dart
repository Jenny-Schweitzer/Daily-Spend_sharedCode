import 'package:flutter/material.dart';
import 'package:flutter_project/utils/app_colors.dart';
import 'package:flutter_project/models/icon.dart';
import 'package:flutter_project/screens/add_new_expense.dart';
import 'package:flutter_project/screens/edit_saving_goal.dart';
import 'package:flutter_project/screens/statistics_screen.dart';
import 'package:flutter_project/services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  // Monatsbasis Optionen für das Dropdown-Menü
  final List<int> _averageOptions = [3, 6, 12, 120];
  int _selectedMonths = 3;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  int _savingGoal = 0;
  double _expenseAverage = 0.0;
  double _savings = 0.0;
  Map<String, Map<String, dynamic>> _categoryExpenseData = {};

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
    _getSavingGoal();
  }

  Future<void> _getSavingGoal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savingGoal = prefs.getInt('savingGoal');
    _savingGoal = savingGoal!;
  }

  // Methode, um die Einnahmen, Ausgaben und Kategorie-Daten zu laden
  Future<void> _fetchFinancialData() async {
    final incomeData =
        await DatabaseHelper.instance.getTotalIncomeForCurrentYearTilToday();
    final expenseData = await DatabaseHelper.instance
        .getTotalExpenseForYear(DateTime.now().year);
    final categoryData = await DatabaseHelper.instance
        .getCategoryExpenseDistributionForYearAllValues(DateTime.now().year);
    _fetchAverageData();

    setState(() {
      _totalIncome = incomeData;
      _totalExpense = expenseData;
      _categoryExpenseData = categoryData;
      _savings = _totalIncome - _totalExpense;
    });
  }

  Future<void> _fetchAverageData() async {
    final expenseDataAverage =
        await DatabaseHelper.instance.getAverageExpense(_selectedMonths);

    setState(() {
      _expenseAverage = expenseDataAverage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'Overview',
          style: TextStyle(
            fontSize: AppFonds.appBar,
            fontWeight: FontWeight.bold,
            color: AppColors.onPrimaryColor,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondaryColor,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewExpenseScreen()),
          );
          _fetchFinancialData();
        },
        child: const Icon(
          Symbols.euro,
          color: AppColors.onSecondaryColor,
        ),
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
                _buildIncomeExpenseSummary(),
                const SizedBox(height: 20),
                _buildSavingsProgressBar(),
                const SizedBox(height: 20),
                _buildCategoryPieChart(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Einkommen, Ausgaben und Monatsdurchschnitt Widget
  Widget _buildIncomeExpenseSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Balance: ${(_savings).toStringAsFixed(2)} €',
              style: const TextStyle(
                  fontSize: AppFonds.big,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColorDark),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Average Expenses:',
                  style: TextStyle(
                      fontSize: AppFonds.meduim,
                      color: AppColors.textColorDark),
                ),
                Text('${_expenseAverage.toStringAsFixed(2)} €'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Months:',
                  style: TextStyle(
                      fontSize: AppFonds.meduim,
                      color: AppColors.textColorDark),
                ),
                DropdownButton<int>(
                  value: _selectedMonths,
                  items: _averageOptions
                      .map((months) => DropdownMenuItem<int>(
                            value: months,
                            child: Text(
                                months == 120 ? 'All Time' : '$months Months',
                                style: const TextStyle(
                                    fontSize: AppFonds.meduim,
                                    color: AppColors.textColorDark)),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedMonths = newValue ?? 3;
                      _fetchAverageData();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Sparziel Progressbar
  Widget _buildSavingsProgressBar() {
    double savingProgress = 0.0;

    if (_savings > 0.0 && _savingGoal > 0) {
      savingProgress = _savings / _savingGoal;
    }
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditSavingGoal()),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Savings Goal Progress:',
                    style: TextStyle(
                        fontSize: AppFonds.meduim,
                        color: AppColors.textColorDark),
                  ),
                  const SizedBox(height: 10),
                  LinearPercentIndicator(
                    lineHeight: 30.0,
                    percent: savingProgress.clamp(0,
                        1), // Sicherstellen, dass der Wert zwischen 0 und 1 bleibt
                    backgroundColor: AppColors.backgroundForColorAccent,
                    progressColor: AppColors.accentColor,
                  ),
                  const SizedBox(height: 5),
                  Text(
                      '${(savingProgress * 100).toStringAsFixed(1)}% of your goal reached',
                      style: const TextStyle(
                          fontSize: AppFonds.smal,
                          color: AppColors.textColorDark)),
                ],
              ),
            ),
            const Positioned(
              bottom: 8,
              right: 8,
              child: Text(
                'Click to edit your goal',
                style: TextStyle(
                  fontSize: AppFonds.little,
                  color: AppColors.textColorDark50,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //TODO: als eigenes Widget auslagern

  // Kategorieausgaben als Tortendiagramm
  Widget _buildCategoryPieChart() {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StatisticScreen()),
                );
              },
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(),
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const Positioned(
              bottom: 8,
              left: 8,
              child: Text(
                'Click for more infos',
                style: TextStyle(
                  fontSize: AppFonds.little,
                  color: AppColors.textColorDark50,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Methode zum Erstellen der Tortendiagramm-Sektionen
  List<PieChartSectionData> _buildPieChartSections() {
    const double iconThreshold =
        5.0; // Schwellenwert (%) ab wo kein Icon mehr angeziegt wird
    final double totalAmountPerYear = _categoryExpenseData.values
        .fold(0.0, (sum, entry) => sum + (entry['totalAmount'] ?? 0.0));

    return _categoryExpenseData.entries.map((entry) {
      final icon = entry.key; // Icon als Schlüssel
      final data = entry.value; // Map mit 'totalAmount', 'color' und 'name'
      final amountPerCategory = data['totalAmount'];

      // Berechne den Prozentsatz der aktuellen Kategorie am Gesamtbetrag
      final percentageCategory = (amountPerCategory / totalAmountPerYear) * 100;

      return PieChartSectionData(
        value: amountPerCategory,
        title: '',
        color: Color(int.parse(data['color'] ?? '0xFFFFFFFF')),
        badgeWidget: percentageCategory > iconThreshold
            ? Icon(CategorieIcons.toIconData(icon),
                size: AppFonds.big, color: AppColors.secondaryColor)
            : null,
        badgePositionPercentageOffset: percentageCategory > iconThreshold
            ? .50 // Positioniere das Icon in der Mitte
            : null,
        radius: 50,
      );
    }).toList();
  }
}
