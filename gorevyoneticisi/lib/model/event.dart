//@dart=2.9
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final Timestamp eventdate;

  Event({this.id, this.title, this.description, this.eventdate});

  factory Event.createDoc(DocumentSnapshot doc) {
    return Event(
        id: doc.id,
        title: doc.get("title"),
        description: doc.get("description"),
        eventdate: doc.get("eventdate"));
  }
}
