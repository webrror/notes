import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/crud.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        primaryColor: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // All notes
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _note = [];

  bool _isLoading = true;
  bool _isEmpty = false;

  Color? color;

  TextEditingController title = TextEditingController();
  TextEditingController note = TextEditingController();

  @override
  void initState() {
    fetchAllNotes();
    super.initState();
  }

  void fetchAllNotes() async {
    final data = await Crud.getNotes();
    setState(() {
      _notes = data;
      if (data.isNotEmpty) {
        _isLoading = false;
        _isEmpty = false;
      } else {
        _isEmpty = true;
      }
    });
  }

  void fetchNote(int id) async {
    final data = await Crud.getNote(id);
    setState(() {
      _note = data;
    });
  }

  void createNote() async {
    await Crud.createNote(title.text, note.text);
    fetchAllNotes();
  }

  void updateNote(int id) async {
    await Crud.updateNote(id, title.text, note.text);
    fetchAllNotes();
  }

  void deleteNote(int id) async {
    await Crud.deleteNote(id);
    fetchAllNotes();
  }

  void deleteAllNotes() async {
    await Crud.deleteAllNotes();
    fetchAllNotes();
  }

  showFormSheet(int? id) {
    if (id != null) {
      final existingNote = _notes.firstWhere((element) => element["id"] == id);
      title.text = existingNote["title"];
      note.text = existingNote["note"];
    }
    if (id == null) {
      title.text = '';
      note.text = '';
    }
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      isScrollControlled: true,
      elevation: 2,
      context: context,
      barrierColor: Colors.black87,

      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      id == null ? 'Create a new note' : 'Update note',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                        padding: EdgeInsets.zero,
                        width: 30,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(FluentIcons.dismiss_20_filled),
                          padding: EdgeInsets.zero,
                          //constraints: const BoxConstraints(),
                        ))
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                    controller: title,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    textInputAction: TextInputAction.next),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                    controller: note,
                    minLines: 4,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        labelText: 'Your note',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    textInputAction: TextInputAction.done),
                const SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                          //backgroundColor: Theme.of(context).primaryColor,
                          // foregroundColor:
                          // Theme.of(context).primaryIconTheme.color,
                          minimumSize: const Size(100, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        if (id == null) {
                          createNote();
                          title.text = '';
                          note.text = '';
                          Navigator.pop(context);
                        }
                        if (id != null) {
                          updateNote(id);
                          title.text = '';
                          note.text = '';
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        id == null ? 'Create' : 'Update',
                        //style: TextStyle(color: Theme.of(context).textTheme.headlineSmall!.color),
                      ),
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  showAlertDialog() {
    // created method
    showDialog(
      //barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text("You'll lose all your notes"),
          actionsPadding: const EdgeInsets.all(15),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  deleteAllNotes();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ))
          ],
        );
      },
    );
  }

  void showNoteInBottomSheet(int id) async {
    fetchNote(id);
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      isScrollControlled: true,
      elevation: 2,
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.95,
          child: Container(
            //height: MediaQuery.of(context).size.height - topPadding,
            padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.zero,
                    width: 30,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        FluentIcons.dismiss_24_regular,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _note[0]['title'],
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _note[0]['note'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal),
                    textAlign: TextAlign.start,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
                onPressed: _isEmpty
                    ? null
                    : () {
                  showAlertDialog();
                },
                //onPressed:  null,
                child: const Text('Delete all')),
          ),
        ],
      ),
      body: _isEmpty
          ? const Center(
        child: Text('No notes found'),
      )
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2),
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        itemBuilder: (context, index) {
          return InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              showNoteInBottomSheet(_notes[index]['id']);
            },
            child: Card(
              //color: Colors.indigo[50],
              //color: Colors.primaries[Random().nextInt(Colors.accents.length)],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      _notes[index]['title'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      _notes[index]['note'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            onPressed: () {
                              showFormSheet(_notes[index]['id']);
                            },
                            icon: Icon(
                              FluentIcons.pen_20_regular,
                              color: Theme.of(context).primaryColor,
                            )),
                        IconButton(
                            onPressed: () {
                              deleteNote(_notes[index]['id']);
                            },
                            icon: const Icon(
                              FluentIcons.delete_20_regular,
                              color: Colors.red,
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: _notes.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormSheet(null);
        },
        child: const Icon(FluentIcons.add_20_regular),
      ),
    );
  }
}
