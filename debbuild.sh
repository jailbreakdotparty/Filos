#!/bin/bash
set -euo pipefail

repository="$(cd "$(dirname "$0")" && pwd)"
cd "$repository"

# An existing app lets CI package the Release build without compiling it twice.
app="${1:-$repository/build/DerivedData/Build/Products/Release-iphoneos/Filos.app}"
if [ "$#" -eq 0 ]; then
    xcodebuild -project Filos.xcodeproj -scheme Filos \
        -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
        -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
fi

read -r bundle_id version minimum_os < <(python3 - "$app/Info.plist" <<'PY'
import plistlib
import sys
with open(sys.argv[1], "rb") as file:
    info = plistlib.load(file)
assert info["CFBundleExecutable"] == "Filos"
print(info["CFBundleIdentifier"], info["CFBundleShortVersionString"], info["MinimumOSVersion"])
PY
)

workspace="$(mktemp -d "${TMPDIR:-/tmp}/filos-deb.XXXXXX")"
trap 'rm -rf "$workspace"' EXIT
package="$workspace/package"
staged_app="$package/Applications/Filos.app"
mkdir -p "$package/DEBIAN" "$package/Applications" "$repository/build/packages"
cp -R "$app" "$staged_app"

ldid -S"$repository/entitlements.plist" "$staged_app"
python3 - "$staged_app/Filos" "$repository/entitlements.plist" <<'PY'
import plistlib
import subprocess
import sys
with open(sys.argv[2], "rb") as file:
    expected = plistlib.load(file)
actual = plistlib.loads(subprocess.check_output(["ldid", "-e", sys.argv[1]]))
assert actual == expected, "Packaged app entitlements do not match entitlements.plist"
PY

cat > "$package/DEBIAN/control" <<EOF
Package: $bundle_id
Name: Filos
Version: $version
Architecture: iphoneos-arm
Description: File manager for iOS 14.8 and later.
Maintainer: jailbreak.party
Author: jailbreak.party
Section: Utilities
Depends: firmware (>= $minimum_os), uikittools
Homepage: https://github.com/k1tty-xz/Filos
EOF
cat > "$package/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
if [ "$1" = configure ]; then
    uicache -p /Applications/Filos.app
fi
EOF
cat > "$package/DEBIAN/postrm" <<'EOF'
#!/bin/sh
set -e
if [ "$1" = remove ] || [ "$1" = purge ]; then
    uicache
fi
EOF

find "$package" -type d -exec chmod 755 {} +
find "$package" -type f -exec chmod 644 {} +
find "$staged_app" -type f -name '*.dylib' -exec chmod 755 {} +
chmod 755 "$staged_app/Filos" "$package/DEBIAN/postinst" "$package/DEBIAN/postrm"

output="$repository/build/packages/${bundle_id}_${version}_iphoneos-arm.deb"
dpkg-deb --build --root-owner-group -Zgzip "$package" "$output"
dpkg-deb --info "$output"
