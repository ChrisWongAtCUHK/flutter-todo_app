import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // 1. 確保 Flutter 綁定完成（非同步操作必備）
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 初始化 Hive（會自動幫你找手機內合適的儲存路徑）
  await Hive.initFlutter();

  // 3. 開啟一個名為 'myBox' 的資料庫（Box）
  var box = await Hive.openBox('myBox');

  // --- CRUD 操作示範 ---

  // 【C - Create】寫入資料 (Key-Value 形式)
  await box.put('name', 'Gemini');
  await box.put('age', 25);

  // 【R - Read】讀取資料
  String name = box.get('name');
  int age = box.get('age');
  debugPrint('=== 讀取初始資料 ===');
  debugPrint('名字: $name, 年齡: $age'); // 輸出: Gemini, 25

  // 【U - Update】更新資料 (重複使用相同的 Key 即可覆蓋)
  await box.put('age', 26);
  debugPrint('=== 讀取更新後的資料 ===');
  debugPrint('新年齡: ${box.get('age')}'); // 輸出: 26

  // 額外技巧：如果找不到 Key，可以設定預設回傳值 (defaultValue)
  var hobby = box.get('hobby', defaultValue: '未填寫');
  debugPrint('嗜好: $hobby'); // 輸出: 未填寫

  // 【D - Delete】刪除資料
  await box.delete('name');
  debugPrint('=== 刪除後的檢查 ===');
  debugPrint('名字還在嗎？: ${box.get('name')}'); // 輸出: null

  // 4. 跑一個最簡單的 App 畫面，避免畫面報錯
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('請看終端機 (Terminal) 的 print 輸出結果！')),
      ),
    ),
  );
}
