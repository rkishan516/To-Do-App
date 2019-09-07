import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'MySliverHeader.dart';
import 'model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TO-DO APP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: ChangeNotifierProvider(
          builder: (BuildContext context) => AllData.instance,
          child: MyHomePage(title: 'TO-DO APP')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    AllData allData = AllData.instance;
    allData.createAndOpenDBAndGetData();
    super.initState();
    Future.delayed(Duration(seconds: 3)).then((onValue) {
      allData.StartingDataFetch(onValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    AllData allData = Provider.of<AllData>(context);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Material(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            delegate: MySliverAppBar(expandedHeight: 200),
            pinned: true,
          ),
          SliverPadding(
            padding: EdgeInsets.all(20.0),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Card(
                  color: Colors.white70,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(20.0),
                    leading: IconButton(
                        icon: const Icon(Icons.strikethrough_s),
                        color: Colors.blue,
                        onPressed: () async {
                          allData.indx = index;
                          await allData.makeStrikeThoroughText();
                        }),
                    trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red[300],
                        onPressed: () async {
                          allData.indx = index;
                          await allData.deleteValue();
                        }),
                    title: Text(
                      '${allData.items[index]}',
                      style: TextStyle(decoration: allData.txtDList[index]),
                    ),
                    onTap: () {
                      allData.edt = true;
                      allData.indx = index;
                      allData.controller.text = allData.items[index];
                      GetTodo(allData);
                    },
                  ),
                );
              },
              childCount: allData.items.length,
            ),
          ),
        ],
      ),
    );
  }

  GetTodo(AllData allData) async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: allData.controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Add item:',
                    ),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () async {
                  await allData.changeListView();
                  allData.controller.text = "";
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
              FlatButton(
                onPressed: () {
                  if (allData.edt) {
                    allData.edt = false;
                  }
                  allData.controller.text = "";
                  Navigator.pop(context);
                },
                child: const Text('cancel'),
              ),
            ],
          );
        });
  }
}
