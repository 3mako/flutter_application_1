import 'package:flutter/material.dart';

void main() {
  runApp(MemoApp());
}

class MemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '食品ロス',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      home: MemoListScreen(),
    );
  }
}

class MemoListScreen extends StatefulWidget {
  @override
  _MemoListScreenState createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  List<String> memos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memo App'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog();
              // メニューなどの設定画面に遷移する処理を追加
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: memos.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(memos[index]),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (direction) {
              _deleteMemo(index);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(
                    memos[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Created: ${DateTime.now().toString()}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.deepPurple,
                  ),
                  onTap: () {
                    _navigateToMemoDetail(context, index);
                  },
                ),
              ),
            ),
          );
        },
      ),



      floatingActionButton: ElevatedButton.icon(
        onPressed: () {
          _showAddMemoDialog(context);
        },
        icon: Icon(Icons.add),
        label: Text("食材を追加"),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          primary: Colors.deepPurple,
          onPrimary: Colors.white,
        ),
       
      ),



    );
  }

  void _showSettingsDialog(){
    showDialog(
      context: context,
     builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Settings"),

      );
    }
    );   
  }

  void _navigateToMemoDetail(BuildContext context, int index) async {
    final editedMemo = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoDetailScreen(memo: memos[index]),
      ),
    );

    if (editedMemo != null) {
      setState(() {
        memos[index] = editedMemo;
      });
    }
  }

  void _showAddMemoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newMemo = '';
        return AlertDialog(
          title: Text('Add Memo'),
          content: TextField(
            onChanged: (value) {
              newMemo = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  memos.add(newMemo);
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMemo(int index) {
    setState(() {
      memos.removeAt(index);
    });
  }
}

class MemoDetailScreen extends StatefulWidget {
  final String memo;

  const MemoDetailScreen({required this.memo});

  @override
  _MemoDetailScreenState createState() => _MemoDetailScreenState();
}

class _MemoDetailScreenState extends State<MemoDetailScreen> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.memo);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memo Detail'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: TextField(
          controller: _textEditingController,
          onChanged: (value) {
            // メモ内容が変更された場合の処理を追加
          },
        ),
      ),


      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveMemo();
        },
        child: Icon(Icons.check),
      ),





    );
  }

  void _saveMemo() {
    final editedMemo = _textEditingController.text;
    Navigator.pop(context, editedMemo);
  }
}