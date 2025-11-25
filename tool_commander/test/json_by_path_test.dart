import "package:test/test.dart";
import "package:tool_commander/json_by_path.dart";

void main() {
  Map<String, dynamic> json1 = {};
  Map<String, dynamic> json2 = {};
  final JsonByPath jbp = JsonByPath();

  group("Testing json get/set methods", () {
    setUp(() {
      json1 = {
        "key 1": "value 1",
        "key 2": "value 2",
        "key 3": {
          "key 3_1": {"key 3_1_1": "value 3.1.1"}
        },
        "key 4": {
          "key 4.1": {"key 4.1.1": "value 4.1.1"}
        },
        "key 5": 4,
        "key 6": true
      };

      json2 = {
        "key 1": "value 1",
        "key 2": "value 2",
        "key 3": {
          "key 3_1": {"key 3_1_1": "value 3.1.1"}
        },
        "key 4": {
          "key 4.1": {"key 4.1.1": "value 4.1.1"}
        },
        "key 5": 4,
        "key 6": 19
      };
    });

    test("get using . and returning map", () {
      expect(jbp.getValue(json1, "key 3.key 3_1"), equals({"key 3_1_1": "value 3.1.1"}));
    });

    test("get using . and returning string", () {
      expect(jbp.getValue(json1, "key 3.key 3_1.key 3_1_1"), equals("value 3.1.1"));
    });

    test("get using . and returning int", () {
      expect(jbp.getValue(json1, "key 5"), equals(4));
    });

    test("get using . and returning bool", () {
      expect(jbp.getValue(json1, "key 6"), isTrue);
    });

    test("get using / and returning string", () {
      jbp.splitChar = "/";
      expect(jbp.getValue(json1, "key 4/key 4.1/key 4.1.1"), equals("value 4.1.1"));
    });

    test("set using . and int value", () {
      jbp.splitChar = ".";
      expect(jbp.setValue(json1, "key 6", 19), equals(json2));
    });

    test("get with . an invalid key", () {
      expect(jbp.getValue(json1, "key 7"), isNull);
    });

    test("creating two new keys", () {
      Map<String, dynamic> origin = Map<String, dynamic>.from(json1);
      expect(jbp.setValue(json1, "key 6.key 6_1.key 6_1_1", 10), isNot(origin));
      expect(jbp.getValue(json1, "key 6.key 6_1.key 6_1_1"), equals(10));
    });

    test("getting default value", () {
      expect(jbp.getValue(json1, "key 99", <String>[]), equals(<String>[]));
    });
  });
}

// eof
