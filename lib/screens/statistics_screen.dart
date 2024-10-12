import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_project/utils/app_colors.dart';
import 'package:flutter_project/models/icon.dart';
import 'package:flutter_project/screens/home_screen.dart';
import 'package:flutter_project/services/database_service.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  _StatisticScreenState createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  Map<String, Map<String, dynamic>> _categoryExpenseData = {};
  final year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _fetchStatistikData();
  }

  Future<void> _fetchStatistikData() async {
    final categoryExpenceData = await DatabaseHelper.instance
        .getCategoryExpenseDistributionForYearAllValues(year);

    setState(() {
      _categoryExpenseData = categoryExpenceData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onPrimaryColor,
            size: 30,
          ),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        title: const Text(
          'Statistic',
          style: TextStyle(
            fontSize: AppFonds.appBar,
            fontWeight: FontWeight.bold,
            color: AppColors.onPrimaryColor,
          ),
        ),
        centerTitle: true,
        elevation: 2,
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
                _buildCategoryPieChart(),
                const SizedBox(height: 20),
                Expanded(
                    child: SingleChildScrollView(
                        child: _buildExpenseList(_categoryExpenseData))),
              ],
            ),
          ),
        ],
      ),
    );
  }

//TODO: als eigenes Widget auslagern
  // Kategorieausgaben als Tortendiagramm
  Widget _buildCategoryPieChart() {
    return SizedBox(
      height: 250,
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
            Positioned(
              top: 8,
              left: 8,
              child: Text(
                year.toString(),
                style: const TextStyle(
                  fontSize: AppFonds.meduim,
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
                size: 24, color: AppColors.backgroundColorBright)
            : null,
        badgePositionPercentageOffset: percentageCategory > iconThreshold
            ? .50
            : null, // Positioniere das Icon richtig
        radius: 50,
      );
    }).toList();
  }

  // Widget zum Erstellen der Ausgabenliste in Card-Form
  Widget _buildExpenseList(
      Map<String, Map<String, dynamic>> categoryExpenseData) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categoryExpenseData.entries.length,
      itemBuilder: (context, index) {
        final enteryList = categoryExpenseData.entries.toList();
        final entry = enteryList[index];
        final iconPerCategory = entry.key; // Icon als Schlüssel
        final data = entry.value;
        final amountPerCategory = data['totalAmount'];
        final colorPerCategory = data['color'];
        final namePerCategory = data['name'];

        return Card(
          elevation: 4,
          color: Color(int.parse(colorPerCategory ?? '0xFFEEEEEE')),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(CategorieIcons.toIconData(iconPerCategory),
                        size: AppFonds.meduim, color: AppColors.backgroundColorBright),
                    const SizedBox(width: 8),
                    Text(
                      namePerCategory,
                      style: const TextStyle(
                        fontSize: AppFonds.meduim,
                        color: AppColors.backgroundColorBright,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${amountPerCategory?.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: AppFonds.meduim,
                        fontWeight: FontWeight.bold,
                        color:AppColors.backgroundColorBright,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
