import 'package:flutter/material.dart';
import 'package:flutter_project/utils/app_colors.dart';
import 'package:flutter_project/models/income.dart';
import 'package:flutter_project/screens/add_new_income.dart';
import 'package:flutter_project/screens/home_screen.dart';
import 'package:flutter_project/services/database_service.dart';
import 'package:flutter_project/utils/helper.dart';

class OverviewIncomeScreen extends StatefulWidget {
  const OverviewIncomeScreen({super.key});

  @override
  State<OverviewIncomeScreen> createState() => _OverviewIncomeScreenState();
}

class _OverviewIncomeScreenState extends State<OverviewIncomeScreen> {
  late Future<List<Income>> _incomeList;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadIncomeData();
  }

  // Methode, um die Einkommensdaten neu zu laden
  void _loadIncomeData() {
    setState(() {
      _incomeList = _fetchAllIncome();
    });
  }

  // Methode, um alle Einkommen aus der Datenbank zu holen
  Future<List<Income>> _fetchAllIncome() async {
    final incomeData = await DatabaseHelper.instance.getAllIncome();
    return incomeData.map((map) => Income.fromMap(map)).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Warte, bis die AddNewIncome-Seite geschlossen ist, und lade dann die Daten neu
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewIncomeScreen()),
            );
            _loadIncomeData(); // Lade die Einkommensdaten neu, nachdem die Seite geschlossen wurde
          },
          backgroundColor: AppColors.secondaryColor,
          elevation: 8,
          child: const Icon(
            Icons.work_history,
            color: AppColors.onSecondaryColor,
            size: 24,
          ),
        ),
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
            'Income Overview',
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
            SafeArea(
              top: true,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: FutureBuilder<List<Income>>(
                  future: _incomeList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text(
                        '  Currently no income available.  ',
                        style: TextStyle(
                            color: AppColors.textColorDark,
                            backgroundColor: AppColors.backgroundColorBright,
                            fontSize: AppFonds.meduim),
                      ));
                    }

                    final allIncomeList = snapshot.data!;

                    return ListView.builder(
                      itemCount: allIncomeList.length,
                      itemBuilder: (context, index) {
                        final income = allIncomeList[index];

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Income: ${income.amount?.toStringAsFixed(2)} €',
                                  style: const TextStyle(
                                    fontSize: AppFonds.meduim,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColorDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: AppFonds.smal,
                                        color: AppColors.textColorDark50),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Month: ${Helper.monthToString(income.startMonth)}',
                                      style: const TextStyle(
                                        fontSize: AppFonds.smal,
                                        color: AppColors.textColorDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.date_range,
                                        size: AppFonds.smal,
                                        color: AppColors.textColorDark50),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Year: ${income.startYear}',
                                      style: const TextStyle(
                                        fontSize: AppFonds.smal,
                                        color: AppColors.textColorDark,
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
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
