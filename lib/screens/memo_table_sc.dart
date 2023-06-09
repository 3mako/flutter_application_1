import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/memo.dart';

class MemoListScreen2 extends StatefulWidget {

  final MemoModel memoModel;

  MemoListScreen2({required this.memoModel});

  @override
  _MemoListScreen2State createState() => _MemoListScreen2State();
}

class _MemoListScreen2State extends State<MemoListScreen2> {

  @override
  void initState() {
    super.initState();
    widget.memoModel.init().then((_) {
      // Force a rebuild after initialization
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memos'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: widget.memoModel.getMemos(),
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            // The future is still running
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Something went wrong
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Success case
          final memos = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Content')),
                
              ],
              rows: memos.map((memo) {
                return DataRow(cells: [
                  DataCell(Text(memo[MemoModel.columnId])),
                  DataCell(Text(memo[MemoModel.columnContent])),
                ]);
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final content = await _showAddMemoDialog();
          if (content != null) {
            // Use the current time as a unique ID
            final id = DateTime.now().millisecondsSinceEpoch.toString();
            await widget.memoModel.addMemo(id, content);
            setState(() {});
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<String?> _showAddMemoDialog() async {
    String? newContent;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a new memo'),
          content: TextField(
            onChanged: (value) {
              newContent = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(newContent),
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
