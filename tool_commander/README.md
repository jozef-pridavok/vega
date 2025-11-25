A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.

# Registration

```
dart pub global activate --source=path ./ --executable=vtc --overwrite 
```

```
dart pub global deactivate tool_commander
```

## Sample commands

## Psql

```
dart run ./bin/vtc.dart psql version
```

```
vtc psql version
```

---

```
vtc psql exec --file ./sql/02_structure.sql
```

```
vtc psql exec --file ./sql/sample_data.sql
```

```
vtc psql pump --file ./sql/migration_cards.sql
```

```
vtc psql exec --file ./test/sql_fake_user.sql
```

```
vtc psql exec --command "SELECT * FROM users"
```

### Lang

```
vtc lang google-sheet --keys "/Users/oxy/Work/Temp/_a/keys.dart" --output "/Users/oxy/Work/Temp/_a/" --url "https://docs.google.com/spreadsheets/d/e/2PACX-1vRrXLETBaKTEMVNKFFKhsxSSiNAKGI5hoMTki5gYLqBrVVAlYFLBgpn27IsIC7noOq0DZnrEbap-bRv/pub?gid=1338362051&single=true&output=tsv"
```

#### Remove unused

```
vtc lang remove_unused --input [--input "path/to/project/directory/with/pubspec.yaml"] [--dry-run=false] [--verbose=false]
```

Skontroluje, či sa všetky klúče používajú (súbor strings.dart, trieda LangKeys). Zoberie sa pubspec.yaml, prečítajú sa závislosti na moduloch core... Prejde sa všetky súbory projektového libs z appky. Ak sa klúč nepoužíva vymaže sa z strings.dart a vymažú sa aj všetky preklady v assetoch.

Assety (json súbory) sú v definované v pubspec.yaml pod "vega.localizations.assets". Kontrolujú sa jazyky definované v pubspe.yaml pod "vega.localizations.locales".

Pokiaľ sa neurčí "--input", použije sa aktuálny adresár.


#### Update source

```
vtc lang source [--input "path/to/project/directory/with/pubspec.yaml"] [--dry-run=false] [--verbose=false]
```

Pridá klúče zo zdrojákov `TODO: localize key locales` resp `TODO: localize_plural key locales` . Prejdu sa všetky zdrojáky aplikácie a zdrojáky z core. Texty z `TODO: localize*` sa pridajú resp. sa nahradia za nové v assetoch. V aplikácii sa komentované riadky `TODO: localize*` odstránia. V core ale ostanú (slúžia ako zdroj core textov pre aplikácie).

Assety (json súbory) sú v definované v pubspec.yaml pod "vega.localizations.assets". Kontrolujú sa jazyky definované v pubspe.yaml pod "vega.localizations.locales".

Pokiaľ sa neurčí "--input", použije sa aktuálny adresár.


### BlurHash

```
vtc blur_hash encode --url http://via.placeholder.com/250x250
```

```
vtc blur_hash decode --key key1 --code 0300155d04
```

### BCrypt

```
vtc bcrypt encode --plain hello
```

```
vtc bcrypt encode --salt \$2a\$10\$l5UkKRFGkRDU9MNyExbcNO --plain hello
```

### Cryptex

```
vtc cryptex encode --key key1 --plain hello
```

```
vtc cryptex decode --key key1 --code 0300155d04
```

### Repo - todo

!default_set:

- api_cron
- api_mobile
- core_dart
- core_flutter
- vega_app
- vega_dashboard
- vega_pos

```
vtc repo update --dep flutter_riverpod --version ^1.17.1 --packages !default_set
vtc repo update --dev_dep flutter_lints --version ^2.0.1
vtc repo switch --local
vtc repo switch --remote --tag 230801a
    git ls-remote | grep 230801
vtc repo tag --repo core_dart --tag 230813a
vtc repo tag --repo core_flutter --tag 230813a
```