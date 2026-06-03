import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todo_model.g.dart'; // 用於 Hive 自動生成代碼

@HiveType(typeId: 0)
enum TodoPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 1)
enum TodoCategory {
  @HiveField(0)
  work,
  @HiveField(1)
  personal,
  @HiveField(2)
  shopping,
  @HiveField(3)
  health,
}

@HiveType(typeId: 2)
class TodoItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  TodoPriority priority;

  @HiveField(5)
  TodoCategory category;

  @HiveField(6)
  DateTime dueDate;

  TodoItem({
    String? id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.priority,
    required this.category,
    required this.dueDate,
  }) : id = id ?? const Uuid().v4();

  // 方便複製物件修改狀態
  TodoItem copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    TodoPriority? priority,
    TodoCategory? category,
    DateTime? dueDate,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
