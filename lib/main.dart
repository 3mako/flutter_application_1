import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/memo_table_sc.dart';
import 'package:path/path.dart';
import 'models/memo.dart';
import 'screens/memo_table_sc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final memoModel = MemoModel();
  await memoModel.init();

  runApp(MemoApp(memoModel: memoModel));
}

class Memo {
  final String id;
  final String content;

  Memo(this.id, this.content);
}

class MemoApp extends StatelessWidget {
  final MemoModel memoModel;

  const MemoApp({required this.memoModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '食品ロス',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      home: MemoListScreen(memoModel: memoModel),
    );
  }
}

class MemoListScreen extends StatefulWidget {
  final MemoModel memoModel;

  const MemoListScreen({required this.memoModel});

  @override
  _MemoListScreenState createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen>
    with SingleTickerProviderStateMixin {
  List<Memo> memos = [];
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final memos = await widget.memoModel.getMemos();
    setState(() {
      this.memos = memos
          .map((memo) => Memo(memo[MemoModel.columnId], memo[MemoModel.columnContent]))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memo App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context);
            },
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  _deleteMemo(index);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(
                        memos[index].content,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Created: ${DateTime.now().toString()}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      trailing: const Icon(
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
          const Center(child: Text('ロスの内容')),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMemoDialog(context);
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          color: const Color.fromARGB(255, 136, 106, 188),
          child: TabBar(
            controller: _tabController,
            tabs: [
              const Tab(icon: Icon(Icons.home), text: 'ホーム'),
              const Tab(icon: Icon(Icons.delete), text: 'ロス'),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Settings"),
          actions: [
            TextButton(
              onPressed: () {
                _showAddCategoryDialog(dialogContext);
              },
              child: Text('カテゴリ追加'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoListScreen2(memoModel: widget.memoModel),
                  ),
                );
              },
              child: Text('DB閲覧'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String categoryName = '';
        return AlertDialog(
          title: const Text('追加'),
          content: TextField(
            onChanged: (value) {
              categoryName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Perform the necessary operations with the category name
                // For example, save it to the database or perform any other logic
                print('Category Name: $categoryName');
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
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
    ) as String?;

    if (editedMemo != null) {
      await widget.memoModel.updateMemo(memos[index].id, editedMemo);
      _loadMemos();
    }
  }

  void _showAddMemoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String newMemo = '';
        return AlertDialog(
          title: const Text('追加'),
          content: TextField(
            onChanged: (value) {
              newMemo = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                await widget.memoModel.addMemo(id, newMemo);
                _loadMemos();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMemo(int index) async {
    await widget.memoModel.deleteMemo(memos[index].id);
    _loadMemos();
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
        title: const Text('Memo Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _textEditingController,
          onChanged: (value) {},
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveMemo(context);
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  void _saveMemo(BuildContext context) {
    final editedMemo = _textEditingController.text;
    Navigator.pop(context, editedMemo);
  }
}
