import XCTest

#if !os(macOS) && !os(iOS)
/// Run all ASN1Kit tests
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ASN1ObjectTest.allTests),
        testCase(ASN1DecoderTest.allTests),
        testCase(DataExtASN1IntTest.allTests),
        testCase(DataScannerTest.allTests),
        testCase(DataExtUIntTest.allTests),
        testCase(ASN1ObjectTest.allTests)
    ]
}
#endif
