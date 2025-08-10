import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 引入我們剛剛新增的數字格式化套件
import 'dart:math'; // 引入 Dart 的數學函式庫，我們需要用它來做次方運算

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  // 控制器們
  final _loanAmountController = TextEditingController();
  final _rateController = TextEditingController();
  final _yearsController = TextEditingController();
  final _graceYearsController = TextEditingController();

  // 狀態變數
  bool _hasGracePeriod = false; // 用來控制寬限期開關的狀態
  String _resultSummary = '';   // 用來顯示結果摘要

  // 計算邏輯，暫時留空
void _calculate() {
    // 1. 讀取並驗證所有可能的輸入值
    final double? loanAmount = double.tryParse(_loanAmountController.text);
    final double? annualRate = double.tryParse(_rateController.text);
    final int? totalYears = int.tryParse(_yearsController.text);
    final int? graceYears = _hasGracePeriod ? int.tryParse(_graceYearsController.text) : 0;

    // 基礎驗證
    if (loanAmount == null || annualRate == null || totalYears == null) {
      setState(() {
        _resultSummary = '請輸入有效的貸款金額、利率及年期。';
      });
      return;
    }
    // 如果有寬限期，則 graceYears 也必須是有效數字
    if (_hasGracePeriod && graceYears == null) {
      setState(() {
        _resultSummary = '請輸入有效的寬限期長度。';
      });
      return;
    }
    // 寬限期不能長於或等於總年期
    if (_hasGracePeriod && graceYears! >= totalYears) {
      setState(() {
        _resultSummary = '寬限期長度必須小於總貸款年期。';
      });
      return;
    }

    // 2. 準備計算參數
    final monthlyRate = (annualRate / 100) / 12; // 月利率
    final formatter = NumberFormat('#,##0', 'en_US');
    String summary = '';

    // 3. 核心計算邏輯
    if (!_hasGracePeriod) {
      // --- 情況一：無寬限期 ---
      final totalMonths = totalYears * 12;
      // M = P * [r(1+r)^n] / [(1+r)^n - 1]
      final monthlyPayment = loanAmount * (monthlyRate * pow(1 + monthlyRate, totalMonths)) / (pow(1 + monthlyRate, totalMonths) - 1);
      final totalPayment = monthlyPayment * totalMonths;
      final totalInterest = totalPayment - loanAmount;

      summary = '每月應付金額: ${formatter.format(monthlyPayment)} 元\n'
                '總還款金額: ${formatter.format(totalPayment)} 元\n'
                '總利息支出: ${formatter.format(totalInterest)} 元';
    } else {
      // --- 情況二：有寬限期 ---
      // 寬限期內的月付利息
      final gracePeriodPayment = loanAmount * monthlyRate;
      
      // 寬限期後的剩餘還款期數
      final remainingYears = totalYears - graceYears!;
      final remainingMonths = remainingYears * 12;
      
      // 寬限期後的每月本息攤還金額
      final postGraceMonthlyPayment = loanAmount * (monthlyRate * pow(1 + monthlyRate, remainingMonths)) / (pow(1 + monthlyRate, remainingMonths) - 1);
      
      // 計算總還款金額
      final totalGracePayment = gracePeriodPayment * (graceYears * 12);
      final totalPostGracePayment = postGraceMonthlyPayment * remainingMonths;
      final totalPayment = totalGracePayment + totalPostGracePayment;
      final totalInterest = totalPayment - loanAmount;

      summary = '寬限期間 (第1-${graceYears}年):\n'
                '  每月應付利息: ${formatter.format(gracePeriodPayment)} 元\n\n'
                '本息攤還期間 (第${graceYears + 1}-${totalYears}年):\n'
                '  每月應付金額: ${formatter.format(postGraceMonthlyPayment)} 元\n\n'
                '總計:\n'
                '  總還款金額: ${formatter.format(totalPayment)} 元\n'
                '  總利息支出: ${formatter.format(totalInterest)} 元';
    }
    
    // 4. 更新畫面
    setState(() {
      _resultSummary = summary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('貸款計算機'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _loanAmountController,
              decoration: const InputDecoration(
                labelText: '總借款金額 (元)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rateController,
              decoration: const InputDecoration(
                labelText: '貸款年利率 (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _yearsController,
              decoration: const InputDecoration(
                labelText: '貸款年期 (年)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // 【新概念】SwitchListTile:
            // 這是一個非常方便的 Widget，它將一個標題、一個開關整合在一起。
            SwitchListTile(
              title: const Text('是否有寬限期?'),
              value: _hasGracePeriod, // 開關的值綁定到我們的狀態變數
              onChanged: (bool value) {
                // 當使用者切換開關時，更新狀態
                setState(() {
                  _hasGracePeriod = value;
                });
              },
              contentPadding: EdgeInsets.zero, // 移除預設的留白
            ),

            // 【新概念】條件渲染:
            // 我們使用 if (_hasGracePeriod) 來判斷是否要顯示寬限期長度的輸入框。
            // 這是 Flutter 宣告式 UI 的強大之處，UI 會自動根據狀態改變。
            if (_hasGracePeriod)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _graceYearsController,
                  decoration: const InputDecoration(
                    labelText: '寬限期長度 (年)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
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

            // 結果顯示區
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                _resultSummary,
                style: const TextStyle(fontSize: 18, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    _graceYearsController.dispose();
    super.dispose();
  }
}