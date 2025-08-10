import 'package:flutter/material.dart';
import 'dart:math'; // 引入 Dart 的數學函式庫，我們需要用它來做次方運算
import 'package:intl/intl.dart'; // 引入我們剛剛新增的數字格式化套件

class LumpSumCalculatorScreen extends StatefulWidget {
  const LumpSumCalculatorScreen({super.key});

  @override
  State<LumpSumCalculatorScreen> createState() => _LumpSumCalculatorScreenState();
}

class _LumpSumCalculatorScreenState extends State<LumpSumCalculatorScreen> {
  // 【新概念】TextEditingController:
  // 這是文字輸入框的「控制器」。我們需要用它來讀取使用者在輸入框裡填寫的內容。
  // 每個輸入框都需要一個自己的控制器。
  final _principalController = TextEditingController(); // 本金控制器
  final _rateController = TextEditingController();      // 利率控制器
  final _yearsController = TextEditingController();     // 年期控制器

  String _result = ''; // 用來儲存並顯示計算結果的變數

  // 計算按鈕的邏輯，我們先留空，下一步再實作
  void _calculate() {
    // 【核心邏輯】
    // 1. 讀取輸入值並轉換為數字。
    //    double.tryParse 如果轉換失敗 (例如輸入框是空的或非數字)，會回傳 null，這樣 App 才不會崩潰。
    final double? principal = double.tryParse(_principalController.text);
    final double? rate = double.tryParse(_rateController.text);
    final int? years = int.tryParse(_yearsController.text);

    // 2. 驗證輸入：確保所有欄位都有有效的數字。
    if (principal == null || rate == null || years == null) {
      setState(() {
        _result = '請輸入所有有效的數值';
      });
      return; // 終止計算
    }
    
    // 3. 執行財務公式：FV = PV * (1 + r)^n
    //    - 將年利率從百分比轉換為小數 (例如 7% -> 0.07)
    final double monthlyRate = rate / 100;
    //    - 使用 dart:math 的 pow() 函式進行次方運算
    final double futureValue = principal * pow((1 + monthlyRate), years);

    // 4. 格式化輸出，並更新畫面。
    //    - 使用 intl 套件的 NumberFormat 來格式化數字，加上千分位，更易讀。
    final formatter = NumberFormat('#,##0', 'en_US');

    setState(() {
      _result = '在第 $years 年底，\n您的資產總值約為\n${formatter.format(futureValue)} 元';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('單筆投資計算機'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // 【新概念】SingleChildScrollView:
      // 當內容可能超出螢幕高度時 (例如彈出鍵盤)，用它包起來可以讓頁面滾動，避免出錯。
      body: SingleChildScrollView(
        // Padding 在內容周圍增加一些留白，讓版面更好看
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch 讓子元件在水平方向上撐滿
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 【新概念】TextField:
            // 這就是文字輸入框 Widget。
            TextField(
              controller: _principalController, // 綁定本金控制器
              // decoration 用來美化輸入框，例如加上標籤
              decoration: const InputDecoration(
                labelText: '單筆投入本金 (元)',
                border: OutlineInputBorder(),
              ),
              // keyboardType 指定彈出的鍵盤類型，numberWithOptions 更方便使用者輸入數字和小數點
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16), // 間距

            TextField(
              controller: _rateController, // 綁定利率控制器
              decoration: const InputDecoration(
                labelText: '預期年化報酬率 (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _yearsController, // 綁定年期控制器
              decoration: const InputDecoration(
                labelText: '總共年期 (年)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            // 計算按鈕
            ElevatedButton(
              onPressed: _calculate, // 點擊時觸發 _calculate 方法
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('計算'),
            ),
            const SizedBox(height: 32),

            // 顯示結果的區域
            Text(
              _result, // 顯示 _result 變數的內容
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 為了良好的資源管理，當頁面銷毀時，我們需要一併銷毀控制器
  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }
}