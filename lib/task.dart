import 'dart:async';
import 'dart:convert';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class Login_splash extends StatefulWidget {
  Login_splash({this.app});

  final FirebaseApp app;

  @override
  State<StatefulWidget> createState() {
    return Login_splashState();
  }
}

class Login_splashState extends State<Login_splash> {
  TabController controller;
  TextEditingController titleController = TextEditingController();
  TextEditingController descipController = TextEditingController();
  StreamController<bool> _taskcontroller = StreamController.broadcast();
  String taskTitle = "Title";
  String taskDescription = "Description";
  DatabaseReference refNew;
  DatabaseReference referenceDatabase;

  DateTime now = DateTime.now();

  var newdate;
  List listdata = [];
  List keytoday = [];
  List keytomorrow = [];
  List keyupcoming = [];
  var date;
  var desc;
  var title;
  var key;

  List _tabList = ["Today", "Tomorrow", "Upcoming"];
  StreamController<int> _tabController = StreamController.broadcast();

  List _todayslist = [];
  List _tomorrowlist = [];
  List _upcominglist = [];

  double _height;
  double _width;
  String _setDate;
  TextEditingController _dateController = TextEditingController();

  String dateTime;

  var newdata;
  var tomorrownew;

  DateTime selectedDate = DateTime.now();

