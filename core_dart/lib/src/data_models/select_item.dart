class SelectItem {
  final String label;
  final String value;

  const SelectItem({
    required this.label,
    required this.value,
  });

  static const _label = "label";
  static const _value = "value";

  bool isEqual(SelectItem other) => value == other.value;

  @override
  String toString() => label;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SelectItem && runtimeType == other.runtimeType && isEqual(other);

  static SelectItem fromMap(Map<String, dynamic> map) => SelectItem(
        label: map[_label] as String,
        value: map[_value] as String,
      );

  Map<String, dynamic> toMap() => {
        _label: label,
        _value: value,
      };
}

class SelectObject<T> {
  final String label;
  final T object;

  const SelectObject({
    required this.label,
    required this.object,
  });

  bool isEqual(SelectObject<T> other) => object == other.object;

  @override
  String toString() => label;

  @override
  int get hashCode => object.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SelectObject<T> && runtimeType == other.runtimeType && isEqual(other);
}

// eof
