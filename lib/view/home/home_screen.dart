import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todoey_aventus_test/model/task_model.dart';
import 'package:todoey_aventus_test/services/hive_db_services.dart';
import 'package:todoey_aventus_test/utils/constants.dart';
import 'package:todoey_aventus_test/view/task/task_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  HiveDbServices _dbServices = HiveDbServices();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _dbServices.listenToTask(),
      builder: (ctx, Box<TaskModel> box, Widget? child) {
        var tasks = box.values.toList();
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            centerTitle: true,
            title: const Text(
              'Todoey',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: tasks.isEmpty
                ? const Center(
                    child: Text(
                      'You have completed all tasks\n Add new tasks now!!!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        color: tasks[index].isCompleted
                            ? Theme.of(context).colorScheme.inversePrimary
                            : null,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListTile(
                            isThreeLine: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskScreen(
                                    isAdd: false,
                                    task: tasks[index],
                                  ),
                                ),
                              );
                            },
                            leading: GestureDetector(
                              onTap: () {
                                tasks[index].isCompleted =
                                    !tasks[index].isCompleted;
                                tasks[index].save();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                decoration: BoxDecoration(
                                    color: tasks[index].isCompleted
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: .8)),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            title: Text(
                              tasks[index].title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  height: 1.5,
                                  decoration: tasks[index].isCompleted
                                      ? TextDecoration.lineThrough
                                      : null),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tasks[index].subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        decoration: tasks[index].isCompleted
                                            ? TextDecoration.lineThrough
                                            : null),
                                  ),
                                  Text(
                                    'Due Time: ${tasks[index].taskTime}, ${tasks[index].taskDate}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey.shade800),
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                final result = await confirmDialog(context);
                                if (result != null && result) {
                                  tasks[index].delete();
                                  showSnackbarMsg(
                                      context, 'Task deleted successfully');
                                }
                              },
                              icon: const Icon(
                                Icons.delete,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskScreen(),
                  ));
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}
