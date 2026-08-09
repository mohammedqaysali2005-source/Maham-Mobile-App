enum Priority { low, medium, high, critical }

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.low:
        return 'منخفضة';
      case Priority.medium:
        return 'متوسطة';
      case Priority.high:
        return 'عالية';
      case Priority.critical:
        return 'حرجة';
    }
  }

  String get apiValue {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.critical:
        return 'Critical';
    }
  }

  static Priority fromApi(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      case 'critical':
        return Priority.critical;
      default:
        return Priority.medium;
    }
  }
}
