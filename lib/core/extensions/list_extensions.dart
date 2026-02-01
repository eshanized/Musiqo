// ============================================================================
// List Extensions - Collection helpers
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

/// Extensions for List with helpful utility methods.
extension ListExtensions<T> on List<T> {
  
  /// Get element at index or null if out of bounds
  /// Safer than list[index] which throws an error
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
  
  /// Shuffle and return a new list (doesn't modify original)
  List<T> get shuffled {
    final copy = List<T>.from(this);
    copy.shuffle();
    return copy;
  }
  
  /// Take up to n elements (safe, never throws)
  List<T> takeSafe(int n) {
    if (n >= length) return List.from(this);
    return sublist(0, n);
  }
  
  /// Split list into chunks of given size
  /// [1,2,3,4,5].chunked(2) -> [[1,2], [3,4], [5]]
  List<List<T>> chunked(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      final end = (i + size > length) ? length : i + size;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }
}

/// Extensions for nullable lists
extension NullableListExtensions<T> on List<T>? {
  /// Is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  
  /// Is not null and not empty
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
