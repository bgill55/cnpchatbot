apt-get update
apt-get install -y unzip
export PATH=$PATH:/opt/flutter/bin
yes | flutter doctor --android-licenses || true
flutter pub get
flutter build