import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({Key? key}) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  late TextEditingController titleController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  DateTime _eventDate = DateTime.now();

  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  late bool processing;
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    //Firebase add event settings
    addEvent() {
      db.collection("events").add({
        "title": titleController.text,
        "description": descriptionController.text,
        "eventdate": _eventDate,
      }).then((value) => print("Görev eklendi."));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Görev Ekle"),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          alignment: Alignment.center,
          child: ListView(
            children: [
              //Title form settings
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: titleController,
                  validator: (value) =>
                      (value!.isEmpty) ? "Başlık boş bırakılamaz!" : null,
                  decoration: InputDecoration(
                    labelText: "Başlık",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

              //Description form settings
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Açıklama kısmı boş bırakılamaz!';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: "Açıklama",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),

              const SizedBox(
                height: 16,
              ),
              //Date Picker settings
              ListTile(
                title: Text(
                  "Tarih",
                  style: TextStyle(fontSize: 24),
                ),
                subtitle: Text(
                  "${_eventDate.day}/${_eventDate.month}/${_eventDate.year}",
                  style: TextStyle(fontSize: 26),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _eventDate,
                    firstDate: DateTime(_eventDate.year - 10),
                    lastDate: DateTime(_eventDate.year + 10),
                  );
                  if (picked != null) {
                    setState(() {
                      _eventDate = picked;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              //Save Button settings
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      addEvent();
                    }
                    Navigator.pop(context);
                    titleController.clear();
                    setState(() {});
                    return;
                  },
                  child: const Text(
                    "Kaydet",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
