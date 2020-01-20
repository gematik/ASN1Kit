# ASN1Kit

ASN.1 Decoder for Swift

## API Documentation

Generated API docs are available at <https://gematik.github.io/ASN1Kit>.

## License

Licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).

## Overview

This library can be used for ASN.1 (Abstract Syntax Notation One) encoding/decoding
using distinguished encoding rules (DER) according to the ITU-T X.690

For more info, please find the complete [X.690-0207.pdf](https://www.itu.int/ITU-T/studygroups/com17/languages/X.690-0207.pdf)
specification.

## Getting Started

ASN1Kit requires Swift 5.1.

### Setup for integration

-   **Carthage:** Put this in your `Cartfile`:

        github "gematik/ASN1Kit" ~> 1.0

### Setup for development

You will need [Bundler](https://bundler.io/), [XcodeGen](https://github.com/yonaskolb/XcodeGen)
and [fastlane](https://fastlane.tools) to conveniently use the established development environment.

1.  Update ruby gems necessary for build commands

        $ bundle install --path vendor/gems

2.  Checkout (and build) dependencies and generate the xcodeproject

        $ bundle exec fastlane setup

3.  Build the project

        $ bundle exec fastlane build_all [build_mac, build_ios]

## Code Samples

Use `ASN1Decoder.decode(asn1:)` to decode serialized data
and `String(from:)` to get a hex representation of it:

    let expected = "0A3B5F291CD"
    let serialized = Data([0x23, 0xc, 0x3, 0x3, 0x0, 0x0A, 0x3B, 0x3, 0x5, 0x4, 0x5F, 0x29, 0x1C, 0xD0])

    expect {
        let asn1 = try ASN1Decoder.decode(asn1: serialized)
        return try String(from: asn1)
    } == expected

Construct an `ASN1Object` of your choice and serialize it:

    let data = Data([0x0, 0x1, 0x2, 0x4]) as ASN1EncodableType
    let data2 = Data([0x4, 0x3, 0x2, 0x1]) as ASN1EncodableType
    let array = [data, data2]

    let expected = Data([0x30, 0xc, 0x4, 0x4, 0x0, 0x1, 0x2, 0x4, 0x4, 0x4, 0x4, 0x3, 0x2, 0x1])
    expect {
        try array.asn1encode().serialize()
    } == expected

ASN.1-encode Swift primitives and extract the encoded value(s):

    //0x0080 = 128
    let expected = Data([0x00, 0x80])
    expect {
        try 128.asn1encode(tag: nil).data.primitive
    } == expected

Extract the tag of the first element of a constructed `ASN1Object`:

    let data = Data([0x1, 0x2, 0x3, 0x4, 0x8])
    let tag1 = ASN1Primitive(data: .primitive(data), tag: .taggedTag(3)) // context-specific class tag
    let tag2 = ASN1Primitive(data: .primitive(data), tag: .universal(ASN1Tag.octetString))
    let implicitTag = ASN1Primitive(data: .constructed([tag1, tag2]), tag: .taggedTag(83))

    expect {
        implicitTag.data.items?.first?.tag
    } == .taggedTag(3)
