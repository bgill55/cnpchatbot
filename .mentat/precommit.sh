./flutter/bin/dart format --fix .
./flutter/bin/dart fix --apply .
./flutter/bin/flutter analyze || true
./flutter/bin/flutter test || true