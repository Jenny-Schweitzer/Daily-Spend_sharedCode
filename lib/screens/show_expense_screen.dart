import 'package:flutter/material.dart';
import 'package:flutter_project/utils/app_colors.dart';
import 'package:flutter_project/models/category.dart';
import 'package:flutter_project/models/expenses.dart';
import 'package:flutter_project/models/icon.dart';
import 'package:flutter_project/screens/add_new_expense.dart';
import 'package:flutter_project/screens/home_screen.dart';
import 'package:flutter_project/services/database_service.dart';
import 'package:flutter_project/utils/helper.dart';
import 'package:material_symbols_icons/symbols.dart';

class OverviewExpenseScreen extends StatefulWidget {
  const OverviewExpenseScreen({super.key});

  @override
  State<OverviewExpenseScreen> createState() => _OverviewExpenseScreenState();
}

class _OverviewExpenseScreenState extends State<OverviewExpenseScreen> {
  late Future<List<Expenses>> _expenseList;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool editMode = false;
  bool standardSelected = false;
  List<bool> selectedExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenseData();
  }

  // Methode, um die Ausgabendaten neu zu laden
  void _loadExpenseData() {
    setState(() {
      _expenseList = _fetchAllExpenses();
    });
    _expenseList.then((expenses) {
      setState(() {
        selectedExpenses = List<bool>.filled(expenses.length, false);
      });
    });
  }

  void _deleteExpense() async {
    List<int> expenseIdsToDelete = [];

    // Sammle die IDs der markierten Ausgaben
    for (int index = 0; index < selectedExpenses.length; index++) {
      if (selectedExpenses[index]) {
        final Expenses expenseToDelete = (await _expenseList).elementAt(index);
        expenseIdsToDelete.add(expenseToDelete.id!);
      }
    }

    if (expenseIdsToDelete.isNotEmpty) {
      await DatabaseHelper.instance.deleteExpenses(expenseIdsToDelete);

      setState(() {
        selectedExpenses.fillRange(0, selectedExpenses.length, false);
        _loadExpenseData();
      });
    }
  }

  void _resetSelection() {
    setState(() {
      selectedExpenses.fillRange(
          0, selectedExpenses.length, false); // Alle Auswahl zurücksetzen
    });
  }

  // Methode, um alle Einkommen aus der Datenbank zu holen
  Future<List<Expenses>> _fetchAllExpenses() async {
    final expenseData = await DatabaseHelper.instance.getAllExpenses();
    return expenseData.map((map) => Expenses.fromMap(map)).toList();
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
          backgroundColor: AppColors.secondaryColor,
          onPressed: () async {
            // Warte, bis die AddNewExpense-Seite geschlossen ist, und lade dann die Daten neu
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewExpenseScreen()),
            );
            _loadExpenseData(); // Lade die Ausgabendaten neu, nachdem die Seite geschlossen wurde
          },
          elevation: 8,
          child: const Icon(
            Symbols.euro,
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
            'Expense Overview',
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
                  _deleteExpense();
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
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: FutureBuilder<List<Expenses>>(
                  future: _expenseList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text(
                        '  Currently no expenses available.  ',
                        style: TextStyle(
                            color: AppColors.textColorDark,
                            backgroundColor: AppColors.backgroundColorBright,
                            fontSize: AppFonds.meduim),
                      ));
                    }

                    final allExpensesList = snapshot.data!;

                    return ListView.builder(
                      itemCount: allExpensesList.length,
                      itemBuilder: (context, index) {
                        final expense = allExpensesList[index];

                        //FutureBuilder, um die Kategorie-Daten asynchron zu laden
                        return FutureBuilder<Map<String, dynamic>?>(
                          future: DatabaseHelper.instance
                              .getCategoryById(expense.categoryId ?? 0),
                          builder: (context, categorySnapshot) {
                            if (categorySnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (categorySnapshot.hasError) {
                              return Text('Fehler: ${categorySnapshot.error}');
                            } else if (!categorySnapshot.hasData ||
                                categorySnapshot.data == null) {
                              return const Text('Kategorie nicht gefunden');
                            }

                            //Kategorie-Daten aus dem Snapshot extrahieren
                            final categoryData =
                                Category.fromMap(categorySnapshot.data!);

                            return Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    elevation: 4,
                                    color: Color(int.parse(
                                        categoryData.color ?? '0xFFEEEEEE')),
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
                                              Text(
                                                '${expense.name}',
                                                style: const TextStyle(
                                                  fontSize: AppFonds.meduim,
                                            color: AppColors.textColorBright,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                '${expense.amount?.toStringAsFixed(2)} €',
                                                style: const TextStyle(
                                                    fontSize: AppFonds.meduim,
                                                    fontWeight: FontWeight.bold,
                                              color: AppColors.textColorBright),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                  CategorieIcons.toIconData(
                                                      categoryData.icon ??
                                                          'Icons.question_mark'),
                                                  size: AppFonds.smal,
                                            color: AppColors.textColorBright70),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Category: ${categoryData.name}',
                                                style: const TextStyle(
                                                  fontSize: AppFonds.smal,
                                            color: AppColors.textColorBright,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  size: AppFonds.smal,
                                            color: AppColors.textColorBright70),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Month: ${Helper.monthToString(expense.month)}',
                                                style: const TextStyle(
                                                  fontSize: AppFonds.smal,
                                            color: AppColors.textColorBright,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                expense.year.toString(),
                                                style: const TextStyle(
                                                  fontSize: AppFonds.smal,
                                            color: AppColors.textColorBright,
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
                                    value: selectedExpenses[index],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        selectedExpenses[index] = value ??
                                            false;
                                      });
                                    },
                                  ),
                              ],
                            );
                          },
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
