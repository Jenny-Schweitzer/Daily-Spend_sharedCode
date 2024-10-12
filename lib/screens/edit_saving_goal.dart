import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditSavingGoal extends StatefulWidget {
  @override
  _EditSavingGoalState createState() => _EditSavingGoalState();
}

class _EditSavingGoalState extends State<EditSavingGoal> {
  final TextEditingController _savingGoalController = TextEditingController();

  Future<void> _getSavingGoal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savingGoal = prefs.getInt('savingGoal');
    _savingGoalController.text = savingGoal!.toString();
  }

  Future<void> _setNewSavingGoal(BuildContext context) async {
    int savingGoal = int.parse(_savingGoalController.text);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('savingGoal', savingGoal);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void initState() {
    super.initState();
    _getSavingGoal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'Saving Goal',
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'How much do you wanna save per Year?',
                  style: TextStyle(
                    fontSize: AppFonds.superBig,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorBright,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(
                    fontSize: AppFonds.meduim,
                    color: AppColors.textColorBright70,
                  ),
                  controller: _savingGoalController,
                  keyboardType: TextInputType.number,
                  cursorColor: AppColors.primaryColor,
                  decoration: const InputDecoration(
                    fillColor: AppColors.backgroundColorDark,
                    filled: true,
                    labelText: 'goal per year',
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
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    _setNewSavingGoal(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'set new saving goal',
                    style: TextStyle(
                        fontSize: AppFonds.buttonBig,
                        color: AppColors.onPrimaryColor),
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
