./flutter/bin/dart format --set-exit-if-changed=false .
./flutter/bin/flutter analyze --no-fatal-infos --no-fatal-warnings || true
./flutter/bin/flutter test || true