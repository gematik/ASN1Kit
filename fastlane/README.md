fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### build_cli
```
fastlane build_cli
```

### carthage_resolve_dependencies
```
fastlane carthage_resolve_dependencies
```
Lane that resolves the project dependencies using Carthage.
### build_mac
```
fastlane build_mac
```
Build the project schemes for macOS
### test_mac
```
fastlane test_mac
```
Build and test (scan) the project schemes for macOS

CI builds should run this lane on every commit


### build_ios
```
fastlane build_ios
```
Build the project for iOS
### test_ios
```
fastlane test_ios
```
Build and test (scan) the project for iOS

CI builds should run this lane on every commit
### build_all
```
fastlane build_all
```
Build the project for macOS and iOS by calling `build_mac` and `build_ios`
### test_all
```
fastlane test_all
```
Build and test (scan) the project for macOS and iOS by calling `test_mac` and `test_ios`
### generate_documentation
```
fastlane generate_documentation
```
Lane that (auto) genarates API documentation from inline comments.
### static_code_analysis
```
fastlane static_code_analysis
```
Lane that runs the static code analyzer(s) for the project.

CI builds should run this lane on every commit

Currently swiftlint is used as static analyzer


### setup
```
fastlane setup
```
Lane that sets up the SPM/Carthage dependencies and xcodeproj.


### cibuild
```
fastlane cibuild
```
Lane that the ci build should invoke directly to do a complete build/test/analysis.

This lane calls `setup`, `static_code_analysis`, `test_all`, `generate_documentation`.



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
