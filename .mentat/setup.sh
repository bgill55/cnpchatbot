# Install Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz
tar xf flutter_linux_3.19.0-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Flutter setup and dependencies
flutter doctor
flutter pub get