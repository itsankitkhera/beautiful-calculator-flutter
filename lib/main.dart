import 'dart:math';
import 'package:flutter/material.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beautiful Calculator',
      theme: ThemeData(
        backgroundColor: Colors.black,
        buttonColor: Colors.black,
        accentColor: Colors.white,
        primaryColor: Colors.teal,
      ),
      home: const MyHomePage(title: 'Beautiful Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    double _result = 0.0;
    String _operation="";

  get math => null;

  void _numberPressed(String number) {
    setState(() {
      _operation+=number;
    });
  }
  void _resetResult() {
    setState(() {
      _operation="0";
      _result=0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                right: 50.0,
                bottom: 50.0,
              ),
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _operation,
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    _result.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 65,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.only(
                  bottom: 40.0,
                  top:40.0),
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex:3,
                          child: ResetButton('C'),
                        ),
                        Expanded(
                          flex: 3,
                          child: ResetButton('CE'),
                        ),
                        Expanded(
                          flex:2,
                          child: OperationsButton('+'),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: numbersButton('1'),
                        ),
                        Expanded(
                          child: numbersButton('2'),
                        ),
                        Expanded(
                          child: numbersButton('3'),
                        ),
                        Expanded(
                          child: OperationsButton('-'),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: numbersButton('4'),
                        ),
                        Expanded(
                          child: numbersButton('5'),
                        ),
                        Expanded(
                          child: numbersButton('6'),
                        ),
                        Expanded(
                          child: OperationsButton('*'),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: numbersButton('7'),
                        ),
                        Expanded(
                          child: numbersButton('8'),
                        ),
                        Expanded(
                          child: numbersButton('9'),
                        ),
                        Expanded(
                          child: OperationsButton('/'),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: numbersButton('0'),
                        ),
                        Expanded(
                          child: numbersButton('.'),
                        ),
                        Expanded(
                          flex: 2,
                          child: EqualButton(),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  MaterialButton numbersButton(String text) {
    return MaterialButton(
      onPressed: () {
        setState(() {
          _operation+=text;
        });
      },
      color: Theme.of(context).buttonColor,
      height: 80.0,
      minWidth: 80.0,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
      textColor: Theme.of(context).accentColor,
    );
  }
  MaterialButton OperationsButton(String text) {
    return MaterialButton(
      onPressed: () {
        setState(() {
          _operation+=text;
        });
      },
      color: Theme.of(context).primaryColor,
      height: 80.0,
      minWidth: 80.0,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
      textColor: Theme.of(context).accentColor,
    );
  }
  MaterialButton EqualButton() {
    return MaterialButton(
      onPressed: () {
        setState(() {
          _result = calcString(_operation);
        });
      },
      color: Theme.of(context).primaryColor,
      height: 80.0,
      child: const Text(
        '=',
        style: const TextStyle(fontSize: 16),
      ),
      textColor: Theme.of(context).accentColor,
    );
  }
  MaterialButton ResetButton(String text) {
      return MaterialButton(
        onPressed: () {
          setState(() {
            _result=0;
            _operation="";
          });
        },
        color: Theme.of(context).buttonColor,
        height: 80.0,
        child: Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
        textColor: Theme.of(context).accentColor,
      );
    }



    Parser buildParser() {
      final builder = ExpressionBuilder();
      builder.group()
        ..primitive(digit()
            .plus()
            .seq(char('.').seq(digit().plus()).optional())
            .flatten()
            .trim()
            .map((a) => num.tryParse(a)))
        ..wrapper(char('(').trim(), char(')').trim(), (String l, num a, String r) => a);
      // negation is a prefix operator
      builder.group()
        ..prefix(char('-').trim(), (String op, num a) => -a);

// power is right-associative
      builder.group()
        ..right(char('^').trim(), (num a, String op, num b) => math.pow(a, b));

// multiplication and addition are left-associative
      builder.group()
        ..left(char('*').trim(), (num a, String op, num b) => a * b)
        ..left(char('/').trim(), (num a, String op, num b) => a / b);
      builder.group()
        ..left(char('+').trim(), (num a, String op, num b) => a + b)
        ..left(char('-').trim(), (num a, String op, num b) => a - b);
      return builder.build().end();
    }

    double calcString(String text) {
      final parser = buildParser();
      final result = parser.parse(text);
      if (result.isSuccess)
        return result.value.toDouble();
      else
        return double.parse(text);
    }
}
