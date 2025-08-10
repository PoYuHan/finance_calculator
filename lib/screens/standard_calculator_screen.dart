import 'package:flutter/material.dart';

// 【新概念】StatefulWidget：
// 這是一種可以「擁有狀態」的 Widget。我們的計算機需要記住使用者當前輸入的數字，
// 所以它的狀態是會改變的，必須使用 StatefulWidget。
// 這就像一塊可以擦寫的「白板」，而不是一張印死的「海報」(StatelessWidget)。
class StandardCalculatorScreen extends StatefulWidget {
  const StandardCalculatorScreen({super.key});

  @override
  State<StandardCalculatorScreen> createState() => _StandardCalculatorScreenState();
}

class _StandardCalculatorScreenState extends State<StandardCalculatorScreen> {
  // region 狀態變數 (State Variables) - 這些是計算機的「記憶」
  String _output = '0'; // 私有變數，儲存螢幕上要顯示的內容
  String _currentInput = '0'; // 當前正在輸入的數字
  double _operand1 = 0; // 運算元一
  String? _operator; // 運算子 (用 ? 表示它可能為空)
  // endregion

  // 【核心邏輯】處理所有按鈕點擊事件的方法
  void _onButtonPressed(String buttonText) {
    // 【新概念】setState()：
    // 這是 StatefulWidget 的心臟！每當我們需要更新畫面時 (例如改變螢幕上的數字)，
    // 我們必須把改變狀態的程式碼放在 setState(...) 的大括號裡。
    // 這會告訴 Flutter：「嘿！資料變了，快去重繪畫面！」
    setState(() {
      if ('0123456789'.contains(buttonText)) {
        // --- 處理數字按鈕 ---
        if (_currentInput == '0') {
          _currentInput = buttonText;
        } else {
          _currentInput += buttonText;
        }
      } else if (buttonText == '.') {
        // --- 處理小數點 ---
        if (!_currentInput.contains('.')) {
          _currentInput += '.';
        }
      } else if ('+-×÷'.contains(buttonText)) {
        // --- 處理運算子 ---
        _operand1 = double.parse(_currentInput);
        _operator = buttonText;
        _currentInput = '0'; // 準備接收下一個數字
      } else if (buttonText == '=') {
        // --- 處理等於 ---
        if (_operator != null) {
          double operand2 = double.parse(_currentInput);
          switch (_operator) {
            case '+':
              _operand1 += operand2;
              break;
            case '-':
              _operand1 -= operand2;
              break;
            case '×':
              _operand1 *= operand2;
              break;
            case '÷':
              _operand1 /= operand2;
              break;
          }
          _currentInput = _operand1.toString();
          _operator = null; // 清除運算子，準備下一次計算
        }
      } else if (buttonText == 'AC') {
        // --- 處理全部清除 ---
        _currentInput = '0';
        _operand1 = 0;
        _operator = null;
      } else if (buttonText == '+/-') {
        // --- 處理正負號 ---
        if (_currentInput != '0') {
          if (_currentInput.startsWith('-')) {
            _currentInput = _currentInput.substring(1);
          } else {
            _currentInput = '-$_currentInput';
          }
        }
      } else if (buttonText == '%') {
        // --- 處理百分比 ---
        double value = double.parse(_currentInput);
        _currentInput = (value / 100).toString();
      }

      // 無論如何，最後都將當前輸入更新到螢幕輸出
      _output = _currentInput;
      // 讓輸出更美觀，如果結尾是 .0 就去掉它
      if (_output.endsWith('.0')) {
        _output = _output.substring(0, _output.length - 2);
      }
    });
  }

  // --- UI 介面部分 (這部分跟之前幾乎一樣) ---
  @override
  Widget build(BuildContext context) {
    final List<String> buttons = [
      'AC', '+/-', '%', '÷',
      '7', '8', '9', '×',
      '4', '5', '6', '-',
      '1', '2', '3', '+',
      '0', '.', '=',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('一般計算機'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24.0),
              child: Text(
                _output, // 顯示 _output 變數的內容
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: buttons.length,
              itemBuilder: (BuildContext context, int index) {
                final buttonText = buttons[index];
                return CalculatorButton(
                  text: buttonText,
                  onPressed: () => _onButtonPressed(buttonText), // 呼叫我們的邏輯方法
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 自訂按鈕 Widget (這部分完全沒變)
class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 根據按鈕類型給予不同顏色，增加美觀
    Color getButtonColor() {
      if ('+-×÷='.contains(text)) {
        return Colors.orange;
      }
      if ('AC+/-'.contains(text)) {
        return Colors.grey[700]!;
      }
      return Colors.blueGrey[800]!;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: getButtonColor(),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      child: Text(text),
    );
  }
}