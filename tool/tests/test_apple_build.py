"""Apple staging contracts without installing SDKs or invoking a linker."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


@unittest.skipUnless(os.name == "posix", "Apple shell contract fixtures require a POSIX host")
class AppleBuildTests(unittest.TestCase):
    def run_script(self, platform, installed):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            pod = root / platform
            pod.mkdir()
            binary = root / 'bin'
            binary.mkdir()
            rustup = binary / 'rustup'
            rustup.write_text('#!/bin/sh\n[ "$*" = "target list --installed" ] || exit 99\nprintf "%s\\n" "$TEST_INSTALLED_TARGET"\n')
            cargo = binary / 'cargo'
            cargo.write_text('''#!/bin/sh
[ "$1" = build ] && [ "$2" = --locked ] || exit 98
while [ "$#" -gt 0 ]; do
  if [ "$1" = --target ]; then shift; selected="$1"; fi
  shift
done
out="$PODS_TARGET_SRCROOT/../rust/target/$selected/debug"
mkdir -p "$out"
printf 'test archive' > "$out/libflutter_opengl_rust.a"
''')
            for tool in [rustup, cargo]:
                tool.chmod(0o755)
            env = dict(os.environ, PATH=str(binary) + os.pathsep + os.environ['PATH'],
                       PODS_TARGET_SRCROOT=str(pod), CONFIGURATION='Debug',
                       ARCHS='arm64', ONLY_ACTIVE_ARCH='YES', PLATFORM_NAME='iphoneos',
                       TEST_INSTALLED_TARGET=installed)
            result = subprocess.run(['bash', str(ROOT / platform / 'build_rust.sh')], env=env,
                                    capture_output=True, text=True)
            archive = root / 'rust/target' / (platform + '-universal') / 'Debug/libflutter_opengl_rust.a'
            return result, archive.exists()

    def test_debug_host_target_and_configuration_match_podspec(self):
        for platform, target in [('macos', 'aarch64-apple-darwin'), ('ios', 'aarch64-apple-ios')]:
            with self.subTest(platform=platform):
                result, exists = self.run_script(platform, target)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertTrue(exists)

    def test_missing_target_fails_without_installing_or_building(self):
        result, exists = self.run_script('macos', '')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('provision Rust target aarch64-apple-darwin', result.stderr)
        self.assertFalse(exists)
