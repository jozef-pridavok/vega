# vega_app

A new Flutter project.

## Notes

### Firebase registration

```
flutterfire config \
  --project=cards-vega-app-dev \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.vega.app.dev \
  --macos-bundle-id=com.vega.app.dev \
  --android-app-id=com.vega.app.dev

mv ./android/app/google-services.json ./android/app/src/dev
mv ./ios/Runner/GoogleService-Info.plist ./ios/Runner/GoogleService-Info.dev.plist
mv ./ios/firebase_app_id_file.json ./ios/firebase_app_id_file.dev.json
mv ./macos/Runner/GoogleService-Info.plist ./macos/Runner/GoogleService-Info.dev.plist
mv ./macos/firebase_app_id_file.json ./macos/firebase_app_id_file.dev.json
```

```
flutterfire config \
  --project=cards-vega-app-qa \
  --out=lib/firebase_options_qa.dart \
  --ios-bundle-id=com.vega.app.qa \
  --macos-bundle-id=com.vega.app.qa \
  --android-app-id=com.vega.app.qa

mv ./android/app/google-services.json ./android/app/src/qa
mv ./ios/Runner/GoogleService-Info.plist ./ios/Runner/GoogleService-Info.qa.plist
mv ./ios/firebase_app_id_file.json ./ios/firebase_app_id_file.qa.json
mv ./macos/Runner/GoogleService-Info.plist ./macos/Runner/GoogleService-Info.qa.plist
mv ./macos/firebase_app_id_file.json ./macos/firebase_app_id_file.qa.json
```

```
flutterfire config \
  --project=cards-vega-app-demo \
  --out=lib/firebase_options_demo.dart \
  --ios-bundle-id=com.vega.app.demo \
  --macos-bundle-id=com.vega.app.demo \
  --android-app-id=com.vega.app.demo

mv ./android/app/google-services.json ./android/app/src/demo
mv ./ios/Runner/GoogleService-Info.plist ./ios/Runner/GoogleService-Info.demo.plist
mv ./ios/firebase_app_id_file.json ./ios/firebase_app_id_file.demo.json
mv ./macos/Runner/GoogleService-Info.plist ./macos/Runner/GoogleService-Info.demo.plist
mv ./macos/firebase_app_id_file.json ./macos/firebase_app_id_file.demo.json
```

```
flutterfire config \
  --project=cards-vega-app-prod \
  --out=lib/firebase_options_prod.dart \
  --ios-bundle-id=com.vega.app \
  --macos-bundle-id=com.vega.app \
  --android-app-id=com.vega.app

mv ./android/app/google-services.json ./android/app/src/prod
mv ./ios/Runner/GoogleService-Info.plist ./ios/Runner/GoogleService-Info.prod.plist
mv ./ios/firebase_app_id_file.json ./ios/firebase_app_id_file.prod.json
mv ./macos/Runner/GoogleService-Info.plist ./macos/Runner/GoogleService-Info.prod.plist
mv ./macos/firebase_app_id_file.json ./macos/firebase_app_id_file.prod.json
```
