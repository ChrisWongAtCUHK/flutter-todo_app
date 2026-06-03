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
  // lib/screens/home_screen.dart 裡面的方法

  void _showAddTodoBottomSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();

    // 預設值
    TodoPriority selectedPriority = TodoPriority.medium;
    TodoCategory selectedCategory = TodoCategory.work;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // 使用 StatefulBuilder 來管理彈出視窗內部的狀態更新
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '建立新任務',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // 任務名稱輸入框
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: '任務名稱',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 分類與優先級 選擇列
                  Row(
                    children: [
                      // 分類選擇 (Category)
                      Expanded(
                        child: DropdownButtonFormField<TodoCategory>(
                          initialValue: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: '分類',
                            border: OutlineInputBorder(),
                          ),
                          items: TodoCategory.values.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (TodoCategory? newValue) {
                            if (newValue != null) {
                              // 注意：這裡必須使用 setModalState 才能改變彈出視窗內的 UI
                              setModalState(() {
                                selectedCategory = newValue;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 優先級選擇 (Priority)
                      Expanded(
                        child: DropdownButtonFormField<TodoPriority>(
                          initialValue: selectedPriority,
                          decoration: const InputDecoration(
                            labelText: '優先等級',
                            border: OutlineInputBorder(),
                          ),
                          items: TodoPriority.values.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority.name.toUpperCase(),
                                style: TextStyle(
                                  color: priority == TodoPriority.high
                                      ? Colors.red
                                      : priority == TodoPriority.medium
                                      ? Colors.orange
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (TodoPriority? newValue) {
                            if (newValue != null) {
                              setModalState(() {
                                selectedPriority = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 送出按鈕
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (titleController.text.trim().isNotEmpty) {
                        ref
                            .read(todoListProvider.notifier)
                            .addTodo(
                              TodoItem(
                                title: titleController.text.trim(),
                                priority: selectedPriority,
                                category: selectedCategory,
                                dueDate: DateTime.now().add(
                                  const Duration(days: 1),
                                ), // 預設明天截止
                              ),
                            );
                        Navigator.pop(context); // 關閉彈出視窗
                      } else {
                        // 提示不可為空
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('請輸入任務名稱！')),
                        );
                      }
                    },
                    child: const Text(
                      '新增任務',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
