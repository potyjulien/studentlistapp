import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liste de présence',
      home: new StudentList(title: 'Liste d\'élèves')
    );
  }
}

class StudentList extends StatefulWidget {

  //final List<Student> students;
  final Set<Student> missing = Set<Student>();
  final String title;

  StudentList({Key key, this.title}) : super(key: key);

  @override
  StudentListState createState() => StudentListState();
}

class StudentListState extends State<StudentList> {

  final TextStyle biggerFont = TextStyle(fontSize: 18.0);

  Future<List<Student>> _getStudents() async {
    
    var data = await DefaultAssetBundle.of(context).loadString('assets/classe.json');
    var jsonData = json.decode(data.toString());

    List<Student> students = [];

    for(var s in jsonData){
      Student student = Student(s["prenom"],s["nom"]);
      students.add(student);
    }

    return students;
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title,
            style: new TextStyle(color: Colors.white),),
          actions: <Widget>[IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),],
        ),

        body: Container(
          child: FutureBuilder(
            future: _getStudents(),
            builder: (BuildContext context, AsyncSnapshot snapshot){

              if(snapshot.data == null){
                return Container(
                  child: Center(
                    child: Text("Loading...")
                  )
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index){
                    final bool alreadySaved = widget.missing.contains(snapshot.data[index]);

                    return ListTile(
                        title: Text(snapshot.data[index].lastName + " " + snapshot.data[index].firstName),
                        trailing: Icon(
                          alreadySaved ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color :alreadySaved ? Colors.red : null,
                        ),
                        onTap: () {
                          setState(() {
                            if (alreadySaved) {
                              widget.missing.remove(snapshot.data[index]);
                            } else {
                              widget.missing.add(snapshot.data[index]);
                            }
                          });
                        },
                    );
                  },
                );
              }

            }
          )
        )
    );
  }

  void _pushSaved(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context){

          final Iterable<ListTile> tiles = widget.missing.map(
            (Student student){
              return ListTile(
                title: Text(
                  student.lastName + " " + student.firstName,
                  style: biggerFont,
                ),
              );
            },
          );

          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          void _removeStudent(Student student) {
            divided.remove(student);
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.missing.length.toString() + ' Absent' + (widget.missing.length > 1 ? "s" : "")),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}

class Student{
  final String firstName;
  final String lastName;

  String _asString;

  Student(this.firstName, this.lastName) {
    if (firstName == null || lastName == null) {
      throw ArgumentError("Words of WordPair cannot be null. "
          "Received: '$firstName', '$lastName'");
    }
    if (firstName.isEmpty || lastName.isEmpty) {
      throw ArgumentError("Words of WordPair cannot be empty. "
          "Received: '$firstName', '$lastName'");
    }
  }

  String get asString => _asString ??= '$lastName$firstName';

  @override
  int get hashCode => asString.hashCode;

  bool operator ==(Object other) {
    if (other is Student) {
      return firstName == other.firstName && lastName == other.lastName;
    } else {
      return false;
    }
  }
}