import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class Test{
  final int id;
  final String text;

  Test({this.id,this.text});

  Map<String,dynamic> toMap(){
    return{
      'id': id,
      'text':text,
    };
  }

  static Future<Database>get database async{
    final Future<Database>_database=openDatabase(database
    
    join(await getDatabasesPath(),))
  }


}