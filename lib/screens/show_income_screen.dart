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
  bool editMode = false;
  bool standardSelected = false;
  List<bool> selectedIncome = [];

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
    _incomeList.then((income) {
      setState(() {
        selectedIncome = List<bool>.filled(income.length, false);
      });
    });
  }

  void _deleteIncome() async {
    List<int> incomeIdsToDelete = [];

    for (int index = 0; index < selectedIncome.length; index++) {
      if (selectedIncome[index]) {
        final Income incomeToDelete = (await _incomeList).elementAt(index);
        incomeIdsToDelete.add(incomeToDelete.id!);
      }
    }

    // Lösche die Ausgaben, wenn die Liste nicht leer ist
    if (incomeIdsToDelete.isNotEmpty) {
      await DatabaseHelper.instance.deleteIncome(incomeIdsToDelete);

      // Setze die Auswahl zurück und lade die Ausgaben neu
      setState(() {
        selectedIncome.fillRange(0, selectedIncome.length, false);
        _loadIncomeData();
      });
    }
  }

  void _resetSelection() {
    setState(() {
      selectedIncome.fillRange(
          0, selectedIncome.length, false);
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
          actions: <Widget>[
            if (editMode)
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: AppColors.onPrimaryColor,
                  size: 30,
                ),
                onPressed: () async {
                  _deleteIncome();
                  editMode = false;
                },
              ),
            IconButton(
              icon: const Icon(
                Icons.edit,
                color: AppColors.onPrimaryColor,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  // Togglen des editMode Werts zwischen true und false
                  editMode = !editMode;
                  // setze die Auswahl zurück, wenn man im editMode war
                  _resetSelection();
                });
              },
            )
          ],
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

                        return Row(
                          children: [
                            Expanded(
                              child: Card(
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
                              ),
                            ),
                            if (editMode)
                              Checkbox(
                                value: selectedIncome[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    selectedIncome[index] =
                                        value ?? false;
                                  });
                                },
                              ),
                          ],
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
