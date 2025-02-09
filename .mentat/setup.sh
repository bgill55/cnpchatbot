# Install Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
export PATH="$PATH:/opt/flutter/bin"
flutter doctor --android-licenses
flutter doctor

# Get Flutter dependencies
flutter pub get