  @override
  Future<void> initState() {
    refNew = FirebaseDatabase.instance.ref().child('Task');
    referenceDatabase = FirebaseDatabase.instance.ref().child('Task');
    super.initState();
    loadSalesData();
    _dateController.text = DateFormat.yMd().format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: EdgeInsets.only(left: 10, top: 10),
                    child: Text("Daily Task")),
              ],
            ),
          ),
          body: getBody(),
          floatingActionButton: DraggableFab(
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: this.context,
                  builder: (context) => AlertDialog(
                    title: const Center(child: Text('Add Your Task Here')),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            taskTitle,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
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
                          SizedBox(
                            height: 20,
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
                                  margin: const EdgeInsets.only(top: 10),
                                  alignment: Alignment.center,
                                  decoration:
                                      BoxDecoration(color: Colors.grey[200]),
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
                                        disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide.none),
                                        // labelText: 'Time',
                                        contentPadding:
                                            EdgeInsets.only(top: 0.0)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(false),
                            child: Container(
                                color: Colors.blueGrey,
                                padding: new EdgeInsets.fromLTRB(
                                    20.0, 10.0, 20.0, 10.0),
                                child: const Text("NO")),
                          ),
                          const SizedBox(width: 25),
                          InkWell(
                              onTap: () {
                                Map<dynamic, String> taskDetails = {
                                  'Title': titleController.text,
                                  'Description': descipController.text,
                                  'Date': _dateController.text
                                };

                                refNew.push().set(taskDetails);
                                titleController.clear();
                                descipController.clear();
                                _dateController.clear();
                                loadSalesData();
                                Navigator.pop(context);
                              },
                              child: Container(
                                  color: Colors.blueAccent,
                                  padding: new EdgeInsets.fromLTRB(
                                      20.0, 10.0, 20.0, 10.0),
                                  child: const Text("Save"))),
                        ],
                      ),
                    ],
                  ),
                );
              },
              child: Icon(
                Icons.add,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    ));
  }

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

  getDate() {
    return InkWell(
      onTap: () {
        _selectDate(context);
      },
      child: Container(
        width: 1.7,
        height: 9,
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
              disabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.only(top: 0.0)),
        ),
      ),
    );
  }

  getBody() {
    return Column(
      children: [
        TabBar(
          onTap: (int index) async {
            await getJsonFromFirebaseRestAPI();
            _taskcontroller.add(true);
          },
          isScrollable: true,
          labelStyle: const TextStyle(
            fontSize: 20,
          ),
          controller: controller,
          labelColor: Colors.black,
          // labelColor: colorCode.cerulean,
          unselectedLabelColor:
              Theme.of(context).tabBarTheme.unselectedLabelColor,
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
              _tabList.length,
              (index) => maketabdesign(index),
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
        return TodaysTask();
      case 1:
        return TomorrowTask();
      case 2:
        return UpcomingTask();
      default:
        return Container();
    }
  }

  Future<String> getJsonFromFirebaseRestAPI() async {
    listdata = List();
    String url = "https://test-dae03-default-rtdb.firebaseio.com/Task.json";
    http.Response response = await http.get(Uri.parse(url));
    Map<dynamic, dynamic> data =
        json.decode(response.body) as Map<dynamic, dynamic>;
    for (int i = 0; i < data.length; i++) {
      Map<dynamic, dynamic> datas =
          data.values.elementAt(i) as Map<dynamic, dynamic>;
      print(data.keys.elementAt(i));
      print(datas.values.elementAt(0));
      print(datas.values.elementAt(1));
      print(datas.values.elementAt(2));
      listdata.add(
          "${datas.values.elementAt(0)}@${datas.values.elementAt(1)}@${datas.values.elementAt(2)}@${data.keys.elementAt(i)}");
    }
    print(listdata);

    return listdata.toString();
  }



  Future loadSalesData() async {
    String jsonString = await getJsonFromFirebaseRestAPI();
    _todayslist = List();
    _tomorrowlist = List();
    _upcominglist = List();
    for (int i = 0; i < listdata.length; i++) {
      newdata = listdata.elementAt(i);
      // if(newdata.contains("--")){
      //   continue;
      // }
      newdata = newdata.split('@').toList();
      if (newdata[0] == "" || newdata == null) {
        continue;
      }
      date = newdata[0];
      desc = newdata[1];
      title = newdata[2];
      key = newdata[3];
      if (date == "" && date == null) {
        continue;
      }
      var dmyString = date;
      DateTime tempDate = DateFormat("MM/dd/yyyy").parse(dmyString);
      newdate = DateFormat('yyyy-dd-MM').format(tempDate);
      DateFormat formatter = DateFormat('yyyy-dd-MM');
      String formatted = formatter.format(now);
      var tomorrow = DateTime(now.year, now.month, now.day + 1);
      tomorrownew = DateFormat('yyyy-dd-MM').format(tomorrow);
      if (newdate == formatted) {
        _todayslist.add(newdata);
        keytoday.add(key);
      } else if (newdate == tomorrownew) {
        _tomorrowlist.add(newdata);
        keytomorrow.add(key);
      } else if (newdate != tomorrownew && newdate != formatted) {
        _upcominglist.add(newdata);
        keyupcoming.add(key);
      }
    }
    _taskcontroller.add(true);
  }

  TodaysTask() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Divider(
          thickness: 3,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Date",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30.0),
              child: Text(
                "Title",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 30.0),
              child: Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const Divider(
          thickness: 3,
        ),
        StreamBuilder<bool>(
            stream: _taskcontroller.stream,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return const Text("No Data");
              } else if (snapshot.data == false) {
                return const Text("Loading...");
              }
              return Expanded(
                child: ListView.builder(
                    itemCount: _todayslist.length,
                    itemBuilder: (context, index) {
                      newdata = _todayslist[index];
                      return Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(newdata[0]),
                                  ),
                                ),
                                Flexible(
                                    flex: 1,
                                    child: Text(
                                      newdata[2],
                                      textAlign: TextAlign.end,
                                    )),
                                Flexible(
                                    fit: FlexFit.tight,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Flexible(
                                            fit: FlexFit.tight,
                                            child: Text(newdata[1],
                                                textAlign: TextAlign.end)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: this.context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                            title: const Center(
                                                                child: Text(
                                                                    'Add Your Task Here')),
                                                            content:
                                                                SingleChildScrollView(
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    taskTitle,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            16),
                                                                    child:
                                                                        TextField(
                                                                      controller:
                                                                          titleController,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        hintText:
                                                                            'Enter your title',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                      taskDescription),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        TextField(
                                                                      controller:
                                                                          descipController,
                                                                      maxLines:
                                                                          8,
                                                                      //or null
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        hintText:
                                                                            'Enter description here',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  Column(
                                                                    children: <
                                                                        Widget>[
                                                                      const Text(
                                                                        'Choose Date',
                                                                        style: TextStyle(
                                                                            fontStyle:
                                                                                FontStyle.italic,
                                                                            fontWeight: FontWeight.w600,
                                                                            letterSpacing: 0.5),
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          _selectDate(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          margin:
                                                                              const EdgeInsets.only(top: 10),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          decoration:
                                                                              BoxDecoration(color: Colors.grey[200]),
                                                                          child:
                                                                              TextFormField(
                                                                            style:
                                                                                const TextStyle(fontSize: 10),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            enabled:
                                                                                false,
                                                                            keyboardType:
                                                                                TextInputType.text,
                                                                            controller:
                                                                                _dateController,
                                                                            onSaved:
                                                                                (String val) {
                                                                              _setDate = val;
                                                                            },
                                                                            decoration: const InputDecoration(
                                                                                disabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                                                                                // labelText: 'Time',
                                                                                contentPadding: EdgeInsets.only(top: 0.0)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            actions: <Widget>[
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () =>
                                                                        Navigator.of(context)
                                                                            .pop(false),
                                                                    child: Container(
                                                                        color: Colors
                                                                            .blueGrey,
                                                                        padding: new EdgeInsets.fromLTRB(
                                                                            20.0,
                                                                            10.0,
                                                                            20.0,
                                                                            10.0),
                                                                        child: const Text(
                                                                            "NO")),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          25),
                                                                  InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Map<String,
                                                                                dynamic>
                                                                            taskDetailsnew =
                                                                            {
                                                                          'Title':
                                                                              titleController.text,
                                                                          'Description':
                                                                              descipController.text,
                                                                          'Date':
                                                                              _dateController.text
                                                                        };
                                                                        var key =
                                                                            keytoday[index];
                                                                        refNew
                                                                            .child(key.toString())
                                                                            .update(taskDetailsnew)
                                                                            .then(
                                                                          (value) {
                                                                            //refNew.push().set(taskDetails);
                                                                            descipController.clear();
                                                                            _dateController.clear();
                                                                            loadSalesData();
                                                                            Navigator.pop(context);
                                                                          },
                                                                        );
                                                                      },
                                                                      child: Container(
                                                                          color: Colors
                                                                              .blueAccent,
                                                                          padding: new EdgeInsets.fromLTRB(
                                                                              20.0,
                                                                              10.0,
                                                                              20.0,
                                                                              10.0),
                                                                          child:
                                                                              const Text("Save"))),
                                                                ],
                                                              ),
                                                            ],
                                                          ));
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              size: 24,
                                            )),
                                        InkWell(
                                            onTap: () async {
                                              var key = keytoday[index];
                                              await referenceDatabase
                                                  .child(key)
                                                  .remove();
                                              keytoday.removeAt(index);
                                              loadSalesData();
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              size: 24,
                                            )),
                                      ],
                                    )),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
              );
            }),
      ],
    );
  }

  TomorrowTask() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Divider(
          thickness: 3,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Date",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30.0),
              child: Text(
                "Title",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 30.0),
              child: Text(
                "Description",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Divider(
          thickness: 3,
        ),
        StreamBuilder<bool>(
            stream: _taskcontroller.stream,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return const Text("No Data");
              } else if (snapshot.data == false) {
                return const Text("Loading...");
              }
              return Expanded(
                child: ListView.builder(
                    itemCount: _tomorrowlist.length,
                    itemBuilder: (context, index) {
                      newdata = _tomorrowlist[index];
                      return Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(newdata[0]),
                                  ),
                                ),
                                Flexible(
                                    flex: 1,
                                    child: Text(
                                      newdata[2],
                                      textAlign: TextAlign.end,
                                    )),
                                Flexible(
                                    fit: FlexFit.tight,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Flexible(
                                            fit: FlexFit.tight,
                                            child: Text(newdata[1],
                                                textAlign: TextAlign.end)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: this.context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                            title: const Center(
                                                                child: Text(
                                                                    'Add Your Task Here')),
                                                            content:
                                                                SingleChildScrollView(
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    taskTitle,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            16),
                                                                    child:
                                                                        TextField(
                                                                      controller:
                                                                          titleController,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        hintText:
                                                                            'Enter your title',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                      taskDescription),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        TextField(
                                                                      controller:
                                                                          descipController,
                                                                      maxLines:
                                                                          8,
                                                                      //or null
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        hintText:
                                                                            'Enter description here',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  Column(
                                                                    children: <
                                                                        Widget>[
                                                                      const Text(
                                                                        'Choose Date',
                                                                        style: TextStyle(
                                                                            fontStyle:
                                                                                FontStyle.italic,
                                                                            fontWeight: FontWeight.w600,
                                                                            letterSpacing: 0.5),
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          _selectDate(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          margin:
                                                                              const EdgeInsets.only(top: 10),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          decoration:
                                                                              BoxDecoration(color: Colors.grey[200]),
                                                                          child:
                                                                              TextFormField(
                                                                            style:
                                                                                const TextStyle(fontSize: 10),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            enabled:
                                                                                false,
                                                                            keyboardType:
                                                                                TextInputType.text,
                                                                            controller:
                                                                                _dateController,
                                                                            onSaved:
                                                                                (String val) {
                                                                              _setDate = val;
                                                                            },
                                                                            decoration: const InputDecoration(
                                                                                disabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                                                                                // labelText: 'Time',
                                                                                contentPadding: EdgeInsets.only(top: 0.0)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            actions: <Widget>[
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () =>
                                                                        Navigator.of(context)
                                                                            .pop(false),
                                                                    child: Container(
                                                                        color: Colors
                                                                            .blueGrey,
                                                                        padding: new EdgeInsets.fromLTRB(
                                                                            20.0,
                                                                            10.0,
                                                                            20.0,
                                                                            10.0),
                                                                        child: const Text(
                                                                            "NO")),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          25),
                                                                  InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Map<String,
                                                                                dynamic>
                                                                            taskDetailsnew =
                                                                            {
                                                                          'Title':
                                                                              titleController.text,
                                                                          'Description':
                                                                              descipController.text,
                                                                          'Date':
                                                                              _dateController.text
                                                                        };
                                                                        var key =
                                                                            keytomorrow[index];
                                                                        refNew
                                                                            .child(key.toString())
                                                                            .update(taskDetailsnew)
                                                                            .then(
                                                                          (value) {
                                                                            //refNew.push().set(taskDetails);
                                                                            descipController.clear();
                                                                            _dateController.clear();
                                                                            loadSalesData();
                                                                            Navigator.pop(context);
                                                                          },
                                                                        );
                                                                      },
                                                                      child: Container(
                                                                          color: Colors
                                                                              .blueAccent,
                                                                          padding: new EdgeInsets.fromLTRB(
                                                                              20.0,
                                                                              10.0,
                                                                              20.0,
                                                                              10.0),
                                                                          child:
                                                                              const Text("Save"))),
                                                                ],
                                                              ),
                                                            ],
                                                          ));
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              size: 24,
                                            )),
                                        InkWell(
                                            onTap: () async {
                                              var key = keytomorrow[index];
                                              await referenceDatabase
                                                  .child(key)
                                                  .remove();
                                              keytomorrow.removeAt(index);
                                              loadSalesData();
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              size: 24,
                                            )),
                                      ],
                                    )),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
              );
            }),
      ],
    );
  }

  UpcomingTask() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Divider(
          thickness: 3,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Date",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30.0),
              child: Text(
                "Title",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 30.0),
              child: Text(
                "Description",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Divider(
          thickness: 3,
        ),
        StreamBuilder<bool>(
            stream: _taskcontroller.stream,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return const Text("No Data");
              } else if (snapshot.data == false) {
                return const Text("Loading...");
              }
              return Expanded(
                child: ListView.builder(
                    itemCount: _upcominglist.length,
                    itemBuilder: (context, index) {
                      newdata = _upcominglist[index];
                      return Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(newdata[0]),
                                  ),
                                ),
                                Flexible(
                                    flex: 1,
                                    child: Text(
                                      newdata[2],
                                      textAlign: TextAlign.end,
                                    )),
                                Flexible(
                                    fit: FlexFit.tight,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Flexible(
                                            fit: FlexFit.tight,
                                            child: Text(newdata[1],
                                                textAlign: TextAlign.end)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: this.context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                            title: const Center(
                                                                child: Text(
                                                                    'Add Your Task Here')),
                                                            content:
                                                                SingleChildScrollView(
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    taskTitle,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            16),
                                                                    child:
                                                                        TextField(
                                                                      controller:
                                                                          titleController,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        hintText:
                                                                            'Enter your title',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                      taskDescription),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        TextField(
                                                                      controller:
                                                                          descipController,
                                                                      maxLines:
                                                                          8,
                                                                      //or null
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        hintText:
                                                                            'Enter description here',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  Column(
                                                                    children: <
                                                                        Widget>[
                                                                      const Text(
                                                                        'Choose Date',
                                                                        style: TextStyle(
                                                                            fontStyle:
                                                                                FontStyle.italic,
                                                                            fontWeight: FontWeight.w600,
                                                                            letterSpacing: 0.5),
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          _selectDate(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          margin:
                                                                              const EdgeInsets.only(top: 10),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          decoration:
                                                                              BoxDecoration(color: Colors.grey[200]),
                                                                          child:
                                                                              TextFormField(
                                                                            style:
                                                                                const TextStyle(fontSize: 10),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            enabled:
                                                                                false,
                                                                            keyboardType:
                                                                                TextInputType.text,
                                                                            controller:
                                                                                _dateController,
                                                                            onSaved:
                                                                                (String val) {
                                                                              _setDate = val;
                                                                            },
                                                                            decoration: const InputDecoration(
                                                                                disabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                                                                                // labelText: 'Time',
                                                                                contentPadding: EdgeInsets.only(top: 0.0)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            actions: <Widget>[
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () =>
                                                                        Navigator.of(context)
                                                                            .pop(false),
                                                                    child: Container(
                                                                        color: Colors
                                                                            .blueGrey,
                                                                        padding: new EdgeInsets.fromLTRB(
                                                                            20.0,
                                                                            10.0,
                                                                            20.0,
                                                                            10.0),
                                                                        child: const Text(
                                                                            "NO")),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          25),
                                                                  InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Map<String,
                                                                                dynamic>
                                                                            taskDetailsnew =
                                                                            {
                                                                          'Title':
                                                                              titleController.text,
                                                                          'Description':
                                                                              descipController.text,
                                                                          'Date':
                                                                              _dateController.text
                                                                        };
                                                                        var key =
                                                                            keyupcoming[index];
                                                                        refNew
                                                                            .child(key.toString())
                                                                            .update(taskDetailsnew)
                                                                            .then(
                                                                          (value) {
                                                                            //refNew.push().set(taskDetails);
                                                                            descipController.clear();
                                                                            _dateController.clear();
                                                                            loadSalesData();
                                                                            Navigator.pop(context);
                                                                          },
                                                                        );
                                                                      },
                                                                      child: Container(
                                                                          color: Colors
                                                                              .blueAccent,
                                                                          padding: new EdgeInsets.fromLTRB(
                                                                              20.0,
                                                                              10.0,
                                                                              20.0,
                                                                              10.0),
                                                                          child:
                                                                              const Text("Save"))),
                                                                ],
                                                              ),
                                                            ],
                                                          ));
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              size: 24,
                                            )),
                                        InkWell(
                                            onTap: () async {
                                              var key = keyupcoming[index];
                                              await referenceDatabase
                                                  .child(key)
                                                  .remove();
                                              keyupcoming.removeAt(index);
                                              loadSalesData();
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              size: 24,
                                            )),
                                      ],
                                    )),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
              );
            }),
      ],
    );
  }

}
