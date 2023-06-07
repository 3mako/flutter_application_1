import 'package:flutter/material.dart';

void main() {
  runApp(MemoApp());
}

class Memo {
  final String id;
  final String content;

  Memo(this.id,this.content);
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

class _MemoListScreenState extends State<MemoListScreen> with SingleTickerProviderStateMixin {
  List<Memo> memos = [];
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memo App'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),


      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: memos.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(memos[index].id),
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
                        memos[index].content,
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
          Center(child: Text('ロスの内容')),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMemoDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple, // 追加ボタンの背景色
      ),


      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(color:const Color.fromARGB(255, 136, 106, 188),
         child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.home), text: 'ホーム'),
            Tab(icon: Icon(Icons.delete), text: 'ロス'),
          ],
        ),
        ),
       
        )
      );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Settings"),
        );
      },
    );
  }

  void _navigateToMemoDetail(BuildContext context, int index) async {
    final editedMemo = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoDetailScreen(memo: memos[index].content),
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
          title: Text('追加'),
          content: TextField(
            onChanged: (value) {
              newMemo = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  String id = DateTime.now().millisecondsSinceEpoch.toString();
                  memos.add(Memo(id,newMemo));
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
          onChanged: (value) {},
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveMemo,
        child: Icon(Icons.check),
      ),
    );
  }

  void _saveMemo() {
    final editedMemo = _textEditingController.text;
    Navigator.pop(context, editedMemo);
  }
}
