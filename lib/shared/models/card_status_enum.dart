enum CardStatus { todo, inProgress, done }

extension CardStatusExtension on CardStatus {
  String get label {
    switch (this) {
      case CardStatus.todo:
        return 'قيد الانتظار';
      case CardStatus.inProgress:
        return 'جاري العمل';
      case CardStatus.done:
        return 'مكتمل';
    }
  }

  String get apiValue {
    switch (this) {
      case CardStatus.todo:
        return 'Todo';
      case CardStatus.inProgress:
        return 'InProgress';
      case CardStatus.done:
        return 'Done';
    }
  }

  static CardStatus fromApi(String value) {
    switch (value.toLowerCase()) {
      case 'todo':
        return CardStatus.todo;
      case 'inprogress':
        return CardStatus.inProgress;
      case 'done':
        return CardStatus.done;
      default:
        return CardStatus.todo;
    }
  }
}
