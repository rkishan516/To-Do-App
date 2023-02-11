import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:to_do/model/todo_list_state.dart';
import 'package:to_do/notifier/todo_list_notifier.dart';

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;

  MySliverAppBar({required this.expandedHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    getTodo() async {
      await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return Consumer(builder: (context, ref, child) {
              final allData = ref.watch(allDataNotifierProvider.notifier);
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
                        allData.updateEditState(false);
                      }
                      allData.controller.text = "";
                      Navigator.pop(context);
                    },
                    child: const Text('cancel'),
                  ),
                ],
              );
            });
          });
    }

    //Data from Provider

    //Suffix for Date
    int date = int.parse(DateFormat('d').format(DateTime.now()));
    String suffix = "th";
    int digit = date % 10;
    if ((digit > 0 && digit < 4) && (date < 11 || date > 13)) {
      suffix = ["st", "nd", "rd"][digit - 1];
    }

    //Sliver App Bar
    return Consumer(builder: (context, ref, child) {
      TodoListState allData = ref.watch(allDataNotifierProvider);
      return Card(
        elevation: 5.0,
        color: Colors.white70,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Opacity(
              opacity: 1 - shrinkOffset / expandedHeight,
              child: Container(
                padding: EdgeInsets.only(left: 30.0),
                child: Row(
                  children: <Widget>[
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text:
                                '${DateFormat('EEEE, ').format(DateTime.now())}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 32.0,
                                color: Colors.blue)),
                        TextSpan(
                            text:
                                '${DateFormat("d'$suffix'\n\n").format(DateTime.now())}',
                            style:
                                TextStyle(fontSize: 32.0, color: Colors.blue)),
                        TextSpan(
                            text:
                                '${DateFormat('MMMM').format(DateTime.now())}',
                            style:
                                TextStyle(fontSize: 22.0, color: Colors.grey)),
                      ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 35.0),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: '${allData.items.length} ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.grey)),
                          TextSpan(
                              text: 'Tasks',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.grey)),
                        ]),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Center(
              child: Opacity(
                opacity: shrinkOffset / expandedHeight,
                child: Text(
                  "To-Do App",
                  style: TextStyle(
                    color: Colors.red[300],
                    fontWeight: FontWeight.w700,
                    fontSize: 23,
                  ),
                ),
              ),
            ),
            Positioned(
              top: expandedHeight / 1.25 - shrinkOffset,
              left: MediaQuery.of(context).size.width / 1.45,
              child: Opacity(
                opacity: (1 - shrinkOffset / expandedHeight),
                child: InkWell(
                  child: CircleAvatar(
                    child: Icon(
                      Icons.add,
                      size: (30 - shrinkOffset > 0) ? 30 - shrinkOffset : 0,
                    ),
                    radius: (30 - shrinkOffset > 0) ? 30 - shrinkOffset : 0,
                  ),
                  onTapDown: (_) {
                    ref
                        .read(allDataNotifierProvider.notifier)
                        .updateEditState(false);
                    getTodo();
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
