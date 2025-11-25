extension NumDecimalPlaces on num {
  int get decimalPlaces {
    int tenMultiple = 10;
    int count = 0;
    double self = toDouble();
    double manipulatedNum = self;
    while (manipulatedNum.ceil() != manipulatedNum.floor()) {
      manipulatedNum = self * tenMultiple;
      count = count + 1;
      tenMultiple = tenMultiple * 10;
    }
    return count;
  }
}

// eof
