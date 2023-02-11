import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_list_state.freezed.dart';

@freezed
class TodoListState with _$TodoListState {
  const factory TodoListState({
    @Default(<TodoItem>[]) List<TodoItem> items,
    @Default(false) bool edit,
  }) = _TodoListState;
}

@freezed
class TodoItem with _$TodoItem {
  const factory TodoItem({
    required int id,
    required String item,
    required bool done,
  }) = _TodoItem;
}
