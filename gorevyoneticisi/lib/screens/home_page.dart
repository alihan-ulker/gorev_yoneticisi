//@dart=2.9
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gorevyoneticisi/model/event.dart';
import 'package:gorevyoneticisi/screens/add_event.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();

  DateTime focusedDay = DateTime.now();
  final db = FirebaseFirestore.instance;

  //Fetch events from Firebase.
  Future<List<Event>> getEvent() async {
    QuerySnapshot snapshot =
        await db.collection("events").where("eventdate").get();
    snapshot.docs.forEach((doc) {
      print(doc.data);
    });
  }

  getDate() async {
    var snapshot = await db.collection("events").where("eventdate").get();

    snapshot.docs.forEach((element) {
      Timestamp timestamp = element.data()["eventdate"];

      if (timestamp.toDate().day == focusedDay.day) {
        print("seçili gün");
        List<Event> events =
            snapshot.docs.map((doc) => Event.createDoc(doc)).toList();
      } else {
        print("focus");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    //getDate();
  }

  //Exit button Alert dialog settings
  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text("İptal"),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = TextButton(
      child: const Text("Çıkış"),
      onPressed: () => exit(0),
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Çıkış"),
      content: const Text("Çıkmak istediğinize emin misiniz?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Görev Yöneticisi"),
        //Back button cancel
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => showAlertDialog(context),
            icon: const Icon(Icons.close),
            tooltip: "Çıkış",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              //Calendar settings
              TableCalendar(
                focusedDay: selectedDay,
                //calendar date range
                firstDay: DateTime(1990),
                lastDay: DateTime(2050),
                calendarFormat: format,
                //calendar location
                locale: 'tr_TR',
                onFormatChanged: (CalendarFormat _format) {
                  setState(() {
                    format = _format;
                  });
                },
                //First day of the week setting
                startingDayOfWeek: StartingDayOfWeek.monday,
                daysOfWeekVisible: true,

                //Day Changed
                onDaySelected: (DateTime selectDay, DateTime focusDay) async {
                  setState(() {
                    selectedDay = selectDay;
                    focusedDay = focusDay;
                  });
                  //get firebase date values
                  var snapshot =
                      await db.collection("events").where("eventdate").get();

                  //firebase timestamp to datetime
                  //get firebase eventdate values
                  snapshot.docs.forEach((element) {
                    Timestamp timestamp = element.data()["eventdate"];
                    //timestamp to day value
                    if (timestamp.toDate().day == focusedDay.day) {
                      print("Selected Day");
                      print("Selected day have a event");
                    }
                  });
                },
                selectedDayPredicate: (DateTime date) {
                  return isSameDay(selectedDay, date);
                },

                //To style the Calendar
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.white),
                  todayDecoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  defaultDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  weekendDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.red),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  formatButtonTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              StreamBuilder<QuerySnapshot>(
                stream: db.collection("events").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  //firebase values to list
                  List<Event> events = snapshot.data.docs
                      .map((doc) => Event.createDoc(doc))
                      .toList();

                  return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      shrinkWrap: true,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot myevent = snapshot.data.docs[index];
                        //Delete button setting
                        Future<void> _showChoiseDialog(BuildContext context) {
                          return showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    title: const Text(
                                      "Silmek istediğinize emin misiniz?",
                                      textAlign: TextAlign.center,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0))),
                                    content: Container(
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            GestureDetector(
                                              //Firebase delete event
                                              onTap: () async {
                                                db
                                                    .collection("events")
                                                    .doc(myevent.id)
                                                    .delete();
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                "Evet",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                "Vazgeç",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        )));
                              });
                        }

                        //List events
                        return ListTile(
                          title: Text(events[index].title),
                          subtitle: Text(events[index].description),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showChoiseDialog(context)),
                        );
                      });
                },
              ),
            ],
          ),
        ),
      ),

      //Task add button settings
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        tooltip: "Görev Ekle",
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddEventPage())),
      ),
    );
  }
}
