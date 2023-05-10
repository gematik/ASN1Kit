fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### build_cli

```sh
[bundle exec] fastlane build_cli
```



### carthage_resolve_dependencies

```sh
[bundle exec] fastlane carthage_resolve_dependencies
```

Lane that resolves the project dependencies using Carthage.

### build_mac

```sh
[bundle exec] fastlane build_mac
```

Build the project schemes for macOS

### test_mac

```sh
[bundle exec] fastlane test_mac
```

Build and test (scan) the project schemes for macOS

CI builds should run this lane on every commit



### build_ios

```sh
[bundle exec] fastlane build_ios
```

Build the project for iOS

### test_ios

```sh
[bundle exec] fastlane test_ios
```

Build and test (scan) the project for iOS

CI builds should run this lane on every commit

### build_all

```sh
[bundle exec] fastlane build_all
```

Build the project for macOS and iOS by calling `build_mac` and `build_ios`

### test_all

```sh
[bundle exec] fastlane test_all
```

Build and test (scan) the project for macOS and iOS by calling `test_mac` and `test_ios`

### setup

```sh
[bundle exec] fastlane setup
```

Lane that sets up the SPM/Carthage dependencies and xcodeproj.



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
