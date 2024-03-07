import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todoey_aventus_test/model/task_model.dart';
import 'package:todoey_aventus_test/services/hive_db_services.dart';
import 'package:todoey_aventus_test/utils/constants.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({
    super.key,
    this.isAdd = true,
    this.task,
  });
  final TaskModel? task;
  final bool isAdd;
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  HiveDbServices _dbServices = HiveDbServices();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MMM-dd').format(_selectedDate!);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = _selectedTime!.format(context);
      });
    }
  }

  TimeOfDay parseTimeOfDay(String formattedTime) {
    DateFormat format = DateFormat("hh:mm a");

    // Use parseStrict to enforce strict parsing
    DateTime dateTime = format.parseStrict(formattedTime);

    // Extract hours and minutes from the DateTime object
    int hours = dateTime.hour;
    int minutes = dateTime.minute;

    // Create and return a TimeOfDay object
    return TimeOfDay(hour: hours, minute: minutes);
  }

  @override
  void initState() {
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _contentController.text = widget.task!.subtitle;
      _dateController.text = widget.task!.taskDate;
      _timeController.text = widget.task!.taskTime;
      _selectedDate = DateFormat('yyyy-MMM-dd').parse(widget.task!.taskDate);
      _selectedTime = parseTimeOfDay(widget.task!.taskTime);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          widget.isAdd ? 'Add Task' : 'Edit Task',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                labelText: 'Select Date',
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _timeController,
              readOnly: true,
              onTap: () => _selectTime(context),
              decoration: InputDecoration(
                labelText: 'Select Time',
                suffixIcon: Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: widget.isAdd
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceEvenly,
                children: [
                  widget.isAdd
                      ? Container()

                      /// Delete Task Button
                      : Container(
                          width: 150,
                          height: 55,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2),
                              borderRadius: BorderRadius.circular(15)),
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minWidth: 150,
                            height: 55,
                            onPressed: () async {
                              final result = await confirmDialog(context);
                              if (result != null && result) {
                                await _dbServices.deleteTask(
                                    task: widget.task!);
                                showSnackbarMsg(
                                    context, 'Task deleted successfully');
                                Navigator.pop(context);
                              }
                            },
                            color: Colors.white,
                            child: Text(
                              'Delete Task',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ),

                  /// Add or Update Task Button
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minWidth: 150,
                    height: 55,
                    onPressed: () async {
                      if (_titleController.text == '') {
                        showSnackbarMsg(context, 'Title is required one');
                      } else {
                        if (widget.isAdd) {
                          TaskModel task = TaskModel.create(
                            title: _titleController.text,
                            subtitle: _contentController.text,
                            taskDate: _dateController.text,
                            taskTime: _timeController.text,
                          );
                          await _dbServices.addTask(task: task);
                          showSnackbarMsg(
                              context, 'New task added successfully');
                        } else {
                          widget.task!.title = _titleController.text;
                          widget.task!.subtitle = _contentController.text;
                          widget.task!.taskDate = _dateController.text;
                          widget.task!.taskTime = _timeController.text;
                          await _dbServices.updateTask(task: widget.task!);
                          showSnackbarMsg(context, 'Task updated successfully');
                        }

                        Navigator.pop(context);
                      }
                    },
                    color: Theme.of(context).colorScheme.primary,
                    child: Text(
                      widget.isAdd ? 'Add Task' : 'Update Task',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
