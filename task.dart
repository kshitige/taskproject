
import 'dart:async';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:draggable_floating_button/draggable_floating_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Login_splash extends StatefulWidget {
  Login_splash({this.app});
  final FirebaseApp app;
  @override
  State<StatefulWidget> createState() {
    return Login_splashState();
  }
}
class Login_splashState extends State<Login_splash> {

  final referenceDatabase = FirebaseDatabase.instance;

  TabController controller;
  TextEditingController titleController = TextEditingController();
  TextEditingController descipController = TextEditingController();
  String taskTitle = "Title";
  String taskDescription = "Description";
  @override
  Widget build(BuildContext context) {

    final ref = referenceDatabase.reference();
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    dateTime = DateFormat.yMd().format(DateTime.now());
    return MaterialApp(
      home: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 10,top: 10),
                      child: Text("Task Page")),
                ],
              ),
            ),
            body: getBody(),
            floatingActionButton: DraggableFab(
              child: FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: this.context,
                    builder: (context) =>
                    AlertDialog(
                      title: const Text('Add Your Task Here'),
                      content: Column(
                        children: [
                          Text(taskTitle),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                            child: TextField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your title',
                              ),
                            ),
                          ),
                           Text(taskDescription),
                           Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: descipController,
                              maxLines: 8, //or null
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter description here',
                              ),
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              const Text(
                                'Choose Date',
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5),
                              ),
                              InkWell(
                                onTap: () {
                                  _selectDate(context);
                                },
                                child: Container(
                                  width: _width / 1.7,
                                  height: _height / 10,
                                  margin: const EdgeInsets.only(top: 30),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: Colors.grey[200]),
                                  child: TextFormField(
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                    enabled: false,
                                    keyboardType: TextInputType.text,
                                    controller: _dateController,
                                    onSaved: (String val) {
                                      _setDate = val;
                                    },
                                    decoration: const InputDecoration(
                                        disabledBorder:
                                        UnderlineInputBorder(borderSide: BorderSide.none),
                                        // labelText: 'Time',
                                        contentPadding: EdgeInsets.only(top: 0.0)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      actions: <Widget>[
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(false),
                          child: const Text("NO"),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: (){
                            ref.child("Title").push().child(taskTitle).set(titleController.text).asStream();
                            ref.child("Description").push().child(taskDescription).set(titleController.text).asStream();
                            ref.child("Date").push().child("Date").set(_dateController.text).asStream();
                          },
                            child: const Text("Save")
                        ),
                      ],
                    ),
                  );
                },
                child: Image.asset("assets/add.jpg",height: 30,width: 30,),
            ),
          ),
        ),
      ),
    ));
  }


  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat.yMd().format(DateTime.now());
    }
  final GlobalKey _parentKey = GlobalKey();
  final List _tabList = ["Today", "Tomorrow", "Upcoming"];
  final StreamController<int> _tabController = StreamController.broadcast();

  List _todayslist = [];
  List _tomorrowlist = [];
  List _upcominglist =[];

  double _height;
  double _width;
  String _setDate;
  TextEditingController _dateController = TextEditingController();

  String dateTime;

  DateTime selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat.yMd().format(selectedDate);
      });
    }
  }

  getDate(){
    return InkWell(
      onTap: () {
        _selectDate(context);
      },
      child: Container(
        width:  1.7,
        height:  9,
        margin: const EdgeInsets.only(top: 30),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: TextFormField(
          style: const TextStyle(fontSize: 40),
          textAlign: TextAlign.center,
          enabled: false,
          keyboardType: TextInputType.text,
          controller: _dateController,
          onSaved: (String val) {
            _setDate = val;
          },
          decoration: const InputDecoration(
              disabledBorder:
              UnderlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.only(top: 0.0)),
        ),
      ),
    );
  }

  getBody() {
    return  Column(
      children: [
        TabBar(
          isScrollable: true,
          labelStyle: const TextStyle(fontSize: 12,),
          controller: controller,
          labelColor: Colors.black,
          // labelColor: colorCode.cerulean,
          unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
          indicatorSize: TabBarIndicatorSize.label,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).indicatorColor,
                width: 2,
              ),
            ),
          ),
          tabs: List.generate(
            _tabList.length,
                (index) => Tab(text: _tabList[index]),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              _tabList.length, (index) => maketabdesign(index),
            ),
          ),
        ),
        //floatingbutton(),
      ],
    );
  }


  maketabdesign(int index) {
    switch (index) {
      case 0:
        _todayslist = [];
        return Container();
      case 1:
        _tomorrowlist = [];
        return Container();
      case 2:
        _upcominglist = [];
        return Container();
      default:
        return Container();
    }
  }

  searchBar(BuildContext context) {}
  }

  @override
  void dispose() {
  }


