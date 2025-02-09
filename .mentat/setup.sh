curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.4-stable.tar.xz
tar xf flutter_linux_3.27.4-stable.tar.xz
git config --global --add safe.directory $(pwd)/flutter
./flutter/bin/flutter doctor --suppress-analytics
./flutter/bin/flutter pub get