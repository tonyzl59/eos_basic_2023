import 'package:eos_practice/timer_item.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ClassApp extends StatefulWidget {
  const ClassApp({super.key});

  @override
  State<ClassApp> createState() => _ClassAppState();
}

class _ClassAppState extends State<ClassApp> {
  var _time = 0;
  var _totalTime = 0;
  var _isRunning = false;
  var _timer;
  var _nowRunning;
  List<TimerItem> timerItems = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
    intializeTimerItems();
  }

  void intializeTimerItems() async {
    await Future.delayed(const Duration(seconds: 3));
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? subjectNameList = prefs.getStringList("subjectNameList");
    if (subjectNameList == null) {
      print("no data!");
      return;
    }
    for (String subjectname in subjectNameList) {
      timerItems.add(TimerItem(subjectname));
    }
  }

  void _updateTimer(Timer timer) {
    setState(() {
      if (_isRunning) {
        timerItems.forEach((element) {
          if (element.isRunning) element.time++;
        });
        _totalTime++;
      }
    });
  }

  void _startTimer(index) {
    setState(() {
      if (_isRunning == true) {
        timerItems[_nowRunning].isRunning = false;
      }
      _isRunning = true;
      timerItems[index].isRunning = true;
      _nowRunning = index;
    });
  }

  void _pauseTimer(index) {
    setState(() {
      timerItems[index].isRunning = false;
      if (!timerItems.any((element) => element.isRunning)) _isRunning = false;
    });
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _totalTime = 0;
      timerItems.forEach((element) {
        element.time = 0;
        element.isRunning = false;
      });
    });
  }

  void _resetEachTimer(index) {
    setState(() {
      _totalTime = _totalTime - timerItems[index].time;
      timerItems[index].time = 0;
      timerItems[index].isRunning = false;
      _isRunning = false;
    });
  }

  void addItem(String subjectName) {
    timerItems.add(TimerItem(subjectName));
    saveITemToLocalScorage();
  }

  void saveITemToLocalScorage() async {
    final subjectNameList = timerItems.map((timer) => timer.name).toList();
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("subjectNameList", subjectNameList);
  }

  void deleteitem(int index) {
    setState(() {
      _resetEachTimer(index);
    });
    timerItems.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    var totalSec = (_totalTime % 60).toString().padLeft(2, '0');
    var totalMin = ((_totalTime ~/ 60) % 60).toString().padLeft(2, '0');
    var totalHour = (_totalTime ~/ 3600).toString().padLeft(2, '0');

    return Scaffold(
        appBar: AppBar(
          title: const Text('EOS BASIC'),
          centerTitle: true,
          backgroundColor: Colors.green,
          leading: const Icon(Icons.dehaze),
          actions: [const Icon(Icons.settings_outlined)],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            TextEditingController controller = TextEditingController();

            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: SizedBox(
                      height: 300,
                      child: Column(
                        children: [
                          const Spacer(),
                          const Text(
                            "과목명을 입력하시오",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 10,
                            ),
                            child: TextField(
                              controller: controller,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              addItem(controller.text);
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 40,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  );
                });
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: _resetTimer,
                child: Image.asset(
                  'assets/eos_logo.png',
                  width: 150,
                  height: 150,
                ),
              ),
              Text(
                "$totalHour:$totalMin:$totalSec",
                style:
                    const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 100,
              ),
              const Divider(
                height: 3,
                color: Colors.black,
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: timerItems.length,
                      itemBuilder: (context, index) {
                        var sec = (timerItems[index].time % 60)
                            .toString()
                            .padLeft(2, '0');
                        var min = ((timerItems[index].time ~/ 60) % 60)
                            .toString()
                            .padLeft(2, '0');
                        var hour = (timerItems[index].time ~/ 3600)
                            .toString()
                            .padLeft(2, '0');

                        return Dismissible(
                          key: ValueKey(timerItems[index]),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            deleteitem(index);
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      padding: const EdgeInsets.all(0),
                                      onPressed: () {
                                        timerItems[index].isRunning
                                            ? _pauseTimer(index)
                                            : _startTimer(index);
                                      },
                                      icon: timerItems[index].isRunning
                                          ? const Icon(
                                              Icons.pause_circle,
                                              size: 40,
                                              color: Colors.green,
                                            )
                                          : const Icon(
                                              Icons.play_circle,
                                              size: 40,
                                              color: Colors.green,
                                            ),
                                    ),
                                    if (timerItems[index].time != 0)
                                      IconButton(
                                          padding: const EdgeInsets.all(0),
                                          onPressed: () {
                                            _resetEachTimer(index);
                                          },
                                          icon: const Icon(
                                            Icons.stop_circle,
                                            size: 40,
                                            color: Colors.redAccent,
                                          )),
                                    Expanded(
                                      child: Text(
                                        timerItems[index].name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 25),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Text(
                                      "$hour:$min:$sec",
                                      style: const TextStyle(fontSize: 25),
                                    )
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 3,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        );
                      }))
            ],
          ),
        )));
  }
}
