// Datenbankzugriff und -operationen.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

// // Toggel if you need a new Databsae in Debug-Mode
//   // Getter für die Datenbank
//   Future<Database> get database async {
//     await deleteDatabaseFile();
//     _database = await _initDatabase();
//     return _database!;
//   }
// // Delete Database
//   Future<void> deleteDatabaseFile() async {
//     String path = join(await getDatabasesPath(), 'daily_spend.db');
//     await deleteDatabase(path);
//   }

//Toggel for normal function
  // Getter für die Datenbank
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialisierung der Datenbank
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'daily_spend.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Erstellung der Tabellen beim ersten Start
  Future _onCreate(Database db, int version) async {
    // Tabelle 'categories'
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT UNIQUE,
        icon TEXT UNIQUE,
        color TEXT UNIQUE
      )
    ''');

    // Tabelle 'expenses'
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY,
        name TEXT,
        amount REAL,
        month INTEGER,
        year INTEGER,
        category_id INTEGER,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Tabelle 'income'
    await db.execute('''
      CREATE TABLE income (
        id INTEGER PRIMARY KEY,
        amount REAL,
        start_month INTEGER,
        start_year INTEGER
      )
    ''');

    // Tabelle 'settings'
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        saving_goal REAL
      )
    ''');
  }

  //insert

  Future<int> insertCategory(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('categories', row);
  }

  Future<int> insertExpenses(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('expenses', row);
  }

  Future<int> insertIncome(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('income', row);
  }

  // get

  // Category
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    Database db = await instance.database;
    return await db.query('categories');
  }

  Future<Map<String, dynamic>?> getCategoryById(int categoryId) async {
    Database db = await instance.database;

    // Führe die Query aus und beschränke das Ergebnis auf eine Zeile
    List<Map<String, dynamic>> result = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [categoryId],
      limit: 1, // Hier sicherstellen, dass nur maximal eine Zeile zurückkommt
    );
    // Überprüfe, ob das Ergebnis nicht leer ist, und gebe die erste (und einzige Zeile) zurück
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  @Deprecated('use -AllValues')
  Future<Map<String, Map<String, dynamic>>>
      getCategoryExpenseDistributionForYear(int year) async {
    Database db = await instance.database;

    // Abfrage, um das Icon, die Farbe und die Gesamtausgaben pro Kategorie zu holen
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT c.icon as categoryIcon, c.color as categoryColor, SUM(e.amount) as totalAmount
    FROM expenses e
    JOIN categories c ON e.category_id = c.id
    WHERE e.year = ?
    GROUP BY e.category_id
  ''', [year]);

    // Map für die Rückgabe vorbereiten: Icon als Schlüssel, Farbe und Betrag als Werte
    Map<String, Map<String, dynamic>> categoryExpenseMap = {};

    for (var row in result) {
      if (row['categoryIcon'] != null && row['totalAmount'] != null) {
        categoryExpenseMap[row['categoryIcon']] = {
          'totalAmount': row['totalAmount'] as double,
          'color': row['categoryColor']
        };
      }
    }

    return categoryExpenseMap;
  }

  Future<Map<String, Map<String, dynamic>>>
      getCategoryExpenseDistributionForYearAllValues(int year) async {
    Database db = await instance.database;

    // Abfrage, um das Icon, die Farbe und die Gesamtausgaben pro Kategorie zu holen
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT c.name as catgoryName, c.icon as categoryIcon, c.color as categoryColor, SUM(e.amount) as totalAmount
    FROM expenses e
    JOIN categories c ON e.category_id = c.id
    WHERE e.year = ?
    GROUP BY e.category_id
  ''', [year]);

    // Map für die Rückgabe vorbereiten: Icon als Schlüssel, Farbe und Betrag als Werte
    Map<String, Map<String, dynamic>> categoryExpenseMap = {};

    for (var row in result) {
      if (row['categoryIcon'] != null && row['totalAmount'] != null) {
        categoryExpenseMap[row['categoryIcon']] = {
          'totalAmount': row['totalAmount'] as double,
          'color': row['categoryColor'],
          'name': row['catgoryName']
        };
      }
    }

    return categoryExpenseMap;
  }

  // Expenses
  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    Database db = await instance.database;
    return await db.query('expenses', orderBy: 'year DESC, month DESC');
  }

  Future<double> getTotalExpenseForYear(int year) async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(amount) as totalExpense 
    FROM expenses 
    WHERE year = ?
  ''', [year]);

    if (result.isNotEmpty && result.first['totalExpense'] != null) {
      return result.first['totalExpense'] as double;
    }

    return 0.0;
  }

  Future<double> getAverageExpense(int averagePeriode) async {
    Database db = await instance.database;
    int month = DateTime.now().month;
    int year = DateTime.now().year;
    double currentAmount = 0.0;
    double totalExpense = 0.0;
    int count = 0;
    int addCount = 0;
    int? lastElementID;
    bool lastElement = false;

    final List<Map<String, dynamic>> result =
        await db.query('expenses', orderBy: 'year DESC, month DESC');

    if (averagePeriode == 120 && result.isNotEmpty) {
      lastElementID = result.last['id'] as int;
    }

    for (int i = 0;
        i < averagePeriode && lastElement == false && result.isNotEmpty;
        i++) {
      for (var row in result) {
        int expenseYear = row['year'] as int;
        int expenseMonth = row['month'] as int;
        double expenseAmount = row['amount'] as double;
        int elementID = row['id'] as int;

        if (expenseYear == year && expenseMonth == month) {
          currentAmount += expenseAmount;
          addCount = 1;
          if (lastElementID == elementID) {
            lastElement = true;
          }
        }
      }
      totalExpense = currentAmount;
      count += addCount;
      addCount = 0;
      month = month - 1; // Verringere den Monat
      if (month == 0) {
        //wenn Januar überschreiten wird
        month = 12; // Wechsel ins vorherige Jahr
        year = year - 1;
      }
    }

    if (count == 0) {
      return 0.0;
    } else {
      return totalExpense / count;
    }
  }

  Future<void> deleteExpenses(List<int> expenseIds) async {
    Database db = await instance.database;

    // Beginne eine Transaktion für die Löschoperation
    await db.transaction((txn) async {
      for (int id in expenseIds) {
        await txn.delete(
          'expenses',
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
  }

  // Income
  Future<List<Map<String, dynamic>>> getAllIncome() async {
    Database db = await instance.database;
    return await db.query('income',
        orderBy: 'start_year DESC, start_month DESC');
  }

//// currently not used ////
//TODO: check if you can delete this?
  Future<double> getTotalIncomeForYear(int year) async {
    Database db = await instance.database;
    // Hole alle Einkommensänderungen, die vor oder im übergebenen Jahr gestartet wurden
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT amount, start_month, start_year 
    FROM income 
    WHERE start_year <= ?
    ORDER BY start_year ASC, start_month ASC  
  ''', [year]);
    //ASC = niederigster Wert hin zum höchsten Wert
    double totalIncomeForYear = 0.0;
    // Initialisiere Variablen für die aktuelle Einkommensberechnung
    double currentIncome = 0.0;

    for (int month = 1; month <= 12; month++) {
      // Gehe durch alle Monate des Jahres und aktualisiere das Einkommen bei einer Einkommensänderung
      for (var row in result) {
        int incomeStartYear = row['start_year'] as int;
        int incomeStartMonth = row['start_month'] as int;
        double incomeAmount = row['amount'] as double;
        // Wenn das Einkommen im aktuellen Monat greift
        if (incomeStartYear < year ||
            (incomeStartYear == year && incomeStartMonth <= month)) {
          currentIncome = incomeAmount;
        }
      }
      // Füge das aktuelle Einkommen für diesen Monat hinzu
      totalIncomeForYear += currentIncome;
    }
    return totalIncomeForYear;
  }

  Future<double> getTotalIncomeForCurrentYearTilToday() async {
    final int currentYear = DateTime.now().year;
    final int currentMonth = DateTime.now().month;

    Database db = await instance.database;

    // Hole alle Einkommen geordnet nach Jahr und Monat (aufsteigend)
    final List<Map<String, dynamic>> result =
        await db.query('income', orderBy: 'start_year ASC, start_month ASC');

    double totalIncomeForYear = 0.0;
    double currentIncome = 0.0;
    double lastIncomeBeforeCurrentYear = 0.0;

    // Finde das letzte Einkommen vor dem aktuellen Jahr
    for (var row in result) {
      int incomeStartYear = row['start_year'] as int;
      double incomeAmount = row['amount'] as double;

      // Wenn das Einkommen aus einem früheren Jahr kommt, speichere es in Hilfsvariable
      if (incomeStartYear < currentYear) {
        lastIncomeBeforeCurrentYear = incomeAmount;
      }

      // sobald im aktuellen Jahr ankommen = breake
      if (incomeStartYear == currentYear) {
        break;
      }
    }

    // Für jeden Monat des aktuellen Jahres, von Januar bis zum aktuellen Monat
    for (int month = 1; month <= currentMonth; month++) {
      // Gehe durch alle Einträge und finde das passende Einkommen für den aktuellen Monat
      bool incomeFoundForMonth = false;

      for (var row in result) {
        int incomeStartYear = row['start_year'] as int;
        int incomeStartMonth = row['start_month'] as int;
        double incomeAmount = row['amount'] as double;

        // Prüfe, ob es ein Einkommen für diesen Monat und das aktuelle Jahr gibt
        if (incomeStartYear == currentYear && incomeStartMonth <= month) {
          currentIncome = incomeAmount;
          incomeFoundForMonth = true;
        }
      }

      // Wenn kein Einkommen für diesen Monat gefunden wurde, verwende das letzte gültige Einkommen aus dem Vorjahr
      if (!incomeFoundForMonth) {
        currentIncome = lastIncomeBeforeCurrentYear;
      }

      // Füge das Einkommen für den aktuellen Monat zur Gesamtsumme hinzu
      totalIncomeForYear += currentIncome;
    }

    return totalIncomeForYear;
  }

  Future<void> deleteIncome(List<int> incomeIds) async {
    Database db = await instance.database;
    await db.transaction((txn) async {
      for (int id in incomeIds) {
        await txn.delete(
          'income',
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
  }
}
