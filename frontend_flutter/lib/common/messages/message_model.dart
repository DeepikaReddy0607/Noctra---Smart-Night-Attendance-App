enum MessageStatus {
  pending,
  replied,
  closed,
}

class StudentMessage {
  final String message;
  final DateTime createdAt;
  String? reply;
  MessageStatus status;

  StudentMessage({
    required this.message,
    required this.createdAt,
    this.reply,
    this.status = MessageStatus.pending,
  });
}
