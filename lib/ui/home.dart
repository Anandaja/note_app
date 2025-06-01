import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_app/service/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final Function(bool) onThemechange;
  Home({super.key, required this.onThemechange});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isdarkmode = false;
  Future<void> _loadthemepreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _isdarkmode = pref.getBool('isdark mode') ?? false;
    });
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isdarkmode = value;
      widget.onThemechange(_isdarkmode);
    });
  }

  List<Map<String, dynamic>> _allnote = [];
  bool _isloadingNote = true;
  final TextEditingController _notetitlecontroller = TextEditingController();
  final TextEditingController _notedescriptioncontroller =
      TextEditingController();

  void _reloadNote() async {
    final note = await QueryHelper.getAllNote();
    setState(() {
      _allnote = note;
      _isloadingNote = false;
    });
  }

  Future<void> _addnote() async {
    await QueryHelper.createnote(
      _notetitlecontroller.text,
      _notedescriptioncontroller.text,
    );
    _reloadNote();
  }

  Future<void> _updateNote(int id) async {
    await QueryHelper.updatenote(
      id,
      _notetitlecontroller.text,
      _notedescriptioncontroller.text,
    );
    _reloadNote();
  }

  void _deletenote(int id) async {
    await QueryHelper.deleteNote(id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Note has been deleted ")));
    _reloadNote();
  }

  void _deleteallnote() async {
    final NoteCount = await QueryHelper.getNoteCount();
    if (NoteCount > 0) {
      await QueryHelper.deleteAllNote();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(" All Note has been deleted "),backgroundColor: _isdarkmode?Colors.grey[600]:Colors.purple));

      _reloadNote();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(" no Note to deleted ")));
    }
  }

  @override
  void initState() {
    super.initState();
    _reloadNote();
    _loadthemepreference();
  }

  void showbottomsheetcontent(int? id) async {
    if (id != null) {
      final currentnote = _allnote.firstWhere((element) => element['id'] == id);
      _notetitlecontroller.text = currentnote['title'];
      _notedescriptioncontroller.text = currentnote['description'];
    }

    showModalBottomSheet(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      isScrollControlled: true,
      context: context,
      builder:
          (_) => SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: 15,
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 15,
                      right: 15,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: _notetitlecontroller,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "note Title",
                          ),
                        ),
                        SizedBox(height: 5),
                         TextField(
                          controller: _notedescriptioncontroller,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Description",
                          ),
                        ),
                        SizedBox(height: 5),
                        Center(
                          child: OutlinedButton(
                            onPressed: () async {
                              if (id == null) {
                                await _addnote();
                              }
                              if (id != null) {
                                await _updateNote(id);
                              }
                              _notetitlecontroller.text = "";
                              _notedescriptioncontroller.text = "";
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              id == null ? "Add Note" : "Update Note",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes",style: TextStyle(fontFamily:'IndieFlower',fontWeight: FontWeight.bold ),),
        actions: [
          IconButton(
            onPressed: () async {
              _deleteallnote();
            },
            icon: Icon(Icons.delete_forever),
          ),
          IconButton(
            onPressed: () async {
              _appexit();
            },
            icon: Icon(Icons.exit_to_app),
          ),
          Transform.scale(
            scale: 0.70,
            child: Switch(
              value: _isdarkmode,
              onChanged: (value) {
                _toggleTheme(value);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child:
            _isloadingNote
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: _allnote.length,
                  itemBuilder:
                      (context, index) => Card(
                        elevation: 5,
                        margin: EdgeInsets.all(16),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    _allnote[index]['title'],
                                    style: TextStyle(
                                      fontFamily: 'IndieFlower',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showbottomsheetcontent(
                                        _allnote[index]['id'],
                                      );
                                    },
                                    icon: Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _deletenote(_allnote[index]['id']);
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Text(
                            _allnote[index]['description'],
                            style:TextStyle(fontFamily:'IndieFlower' ,fontSize: 22),
                          ),
                        ),
                      ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showbottomsheetcontent(null);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _appexit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Exit App"),
          content: Text("Are you sure you want to exit the app"),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("cancel"),
            ),
            OutlinedButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: Text("ok"),
            ),
          ],
        );
      },
    );
  }
}
