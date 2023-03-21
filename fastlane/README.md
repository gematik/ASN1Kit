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

### generate_documentation

```sh
[bundle exec] fastlane generate_documentation
```

Lane that (auto) genarates API documentation from inline comments.

### static_code_analysis

```sh
[bundle exec] fastlane static_code_analysis
```

Lane that runs the static code analyzer(s) for the project.

CI builds should run this lane on every commit

Currently swiftlint is used as static analyzer



### setup

```sh
[bundle exec] fastlane setup
```

Lane that sets up the SPM/Carthage dependencies and xcodeproj.



### xcodegen_generate_xcodeproj

```sh
[bundle exec] fastlane xcodegen_generate_xcodeproj
```

Generate xcodeproj from project.yml file

The lane to run when project.yml has changed and this should be reflected

in the xcodeproj.



###Example:

```
fastlane xcodegen_generate_xcodeproj
```



### cibuild

```sh
[bundle exec] fastlane cibuild
```

Lane that the ci build should invoke directly to do a complete build/test/analysis.

This lane calls `setup`, `static_code_analysis`, `test_all`, `generate_documentation`.



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
