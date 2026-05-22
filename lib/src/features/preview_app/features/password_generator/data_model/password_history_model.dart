class PasswordHistory {
  final String password;
  final DateTime createdAt;
  bool favorite;

  PasswordHistory({
    required this.password,
    required this.createdAt,
    this.favorite = false,
  });
}