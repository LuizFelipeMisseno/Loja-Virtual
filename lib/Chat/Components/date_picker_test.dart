import 'package:flutter/material.dart';

class DatePicker extends ChangeNotifier {
  DateTime _day = DateTime.now();
  DateTime get today => _day;

  showCalendar(context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((value) {
      _day = value!;
      notifyListeners();
    });
  }
}

//chamar Provider
//DatePicker datePicker = Provider.of<DatePicker>(context);
//datePicker.showCalendar(context);

//Receber atualizações
//Consumer<DatePicker>(
      //builder: ((context, selectedDay, child) {}