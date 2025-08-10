// 引入 Flutter 的材料設計函式庫，這是我們所有 UI 元件的來源
import 'package:flutter/material.dart';
import 'screens/standard_calculator_screen.dart';
import 'screens/lump_sum_calculator_screen.dart';
import 'screens/recurring_investment_calculator_screen.dart';

// main 函式是我們 App 的入口點，就像房子的總開關
void main() {
  // runApp 告訴 Flutter 運行我們的 App，並將 MyApp 這個 Widget 作為根元件
  runApp(const MyApp());
}

// MyApp 是我們整個 App 的最外層框架
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp 是建立 App 的基礎，它提供了許多基本功能，如導航、主題等
    return MaterialApp(
      // App 的標題，在手機的任務管理器中會看到
      title: '萬能財務計算機',
      // 設定 App 的主色調
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home 指定 App 打開後看到的第一個畫面
      home: const MainMenuScreen(),
    );
  }
}

// MainMenuScreen 是我們的主選單畫面
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold 是一個頁面的基本骨架，包含了標題欄、背景等
    return Scaffold(
      // appBar 是頁面頂部的標題欄
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('萬能財務計算機'),
      ),
      // body 是頁面的主要內容區域
      body: Center( // Center 讓它的子元件在畫面上置中
        // Column 讓它的子元件從上到下垂直排列
        child: Column(
          // mainAxisAlignment 讓子元件在垂直方向上盡量散開並置中
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ElevatedButton 是一個有立體感的按鈕
            ElevatedButton(
              onPressed: () {
                                // 【新概念】Navigator.push：
                // 這是 Flutter 的導航方法，像在書本上疊加一頁新的紙一樣，
                // 將新的頁面 (StandardCalculatorScreen) 推到畫面上方。
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StandardCalculatorScreen()),
                );
              },
              child: const Text('一般計算機'),
            ),
            const SizedBox(height: 20), // SizedBox 用來在按鈕之間製造一些間距

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecurringInvestmentCalculatorScreen()),
              );
              },
              child: const Text('定期定額終值計算機'),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LumpSumCalculatorScreen()),
                );
              },
              child: const Text('單筆終值計算機'),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // TODO: 導航到貸款利率計算機
              },
              child: const Text('貸款利率計算機'),
            ),
          ],
        ),
      ),
    );
  }
}