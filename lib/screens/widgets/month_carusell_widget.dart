import 'package:flutter/material.dart';
import 'package:flutter_project/utils/app_colors.dart';
import 'package:flutter_project/utils/helper.dart';

class MonthCarouselWidget extends StatefulWidget {
  final int selectedMonthIndex;
  final ValueChanged<int> onMonthChanged;

  const MonthCarouselWidget({
    Key? key,
    required this.selectedMonthIndex,
    required this.onMonthChanged,
  }) : super(key: key);

  @override
  _MonthCarouselWidgetState createState() => _MonthCarouselWidgetState();
}

class _MonthCarouselWidgetState extends State<MonthCarouselWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedMonth();
    });
  }

  void _scrollToSelectedMonth() {
    const double width = 100.0; // Width of each month item
    final double offset = (widget.selectedMonthIndex * width) -
        (MediaQuery.of(context).size.width / 2 - width / 2);

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        itemCount: 12,
        itemBuilder: (context, index) {
          final bool isSelected = index == widget.selectedMonthIndex;
          return GestureDetector(
            onTap: () {
              widget.onMonthChanged(index);
              _scrollToSelectedMonth();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.textColorDark50.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text( Helper.monthToString(index +1),
                  style: TextStyle(
                    color: isSelected ? AppColors.onPrimaryColor : AppColors.onSecondaryColor,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
