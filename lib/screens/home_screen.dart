import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return Colors.redAccent;
      case TodoPriority.medium:
        return Colors.orangeAccent;
      case TodoPriority.low:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoList = ref.watch(todoListProvider);
    final completedCount = todoList.where((t) => t.isCompleted).length;
    final completionRate = todoList.isEmpty
        ? 0.0
        : completedCount / todoList.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '進階工時任務管理',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 頂部統計面板
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '今日進度: $completedCount / ${todoList.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: completionRate,
                      backgroundColor: Colors.grey[200],
                      color: Colors.indigo,
                      minHeight: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 任務列表
          Expanded(
            child: todoList.isEmpty
                ? const Center(child: Text('目前沒有任務，放鬆一下吧！'))
                : ListView.builder(
                    itemCount: todoList.length,
                    itemBuilder: (context, index) {
                      final todo = todoList[index];
                      return Dismissible(
                        key: Key(todo.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          ref
                              .read(todoListProvider.notifier)
                              .deleteTodo(todo.id);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: todo.isCompleted,
                              onChanged: (_) {
                                ref
                                    .read(todoListProvider.notifier)
                                    .toggleTodo(todo.id);
                              },
                            ),
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${todo.category.name.toUpperCase()} · 截止日: ${todo.dueDate.toLocal().toString().split(' ')[0]}',
                            ),
                            trailing: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getPriorityColor(todo.priority),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoBottomSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  // 彈出新增視窗 (精簡版邏輯演示)
  void _showAddTodoBottomSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    TodoPriority selectedPriority = TodoPriority.medium;
    TodoCategory selectedCategory = TodoCategory.work;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '任務名稱',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // 這裡可以延伸加入 DropdownButton 選擇優先度與分類
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  ref
                      .read(todoListProvider.notifier)
                      .addTodo(
                        TodoItem(
                          title: titleController.text,
                          priority: selectedPriority,
                          category: selectedCategory,
                          dueDate: DateTime.now().add(const Duration(days: 1)),
                        ),
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('新增任務'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
