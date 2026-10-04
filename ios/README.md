# iPhone app

`SacredFeminineKit/` is a Swift package with the shared code for the native
iPhone app: Codable models for the `/api/v1` responses, an async `APIClient`
over `URLSession`, typed `APIError`s and a `TokenStore` protocol (with an
in-memory implementation; the Keychain one lives in the app). It has no
iPhone-only code, so it builds and tests on Linux as well as macOS. The app
target and its screens will sit on top of it.

The tests decode every example response in `test/api_examples/v1/`, which the
Rails request tests write. They read the files from the repository, so an API
shape change fails the Swift tests too. A new example file must be added to
`APIExamplesTests.decoders`.

## Running the tests

Swift 6.0 or later. On macOS, with Xcode installed:

```bash
cd ios/SacredFeminineKit
swift test
```

On Linux, install a toolchain from https://www.swift.org/install/linux/ (or use
the `swift` Docker image), then run the same commands. CI runs `swift build`
and `swift test` in the `swift:6.4` image whenever `ios/` or
`test/api_examples/` change (`.github/workflows/ios-package.yml`).

On Linux distributions swift.org does not support, such as Arch, the Ubuntu
24.04 toolchain works after linking two newer system libraries under the names
it expects, inside the toolchain's own library folder:

```bash
cd <toolchain>/usr/lib/swift/linux
ln -s /usr/lib/libncursesw.so.6 libncurses.so.6
ln -s /usr/lib/libxml2.so.16 libxml2.so.2
```
