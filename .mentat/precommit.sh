export PATH=$PATH:/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin
dart format --set-exit-if-changed .
flutter analyze
flutter test