//
//  LogFormatterImplTestsNew.swift
//  Main
//
//  Created by Volodymyr Kotsiubenko (13.01.2022).
//

import XCTest
@testable import K_Logger

final class LogFormatterImplTests: BaseLoggerTests {
    private let date = Date()

    private lazy var logsFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = testConfig.logDateFormat
        formatter.timeZone = TimeZone(abbreviation: testConfig.timeZone)
        return formatter
    }()
    
    private var dateString: String {
        logsFormatter.string(from: date)
    }
    
    // MARK: - EventType tests
    func test_eventType_transformedIntoStringCorrectly() {
        let sut = makeSUT()
        
        let testCases: [EventTypeTestCase] = [
            .ensure(.debug, convertedInto: "D"),
            .ensure(.info, convertedInto: "I"),
            .ensure(.critical, convertedInto: "C"),
            .ensure(.warning, convertedInto: "W"),
            .ensure(.error, convertedInto: "E"),
            .ensure(.user(label: "label test"), convertedInto: "U[label test]"),
        ]
        
        for testCase in testCases {
            sut.eventType = testCase.eventType
            XCTAssertEqual(testCase.expected, sut.formatted())
        }
    }
    
    func test_eventType_notTransformedWhenNotProvided() {
        let sut = makeSUT()
        
        sut.eventType = nil
        XCTAssert(sut.formatted().isEmpty)
    }
    
    func test_eventType_transformedWhenProvided() {
        let sut = makeSUT()
        sut.eventType = anyEventType
        
        XCTAssert(sut.formatted().count != 0)
    }
    
    // MARK: - Date tests
    func test_date_notTransformedWhenNotProvided() {
        let sut = makeSUT()
        
        sut.date = nil
        XCTAssert(sut.formatted().isEmpty)
    }
    
    func test_date_transformedWhenProvided() {
        let sut = makeSUT()
        
        sut.date = date
        XCTAssert(!sut.formatted().isEmpty)
    }
    
    func test_date_transformedIntoStringCorrectly() {
        let sut = makeSUT()
        
        sut.date = date
        XCTAssertEqual(dateString, sut.formatted())
    }
    
    // MARK: - ThreadLabel and Tag tests
    func test_threadLabel_notTransformedWhenNotProvided() {
        let sut = makeSUT()
        
        sut.threadLabel = nil
        XCTAssert(sut.formatted().isEmpty)
    }
    
    func test_threadLabel_transformedWhenProvided() {
        let sut = makeSUT()
        
        sut.threadLabel = anyThreadLabel
        XCTAssert(!sut.formatted().isEmpty)
    }
    
    func test_threadLabel_transformedIntoStringCorrectly() {
        let sut = makeSUT()
        
        sut.threadLabel = anyThreadLabel
        XCTAssertEqual("[\(anyThreadLabel)]", sut.formatted())
    }
    
    func test_tag_notTransformedWhenNotProvided() {
        let sut = makeSUT()
        
        sut.tag = nil
        XCTAssert(sut.formatted().isEmpty)
    }
    
    func test_tag_transformedWhenProvided() {
        let sut = makeSUT()
        
        sut.tag = anyTag
        XCTAssert(!sut.formatted().isEmpty)
    }
    
    func test_tag_transformedIntoStringCorrectly() {
        let sut = makeSUT()
        
        sut.tag = anyTag
        XCTAssertEqual("[\(anyTag)]", sut.formatted())
    }
    
    func test_threadLabel_and_tag_transformedIntoStringCorrectly() {
        let sut = makeSUT()
        
        sut.tag = anyTag
        sut.threadLabel = anyThreadLabel
        XCTAssertEqual("[\(anyThreadLabel), \(anyTag)]", sut.formatted())
    }
    
    // MARK: - Message tests
    func test_message_notTransformedWhenNotProvided() {
        let sut = makeSUT()
        
        sut.message = nil
        XCTAssert(sut.formatted().isEmpty)
    }
    
    func test_message_transformedWhenProvided() {
        let sut = makeSUT()
        
        sut.message = anyMessage
        XCTAssert(!sut.formatted().isEmpty)
    }
    
    func test_message_transformedIntoStringCorrectly() {
        let sut = makeSUT()
        
        sut.message = anyMessage
        XCTAssertEqual(anyMessage, sut.formatted())
    }
    
    // MARK: - Params tests
    func test_params_notTransformedWhenNotProvided() {
        let sut = makeSUT()
        
        sut.params = nil
        XCTAssert(sut.formatted().isEmpty)
    }
    
    func test_params_transformedWhenProvided() {
        let sut = makeSUT()
        
        sut.params = anyLogParams
        XCTAssert(!sut.formatted().isEmpty)
    }
    
    func test_params_ensureResultStringStartsWithPrefix() {
        let sut = makeSUT()
        
        sut.params = anyLogParams
        XCTAssert(sut.formatted().hasPrefix(testConfig.paramsPrefix))
    }
    
    func test_params_transformedIntoStringCorrectlyWithStringValues() {
        let input = ["Some params key1": "Any1",
                     "Some params key2": "Any2"]
        
        check(input, transformedInto: "{\"Some params key1\":\"Any1\",\"Some params key2\":\"Any2\"}")
    }
    
    func test_params_transformedIntoStringCorrectlyWithNestedDictionariesValues() {
        let input = ["Some key1": "Some value1",
                     "Some key2": ["Some key2.1": "Some value2.1",
                                   "Some key2.2": ["Some key3.1": "Some value3.1",
                                                   "Some key3.2": "Some value3.2"]]] as [String: Any]
        
        check(input, transformedInto: "{\"Some key1\":\"Some value1\",\"Some key2\":{\"Some key2.1\":\"Some value2.1\",\"Some key2.2\":{\"Some key3.1\":\"Some value3.1\",\"Some key3.2\":\"Some value3.2\"}}}")
    }
    
    func test_params_transformedIntoStringCorrectlyWithNestedArraysValues() {
        let input = ["Some key1": "Some value1",
                     "Some key2": ["Some arrayValue1.1", "Some arrayValue1.2", ["Some arrayValue2.1"]]] as [String: Any]
        
        check(input, transformedInto: "{\"Some key1\":\"Some value1\",\"Some key2\":[\"Some arrayValue1.1\",\"Some arrayValue1.2\",[\"Some arrayValue2.1\"]]}")
    }
    
    func test_params_transformedIntoStringCorrectlyWithIntPositiveValues() {
        let input = ["Some params key1": 1,
                     "Some params key2": 0,
                     "Some params key3": 9999999999]
        
        check(input, transformedInto: "{\"Some params key1\":1,\"Some params key2\":0,\"Some params key3\":9999999999}")
    }
    
    func test_params_transformedIntoStringCorrectlyWithIntNegativeValues() {
        let input = ["Some params key1": -1,
                     "Some params key2": -0,
                     "Some params key3": -9999999999]
        
        check(input, transformedInto: "{\"Some params key1\":-1,\"Some params key2\":0,\"Some params key3\":-9999999999}")
    }
    
    func test_params_transformedIntoStringCorrectlyWithFloatPositiveValues() {
        let input = ["Some params key1": Float(1.001),
                     "Some params key2": Float(0.0),
                     "Some params key3": Float(99.99999)]
        
        check(input, transformedInto: "{\"Some params key1\":1.001,\"Some params key2\":0,\"Some params key3\":99.99999}")
    }
        
    func test_params_transformedIntoStringCorrectlyWithFloatNegativeValues() {
        let input = ["Some params key1": Float(-1.001),
                     "Some params key2": Float(-0.0),
                     "Some params key3": Float(-99.9999)]
        
        check(input, transformedInto: "{\"Some params key1\":-1.001,\"Some params key2\":0,\"Some params key3\":-99.9999}")
    }
    
    func test_params_transformedIntoStringCorrectlyWithBoolValues() {
        let input = ["Some params key1": true, "Some params key2": false]
        
        check(input, transformedInto: "{\"Some params key1\":true,\"Some params key2\":false}")
    }
    
    func test_params_transformedIntoStringCorrectlyWithArrayValues() {
        let input = ["Some key1": ["String1", true],
                     "Some key2": [-157, 123456],
                     "Some key3": [0.001, -0, -99.999999999]]
        
        check(input, transformedInto: "{\"Some key1\":[\"String1\",true],\"Some key2\":[-157,123456],\"Some key3\":[0.001,0,-99.999999999]}")
    }
    
    func test_params_ensureFloatingPointNumbersTransformedCorrectlyInNestedDictionaries() {
        let input = ["Some key1": Float(1.001),
                        "Some key2": ["Some key2.1": 1.001,
                                      "Some key2.2": ["Some key3.1": 10.0011,
                                                      "Some key3.2": Float(-99.99999)]]] as [String: Any]
        
        check(input, transformedInto: "{\"Some key1\":1.001,\"Some key2\":{\"Some key2.1\":1.001,\"Some key2.2\":{\"Some key3.1\":10.0011,\"Some key3.2\":-99.99999}}}")
    }
    
    func test_params_ensureFloatingPointNumbersTransformedCorrectlyInNestedArrays() {
        let input = ["Some key1": Float(1.001),
                     "Some key2": [-4.00001, -4.00001, [Float(-99.99999)]]] as [String: Any]
        
        check(input, transformedInto: "{\"Some key1\":1.001,\"Some key2\":[-4.00001,-4.00001,[-99.99999]]}")
    }
    
    func test_params_ensureNaNTransformedCorrectly() {
        let input = ["Some key1": Float.nan, "Some key2": Double.nan] as [String: Any]
        
        check(input, transformedInto: "{\"Some key1\":\"NaN\",\"Some key2\":\"NaN\"}")
    }
    
    func test_params_ensureNSNullTransformedCorrectly() {
        let input = ["Any key": NSNull()]

        check(input, transformedInto: "{\"Any key\":null}")
    }
    // MARK: - Symbols tests
    func test_params_ensureNonAlphabetSymbolsTransformedCorrectly() {
        let input = ["K&#*)!+_)(*&^%$!": "+_)(*&^%$#@!±😊"]
        
        check(input, transformedInto: "{\"K&#*)!+_)(*&^%$!\":\"+_)(*&^%$#@!±😊\"}")
    }
    
    func test_params_ensureNonCyrillicSymbolsTransformedCorrectly() {
        let input = ["Кирилица кирилица": "Кирилица кирилица"]
        
        check(input, transformedInto: "{\"Кирилица кирилица\":\"Кирилица кирилица\"}")
    }
    
    // MARK: - Spacings tests
    func test_params_ensureSpacingsInReturnedStringCorrectWhenAllArgumentsNotEmpty() {
        let sut = makeSUT()
        let eventType = anyEventType

        sut.eventType = eventType
        sut.date = date
        sut.params = ["Some key1": true, "Some key2": -99]
        sut.threadLabel = anyThreadLabel
        sut.tag = anyTag
        sut.message = anyMessage
        
        let expect = "\(dateString) \(eventType.mark) [\(anyThreadLabel), \(anyTag)] \(anyMessage) \(testConfig.paramsPrefix){\"Some key1\":true,\"Some key2\":-99}"
        
        XCTAssertEqual(sut.formatted(), expect)
    }
    
    func test_params_ensureSpacingsInReturnedStringCorrectWhenParamsIsEmpty() {
        let sut = makeSUT()
        let eventType = anyEventType
        
        sut.eventType = eventType
        sut.date = date
        sut.threadLabel = anyThreadLabel
        sut.tag = anyTag
        sut.message = anyMessage
        
        let expect = "\(dateString) \(eventType.mark) [\(anyThreadLabel), \(anyTag)] \(anyMessage)"
        
        XCTAssertEqual(sut.formatted(), expect)
    }
    
    func test_params_ensureSpacingsInReturnedStringCorrectWhenTagIsEmpty() {
        let sut = makeSUT()
        let eventType = anyEventType

        sut.eventType = eventType
        sut.date = date
        sut.threadLabel = anyThreadLabel
        sut.message = anyMessage
        sut.params = ["Some key1": true, "Some key2": -99]
        
        let expect = "\(dateString) \(eventType.mark) [\(anyThreadLabel)] \(anyMessage) \(testConfig.paramsPrefix){\"Some key1\":true,\"Some key2\":-99}"

        XCTAssertEqual(sut.formatted(), expect)
    }
    
    func test_params_ensureSpacingsInReturnedStringCorrectWhenTagAndParamsEmpty() {
        let sut = makeSUT()
        let eventType = anyEventType

        sut.eventType = eventType
        sut.date = date
        sut.message = anyMessage
        sut.threadLabel = anyThreadLabel
        
        let expect = "\(dateString) \(eventType.mark) [\(anyThreadLabel)] \(anyMessage)"

        XCTAssertEqual(sut.formatted(), expect)
    }
    
    func test_params_ensureSpacingsInReturnedStringCorrectWhenTagThreadLabelAndParamsEmpty() {
        let sut = makeSUT()
        let eventType: LogEventType = .info

        sut.eventType = eventType
        sut.date = date
        sut.message = anyMessage
        
        let expect = "\(dateString) \(eventType.mark) \(anyMessage)"

        XCTAssertEqual(sut.formatted(), expect)
    }
    
    func test_params_ensureSpacingsInReturnedStringCorrectThreadLabelEmpty() {
        let sut = makeSUT()
        let eventType = anyEventType

        sut.eventType = eventType
        sut.date = date
        sut.message = anyMessage
        sut.threadLabel = ""

        let expect = "\(dateString) \(eventType.mark) \(anyMessage)"

        XCTAssertEqual(sut.formatted(), expect)
    }
    
    // MARK: - DateFormatter test
    func test_timeZone_ensureDateFormatterTimeZoneIsUTC() {
        let sut = makeSUT()
        
        sut.date = date
        let dateString = logsFormatter.string(from: date)
        
        XCTAssertEqual(dateString, sut.formatted())
    }
    
    // MARK: - LogFormatterExtractorInterface test
    func test_dateStringSize_ensureResultIsCorrect() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.dateStringSize, logsFormatter.string(from: Date()).count)
    }
    
    func test_date_ensureResultIsCorrect() {
        let sut = makeSUT()
        let testDate = Date()
        let testDateString = logsFormatter.string(from: testDate)
                
        let result = sut.date(from: testDateString)

        let roundedTestDate = round(testDate.timeIntervalSince1970 * 1000) / 1000

        XCTAssertEqual(roundedTestDate, result?.timeIntervalSince1970)
    }

    // MARK: - Private
    private func makeSUT() -> LogFormatterImpl {
        LogFormatterImpl(config: testConfig)
    }
    
    // MARK: - Helpers    
    struct EventTypeTestCase {
        let eventType: LogEventType
        let expected: String
        
        static func ensure(_ eventType: LogEventType, convertedInto expected: String) -> Self {
            return .init(eventType: eventType, expected: expected)
        }
    }
    
    private func check(_ params: [String: Any], transformedInto expected: String, file: StaticString = #filePath, line: UInt = #line) {
        let sut = makeSUT()
        
        sut.params = params
        XCTAssertEqual(sut.formatted(), testConfig.paramsPrefix + expected, file: file, line: line)
    }
}
