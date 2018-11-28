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
or alternatively using `brew cask install fastlane`

# Available Actions
### resolve_dependencies
```
fastlane resolve_dependencies
```
Lane that resolves the project dependencies using Swift Package manager.
### generate_xcodeproj
```
fastlane generate_xcodeproj
```
Generate xcodeproj from Package.swift file

The lane to run when Package.swift has changed and this should be reflected

in the xcodeproj. CI builds should always run this.

Note: This lane calls `fix_test_resources` and `fix_project_resources` (because they will be lost due to spm generate-xcodeproj)



###Example:

```
fastlane generate_xcodeproj xcconfig:Other.xcconfig skip_fix_resources:true skip_fix_test_resources:true --env osx
```

###Options

 * **`xcconfig`**: The xcconfig file [default: Package.xcconfig]. (`G_XCCONFIG`)

 * **`skip_fix_resources`**: Whether to run lane `fix_project_resources` or not [default: true => do not run fix_project_resources]. (`G_GEN_XCODEPROJ_SKIP_PROJECT_RESOURCES`)

 * **`skip_fix_test_resources`**: Whether to run lane `fix_test_resources` or not [default: false => do run fix_test_resources]. (`G_GEN_XCODEPROJ_SKIP_TEST_RESOURCES`)


### fix_test_resources
```
fastlane fix_test_resources
```
Add test (Bundle) Resource(s) to the Test target



###Example:

```
fastlane fix_test_resources project:Project.xcodeproj test_target:TargetTest test_group:Tests/Group test_bundles:"../Resources.bundle,Tests.bundle" --env osx
```

###Options

 * **`project`**: The path to the Xcode project file. (`G_PROJECT`)

 * **`test_target`**: The target name in the Xcode project. (`G_FIX_TEST_TARGET`)

 * **`test_group`**: The group name in the Xcode project. (`G_FIX_TEST_GROUP`)

 * **`test_bundles`**: Comma separated list of the bundle resources to add to the target relative to the group in the Xcode project. (`G_FIX_TEST_BUNDLE_RESOURCES`)


### fix_project_resources
```
fastlane fix_project_resources
```
Add (Bundle) Resource(s) to the Project target



###Example:

```
fastlane fix_project_resources project:Project.xcodeproj target:Target group:Sources/Group bundles:"../Resources.bundle,Assets.bundle" --env osx
```

###Options

 * **`project`**: The path to the Xcode project file. (`G_PROJECT`)

 * **`target`**: The target name in the Xcode project. (`G_FIX_PROJECT_TARGET`)

 * **`group`**: The group name in the Xcode project. (`G_FIX_PROJECT_GROUP`)

 * **`bundles`**: Comma separated list of the bundle resources to add to the target relative to the group in the Xcode project. (`G_FIX_PROJECT_BUNDLE_RESOURCES`)


### build_mac
```
fastlane build_mac
```
Build and test (scan) the project for macOS

The lane to run by ci on every commit.



###Example:

```
fastlane build_mac mac_schemes:ProjectScheme mac_sdk:"macos10.14" mac_destination:"platform=macOS,arch=x86_64" configuration:Release --env osx
```

###Options

 * **`project`**: The path to the Xcode project file. (`G_PROJECT`)

 * **`mac_sdk`**: The SDK version to build against [default: macosx]. (`G_MAC_SDK`)

 * **`mac_destination`**: Build platform destination [default: platform=macOS,arch=x86_64]. (`G_MAC_DESTINATION`)

 * **`configuration`**: Build configuration (Debug|Release) [default: Release]. (`G_BUILD_CONFIGURATION`)


### build_ios
```
fastlane build_ios
```
Build and test (scan) the project for iOS

The lane to run by ci on every commit.



###Example:

```
fastlane build_ios ios_schemes:ProjectScheme ios_sdk:"iphonesimulator12.0" ios_destination:"platform=iOS Simulator,name=iPhone 6s,OS=12.0" configuration:Release --env ios12_xcode10
```

###Options

 * **`project`**: The path to the Xcode project file. (`G_PROJECT`)

 * **`ios_sdk`**: The SDK version to build against [default: iphonesimulator]. (`G_IOS_SDK`)

 * **`ios_destination`**: Build platform destination [default: platform=iOS Simulator,name=iPhone 6s,OS=12.0]. (`G_IOS_DESTINATION`)

 * **`configuration`**: Build configuration (Debug|Release) [default: Release]. (`G_BUILD_CONFIGURATION`)


### build_all
```
fastlane build_all
```
Lane that builds for macOS and iOS by calling `build_mac` and `build_ios`

See other lanes for configuration of options and/or ENV.



###Example:

```
fastlane build_all skip_ios:true skip_macos:false --env osx
```

###Options

 * **`skip_ios`**: Whether to skip the ios build [default: false]. (`G_BUILD_IOS_SKIP`)

 * **`skip_macos`**: Whether to skip the macos build [default: false]. (`G_BUILD_MAC_SKIP`)


### generate_documention
```
fastlane generate_documention
```
Lane that (auto) genarates API documentation from inline comments.

See for more info: https://github.com/realm/jazzy



###Example:

```
fastlane generate_documention jazzy_config:".jazzy.yml" --env ios12_xcode10
```

###Options

 * **`jazzy_config`**: The jazzy configfile [default: .jazzy.yml]. (`G_JAZZY_CONFIG`)


### static_code_analysis
```
fastlane static_code_analysis
```
Lane that runs the static code analyzer for the project.

CI builds should run this lane on every commit and fail the build when

the error/warning threshold exceeds the set limit.

Currently swiftlint is used as static analyzer



###Example:

```
fastlane static_code_analysis swinftlint_config:".swiftlint.yml" code_analysis_fail_build:true code_analysis_strict:true --env ios12_xcode10
```

###Options

 * **`swinftlint_config`**: The SwiftLint configfile [default: .swiftlint.yml]. (`G_SWIFTLINT_CONFIG`)

 * **`code_analysis_fail_build`**: Whether errors/warnings should trigger build failures or not [default: true]. (`G_CODE_ANALYSIS_FAIL_BUILD`)

 * **`code_analysis_strict`**: Lint mode strict [default: true]. (`G_CODE_ANALYSIS_STRICT`)


### cibuild
```
fastlane cibuild
```
Lane that the ci build should invoke directly to do a complete build/test/analysis.

This lane calls `resolve_dependencies`, `generate_xcodeproj`, `static_code_analysis`, 

`build_all`, `test_all`, `generate_documention`. See these sub-lanes for option parameters

and ENV configuration options.



###Example:

```
fastlane cibuild --env ios12_xcode10
```



----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
