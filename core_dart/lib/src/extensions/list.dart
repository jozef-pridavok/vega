extension StringListExtensions on List<String> {
  List<String> addNonExisting(List<String> other) {
    // Vytvoríme novú kópiu aktuálneho zoznamu
    List<String> result = List<String>.from(this);
    // Prevedieme 'result' na sadu pre rýchlejšie vyhľadávanie
    Set<String> resultSet = Set<String>.from(result);
    // Prejdeme všetky prvky v 'other'
    for (String item in other) {
      // Ak 'resultSet' neobsahuje 'item', pridáme ho do 'result'
      if (!resultSet.contains(item)) {
        result.add(item);
      }
    }
    // Vrátime 'result'
    return result;
  }
}

// eof
