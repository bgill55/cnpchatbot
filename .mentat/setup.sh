curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.4-stable.tar.xz
tar xf flutter_linux_3.27.4-stable.tar.xz
git config --global --add safe.directory $(pwd)/flutter
export PATH="$(pwd)/flutter/bin:$PATH"
flutter doctor --android-licenses
flutter doctor
flutter pub get