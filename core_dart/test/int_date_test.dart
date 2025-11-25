import "package:core_dart/src/int_date.dart";
import "package:test/test.dart";

void main() {
  test("composeRangeParam should return correct rangeParam", () {
    IntDate startingAt = IntDate(2022, 1, 1);
    IntDate endingAt = IntDate(2022, 1, 31);
    IntDateRange rangeIntDate = IntDateRange(startingAt, endingAt);
    expect(rangeIntDate.composeForParam(), "2022010120220131");

    startingAt = IntDate(2023, 3, 15);
    endingAt = IntDate(2023, 4, 20);
    rangeIntDate = IntDateRange(startingAt, endingAt);
    expect(rangeIntDate.composeForParam(), "2023031520230420");
  });

  test("composeRangeParam should return correct rangeParam for Jesus life", () {
    IntDate startingAt = IntDate(0, 12, 25);
    IntDate endingAt = IntDate(33, 4, 7);
    IntDateRange rangeIntDate = IntDateRange(startingAt, endingAt);
    expect(rangeIntDate.composeForParam(), "0000122500330407");
  });

  test("decomposeRangeParam should return correct RangeIntDate", () {
    String rangeParam = "2022010120220131";
    IntDateRange decomposedRangeIntDate = IntDateRange.fromParam(rangeParam);
    expect(decomposedRangeIntDate.startingAt.year, 2022);
    expect(decomposedRangeIntDate.startingAt.month, 1);
    expect(decomposedRangeIntDate.startingAt.day, 1);
    expect(decomposedRangeIntDate.endingAt.year, 2022);
    expect(decomposedRangeIntDate.endingAt.month, 1);
    expect(decomposedRangeIntDate.endingAt.day, 31);

    rangeParam = "2023031520230420";
    decomposedRangeIntDate = IntDateRange.fromParam(rangeParam);
    expect(decomposedRangeIntDate.startingAt.year, 2023);
    expect(decomposedRangeIntDate.startingAt.month, 3);
    expect(decomposedRangeIntDate.startingAt.day, 15);
    expect(decomposedRangeIntDate.endingAt.year, 2023);
    expect(decomposedRangeIntDate.endingAt.month, 4);
    expect(decomposedRangeIntDate.endingAt.day, 20);
  });
}

// eof