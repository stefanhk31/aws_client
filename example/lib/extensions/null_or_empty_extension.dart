extension NullOrEmptyExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
