import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String request = 'https://api.hgbrasil.com/finance?key=4ab24ad8';

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<dynamic> getData() async {
  final http.Response response = await http.get(request);

  return jsonDecode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String _appTitle = '\$ Conversor \$\t';

  final TextEditingController realController = TextEditingController();
  final TextEditingController dolarController = TextEditingController();
  final TextEditingController euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    final double real = double.parse(text);

    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    final double dolar = double.parse(text);

    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    final double euro = double.parse(text);

    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
  }

  Widget _bodyBuild(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
        return const Center(
            child: Text(
          'Carregando dados',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ));

      default:
        if (snapshot.hasError) {
          return const Center(
              child: Text(
            'Erro ao carregar dados',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ));
        }

        dolar = double.parse(
            snapshot.data['results']['currencies']['USD']['buy'].toString());
        euro = double.parse(
            snapshot.data['results']['currencies']['EUR']['buy'].toString());

        return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(Icons.monetization_on, size: 150, color: Colors.amber),
              buildTextField('Reais', 'R\$\t', realController, _realChanged),
              const Divider(),
              buildTextField('Dólares', 'US', dolarController, _dolarChanged),
              const Divider(),
              buildTextField('Euros', '€', euroController, _euroChanged),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_appTitle),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<dynamic>(
        future: getData(),
        builder: _bodyBuild,
      ),
    );
  }
}

//  Retorna um campo de texto
Widget buildTextField(
    String label, String prefix, TextEditingController controller, Function f) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(color: Colors.amber, fontSize: 25),
    onChanged: f,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}
