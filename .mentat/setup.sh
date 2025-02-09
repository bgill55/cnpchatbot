apt-get update
apt-get install -y unzip
git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
export PATH=$PATH:/opt/flutter/bin
flutter doctor --android-licenses
flutter pub get
flutter build