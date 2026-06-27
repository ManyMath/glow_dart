## 0.0.2

- Use injected process execution for Android Rust builds with Gradle 9.

- Repair Flutter package target names, generated header paths, desktop bundling and Apple podspec names.
- Use a length-aware uniform setter and validate queued values; legacy unsized C setter now fails safely.
- Match Dart FFI boolean and void declarations to the Rust C ABI.
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
