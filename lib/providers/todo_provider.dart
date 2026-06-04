import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_model.dart';

const String _boxName = 'todo_box';

final todoListProvider = StateNotifierProvider<TodoNotifier, List<TodoItem>>((
  ref,
) {
  final box = Hive.box<TodoItem>(_boxName);
  return TodoNotifier(box);
});

class TodoNotifier extends StateNotifier<List<TodoItem>> {
  final Box<TodoItem> _box;

  TodoNotifier(this._box) : super([]) {
    _loadTodos();
  }

  void _loadTodos() {
    state = _box.values.toList();
  }

  void addTodo(TodoItem todo) {
    _box.put(todo.id, todo);
    state = [...state, todo];
  }

  void toggleTodo(String id) {
    final todo = state.firstWhere((item) => item.id == id);
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    _box.put(id, updatedTodo);

    state = [
      for (final item in state)
        if (item.id == id) updatedTodo else item,
    ];
  }

  void deleteTodo(String id) {
    _box.delete(id);
    state = state.where((item) => item.id != id).toList();
  }

  void updateTodo(
    String id, {
    required String title,
    required TodoPriority priority,
    required TodoCategory category,
  }) {
    final todo = state.firstWhere((item) => item.id == id);

    // 使用 copyWith 複製並修改屬性
    final updatedTodo = todo.copyWith(
      title: title,
      priority: priority,
      category: category,
    );

    _box.put(id, updatedTodo); // 更新本地資料庫

    // 更新狀態讓 UI 重繪
    state = [
      for (final item in state)
        if (item.id == id) updatedTodo else item,
    ];
  }
}
