import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart'; // 引入我們剛剛新增的數字格式化套件

// 【新概念】enum (列舉):
// 我們用 enum 來定義一組固定的常數。這裡用來代表「投資頻率」。
// 這樣可以避免直接使用字串 '每月', '每年'，讓程式碼更安全、更清晰。
enum InvestmentFrequency { monthly, yearly }

class RecurringInvestmentCalculatorScreen extends StatefulWidget {
  const RecurringInvestmentCalculatorScreen({super.key});

  @override
  State<RecurringInvestmentCalculatorScreen> createState() =>
      _RecurringInvestmentCalculatorScreenState();
}

class _RecurringInvestmentCalculatorScreenState
    extends State<RecurringInvestmentCalculatorScreen> {
  // 控制器們
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _yearsController = TextEditingController();

  // 狀態變數
  InvestmentFrequency _frequency = InvestmentFrequency.monthly; // 預設頻率為「每月」
  String _result = '';

  // 計算邏輯，暫時留空
void _calculate() {
    // 1. 讀取並驗證輸入值
    final double? amount = double.tryParse(_amountController.text);
    final double? annualRate = double.tryParse(_rateController.text);
    final int? years = int.tryParse(_yearsController.text);

    if (amount == null || annualRate == null || years == null) {
      setState(() {
        _result = '請輸入所有有效的數值';
      });
      return;
    }

    // 2. 根據投資頻率，計算出「每一期的利率 r」和「總期數 n」
    double ratePerPeriod; // 每一期的利率 (r)
    int numberOfPeriods;  // 總期數 (n)

    if (_frequency == InvestmentFrequency.monthly) {
      // 如果是每月投資
      ratePerPeriod = (annualRate / 100) / 12; // 年利率要換算成月利率
      numberOfPeriods = years * 12; // 年期要換算成月數
    } else {
      // 如果是每年投資
      ratePerPeriod = annualRate / 100;
      numberOfPeriods = years;
    }

    // 3. 執行年金終值公式
    double futureValue;
    if (ratePerPeriod == 0) {
      // 如果利率為 0，直接用乘法計算，避免除以零
      futureValue = amount * numberOfPeriods;
    } else {
      // FV = P * [((1 + r)^n - 1) / r]
      futureValue = amount * ((pow(1 + ratePerPeriod, numberOfPeriods) - 1) / ratePerPeriod);
    }
    
    // 4. 格式化輸出並更新畫面
    final formatter = NumberFormat('#,##0', 'en_US');
    final frequencyText = _frequency == InvestmentFrequency.monthly ? '每月' : '每年';

    setState(() {
      _result = 
        '持續 $years 年，\n'
        '$frequencyText投入 ${formatter.format(amount)} 元，\n'
        '在年化報酬率 $annualRate% 的情況下，\n'
        '您的資產總值約為\n'
        '${formatter.format(futureValue)} 元';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('定期定額計算機'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: '定期投入金額 (元)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // 【新概念】DropdownButtonFormField:
            // 這是一個結合了下拉選單和表單欄位優點的 Widget。
            DropdownButtonFormField<InvestmentFrequency>(
              value: _frequency, // 目前選中的值
              decoration: const InputDecoration(
                labelText: '多久存一次',
                border: OutlineInputBorder(),
              ),
              // items 是下拉選單中的所有選項
              items: const [
                DropdownMenuItem(
                  value: InvestmentFrequency.monthly,
                  child: Text('每月'),
                ),
                DropdownMenuItem(
                  value: InvestmentFrequency.yearly,
                  child: Text('每年'),
                ),
              ],
              // onChanged 當使用者選擇新選項時會被觸發
              onChanged: (InvestmentFrequency? newValue) {
                if (newValue != null) {
                  setState(() {
                    _frequency = newValue; // 更新狀態
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _rateController,
              decoration: const InputDecoration(
                labelText: '預期年化報酬率 (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _yearsController,
              decoration: const InputDecoration(
                labelText: '總共年期 (年)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('計算'),
            ),
            const SizedBox(height: 32),

            Text(
              _result,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }
}