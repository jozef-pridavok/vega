import "package:core_dart/src/data_models/user.dart";
import "package:core_dart/src/enums/gender.dart";
import "package:core_dart/src/enums/theme.dart";
import "package:core_dart/src/enums/user_role.dart";
import "package:core_dart/src/enums/user_type.dart";
import "package:core_dart/src/hive_adapters/user.dart";
import "package:hive/hive.dart";
import "package:test/test.dart";

void main() {
  Hive.init("test_path");

  group("UserAdapter", () {
    late Box<User> box;

    setUpAll(() async {
      Hive.registerAdapter(UserAdapter());
      box = await Hive.openBox<User>("test_box");
    });

    tearDownAll(() async {
      await box.clear();
      await box.close();
    });

    test("Write and read user", () async {
      // create a user object
      final user = User(
        userId: "123",
        userType: UserType.client,
        clientId: "456",
        roles: [UserRole.admin],
        login: "johndoe",
        email: "johndoe@example.com",
        nick: "John Doe",
        gender: Gender.man,
        yob: 1985,
        language: "en",
        country: "US",
        theme: Theme.light,
        emailVerified: true,
        blocked: false,
        //meta: {"key": "value"},
      );

      // write the user object to the box
      await box.put(user.userId, user);

      // read the user object from the box
      final storedUser = box.get(user.userId)!;

      // check that the stored user is equal to the original user
      expect(storedUser.userId, equals(user.userId));
      expect(storedUser.userType, equals(user.userType));
      expect(storedUser.clientId, equals(user.clientId));
      expect(storedUser.roles, equals(user.roles));
      expect(storedUser.login, equals(user.login));
      expect(storedUser.email, equals(user.email));
      expect(storedUser.nick, equals(user.nick));
      expect(storedUser.gender, equals(user.gender));
      expect(storedUser.yob, equals(user.yob));
      expect(storedUser.language, equals(user.language));
      expect(storedUser.country, equals(user.country));
      expect(storedUser.theme, equals(user.theme));
      expect(storedUser.emailVerified, equals(user.emailVerified));
      expect(storedUser.blocked, equals(user.blocked));
      //expect(storedUser.meta, equals(user.meta));
    });

    test("Write and read user with nullable properties", () async {
      // create a user object
      final user = User(
        userId: "321",
        userType: UserType.client,
        roles: [UserRole.admin],
        nick: "John Doe",
        gender: Gender.man,
        language: "en",
        country: "US",
        theme: Theme.light,
        emailVerified: true,
        blocked: false,
        //meta: {"key": "value"},
      );

      // write the user object to the box
      await box.put(user.userId, user);

      // read the user object from the box
      final storedUser = box.get(user.userId)!;

      // check that the stored user is equal to the original user
      expect(storedUser.userId, equals(user.userId));
      expect(storedUser.userType, equals(user.userType));
      expect(storedUser.clientId, equals(user.clientId));
      expect(storedUser.roles, equals(user.roles));
      expect(storedUser.login, equals(user.login));
      expect(storedUser.email, equals(user.email));
      expect(storedUser.nick, equals(user.nick));
      expect(storedUser.gender, equals(user.gender));
      expect(storedUser.yob, equals(user.yob));
      expect(storedUser.language, equals(user.language));
      expect(storedUser.country, equals(user.country));
      expect(storedUser.theme, equals(user.theme));
      expect(storedUser.emailVerified, equals(user.emailVerified));
      expect(storedUser.blocked, equals(user.blocked));
      //expect(storedUser.meta, equals(user.meta));
    });
  });
}

// eof
