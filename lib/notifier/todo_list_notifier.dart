import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:to_do/model/todo_list_state.dart';
import 'package:to_do/repository/todo_list_repository.dart';

part 'todo_list_notifier.g.dart';

@riverpod
class AllDataNotifier extends _$AllDataNotifier {
  @override
  TodoListState build() {
    ref.watch(todoListRepositoryNotifierProvider);
    return TodoListState();
  }

  TextEditingController controller = TextEditingController();

  Future getData() async {
    try {
      List<Map> list = await ref
          .read(todoListRepositoryNotifierProvider.notifier)
          .getItems();
      List<TodoItem> items = [];
      for (int i = 0; i < list.length; i++) {
        items.add(
          TodoItem(
            id: list[i]["id"],
            item: list[i]["item"],
            done: list[i]["done"] == 'true' ? true : false,
          ),
        );
      }
      state = state.copyWith(items: items);
    } catch (e) {}
  }

  changeListView(int index) async {
    if (state.edit) {
      try {
        await ref
            .read(todoListRepositoryNotifierProvider.notifier)
            .updateDoneState(
                state.items[index].done, state.items[index].id.toString());
      } catch (e) {
        print("error in update: $e");
      }
    } else {
      ref
          .read(todoListRepositoryNotifierProvider.notifier)
          .insertTodo(controller.text);
    }
    getData();
  }

  deleteValue(int index) async {
    final id = state.items[index].id;
    ref
        .read(todoListRepositoryNotifierProvider.notifier)
        .deleteValue(id.toString());
    getData();
  }

  makeStrikeThoroughText(int index) async {
    final item = state.items[index];

    await ref
        .read(todoListRepositoryNotifierProvider.notifier)
        .updateDoneState(item.done, item.id.toString());
    getData();
  }

  void updateEditState(bool enable) {
    state = state.copyWith(edit: enable);
  }
}
