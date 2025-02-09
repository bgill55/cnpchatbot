export PATH=$PATH:/opt/flutter/bin
flutter format --set-exit-if-changed .
flutter analyze
flutter test