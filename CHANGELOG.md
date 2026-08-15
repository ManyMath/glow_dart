## 0.0.2

- Use injected process execution for Android Rust builds with Gradle 9.
- Repair Flutter package target names, generated header paths, desktop bundling and Apple podspec names.
- Use a length-aware uniform setter and validate queued values; legacy unsized C setter now fails safely.
- Decode queued additions without alignment assumptions, reject foreign sampler structs, and validate byte lengths for queued and WASM updates.
- Retained Rust raw-pointer uniform methods now require `unsafe` and documented valid buffers; public C symbols are unchanged.
- Match Dart FFI boolean and void declarations to the Rust C ABI.
- Drop the unused `permission_handler` dependency, which forced its Windows plugin into every app; the example still uses it.
- Verify actual package archives with a fresh Linux Flutter build and runtime FFI smoke.

## 0.0.1

Initial public release.

- 6-platform support: Android, iOS, Linux, macOS, Windows, and Web
- GLSL shader rendering via OpenGL ES / OpenGL / WebGL2
- ShaderToy compatibility (single-layer Image shaders)
- Sampler2D texture uniforms (iChannel0-3) with runtime updates
- Mouse interaction via iMouse uniform
- Custom uniform support (bool, int, float, vec2-4, mat2-4)
- FPS reporting
- Optional OpenCV video capture on Android, Linux, and Windows
