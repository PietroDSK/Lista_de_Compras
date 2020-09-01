import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var _edProduto = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Compras'),
      ),
      body: _body(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          _showMaterialDialog()
        },
        tooltip: 'Limpar a lista de compras',
        child: Icon(Icons.autorenew),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  _showMaterialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: new Text("Exclusão da Lista"),
          content: new Text("Confirma exclusão de todos os produtos"),
          actions: <Widget>[
            // define os botões na base do dialogo
            new FlatButton(
              child: new Text("sim"),
              onPressed: () {
                setState(() {
                  _produtos.clear();
                });
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("não"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _readData().then((value) => {
          setState(() {
            _produtos = json.decode(value);
          }),
        });
  }

  Column _body(context) {
    return Column(
      children: <Widget>[
        _form(),
        _listagem(context),
      ],
    );
  }

  Container _form() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 2, 5, 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _edProduto,
              decoration: InputDecoration(
                labelText: 'Produto:',
                labelStyle: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          Expanded(
            child: RaisedButton(
                color: Colors.blue,
                child: Text('Adicionar'),
                textColor: Colors.white,
                onPressed: () {
                  _addProduto();
                }),
          ),
        ],
      ),
    );
  }

  _addProduto() {
    String produto = _edProduto.text;

    var novoProduto = new Map();

    novoProduto['nome'] = produto;
    novoProduto['ok'] = false;

    setState(() {
      _produtos.add(novoProduto);
      _edProduto.text = '';
    });
  }

  List _produtos = [];

  _listagem(context) {
    return Expanded(
      child: ListView.builder(
        itemCount: _produtos.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(_produtos[index]['nome']),
            value: _produtos[index]['ok'],
            onChanged: (bool value) {
              setState(() {
                _produtos[index]['ok'] = value;
              });
              _saveData();
            },
          );
        },
      ),
    );
  }

  Future<File> _getFile() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    return File(appDocPath + '/compras.json');
  }

  Future<File> _saveData() async {
    String compras = json.encode(_produtos);

    final file = await _getFile();
    return file.writeAsString(compras);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (error) {
      print('Erro na leitura do arquivo ${error.toString()}');
    }
  }
}
