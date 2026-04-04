# Private Glow payload verification

The maintained Glow source is primary `sneurlax/fluter_opengl` branch `main`.
The primary default `master` is an older flutter_opengl upstream snapshot; do
not infer the maintained baseline from that default. Candidate version: 0.0.2.

Flutter requires package-derived desktop targets (`glow_plugin`), bundle
variables, header include directories and Apple podspec names. Exported plugin
class names, method channels and Rust ABI/library names remain stable. Windows
loads the Rust DLL directly for exported FFI symbols; Android keeps its existing plugin
library name. Linux declares Rust build outputs to Ninja and resolves the
bundled Rust library by basename and `$ORIGIN`, without a build-directory path.
The runtime gate also exposed mismatched Rust bool/void declarations in Dart;
these now use the corresponding FFI Bool/Void types, with failure-path uniform
queries in the smoke test. Dart setters now call `setUniformSized` with exact
byte lengths; the render queue rejects wrong lengths and decodes typed values
without pointer overreads. The legacy unsized C ABI symbol returns false
without reading memory; low-level callers must migrate to the sized symbol.
The public Dart setter API is unchanged. The Rust output belongs to the consumer build tree.

The archive excludes generated targets and the unresolved generated
`example/web/pkg` symlink. Source, native dependencies and upstream license
notices remain included. WebAssembly distribution is not validated by this
Linux gate.

```sh
python3 -m unittest discover -s tool/tests -v
DASH__SUPPRESS_ANALYTICS=true FLUTTER_SUPPRESS_ANALYTICS=true RUSTUP_TOOLCHAIN=1.94.0 CARGO_BUILD_JOBS=3 python3 tool/native_payload.py --config tool/payload.json --mode candidate --output /tmp/glow-candidate
```

Requires provisioned Python3.12+, Dart3.13.2, Flutter, Rust1.94.0 and Linux
GTK/OpenGL/EGL/GLEW/Xvfb libraries. No shared tool installer runs. Use a new
output directory every time. Pub validation and the pinned local archive flag
run separately without uploading or publication fallback. The actual archive
is extracted outside the repository and used in a fresh Flutter build.

The bundled app is copied outside its build tree and run under Xvfb/software
GL. It initializes native FFI, queries the inactive renderer and texture-size
sentinel, and asserts `/proc/self/maps` names the relocated bundled Rust
library. This verifies plugin loading and simple ABI calls, not shader
rendering or physical GPU behavior. The existing placeholder unit test is not
counted as meaningful coverage. Apple/Android/Windows builds and rendered
output remain separate acceptance checks. Glow is Flutter-only, with no
coordinated pure-Dart satellite package, so only candidate archive mode is
applicable; ordinary hosted dependencies resolve without overrides.

All CI and artifacts remain private. No GitHub writes or public package
publication are performed by this gate.

Cross-platform configuration preflights only the host Rust target for Flutter
debug macOS/Windows consumers. Apple scripts require installed targets and
write the static archive into the configuration directory expected by the
podspec (Debug/Release). Universal release builds require separate two-target
provisioning and validation. Linux is still the only runtime smoke here.
