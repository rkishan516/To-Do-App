import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do/notifier/todo_list_notifier.dart';
import 'MySliverHeader.dart';

void main() => runApp(
      ProviderScope(
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TO-DO APP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'TO-DO APP'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  MyHomePage({super.key, required this.title});
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final allData = ref.watch(allDataNotifierProvider);
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
                      onPressed: () {
                        ref
                            .watch(allDataNotifierProvider.notifier)
                            .makeStrikeThoroughText(index);
                      },
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red[300],
                      onPressed: () {
                        ref
                            .watch(allDataNotifierProvider.notifier)
                            .deleteValue(index);
                      },
                    ),
                    title: Text(
                      '${allData.items[index].item}',
                      style: TextStyle(
                        decoration: allData.items[index].done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    onTap: () {
                      ref
                          .read(allDataNotifierProvider.notifier)
                          .updateEditState(true);
                      ref
                          .read(allDataNotifierProvider.notifier)
                          .controller
                          .text = allData.items[index].item;
                      getTodo();
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

  getTodo() async {
    final allData = ref.read(allDataNotifierProvider.notifier);
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
              OutlinedButton(
                onPressed: () async {
                  await allData.changeListView(0);
                  allData.controller.text = "";
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
              OutlinedButton(
                onPressed: () {
                  if (ref.read(allDataNotifierProvider).edit) {
                    ref
                        .read(allDataNotifierProvider.notifier)
                        .updateEditState(false);
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
