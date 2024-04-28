//
//  LoggerFileActionProviderImplTests.swift
//  Main
//
//  Created by Volodymyr Kotsiubenko (13.01.2022).
//

import XCTest
@testable import K_Logger

final class LoggerFileActionProviderImplTests: BaseLoggerTests {
    // MARK: - Create Tests
    func test_actionForLog_requestsNewFile_whenNoFilesExist() {
        let testDate = currentDate
        let sut = makeSUT(maxFilesCount: 10, maxFilesSize: 100, config: testConfig(testDate: testDate))
        
        XCTAssertEqual(sut.actionForLog(ofSize: 1, using: [FileMeta]()), .create(fileName: fileNameByDate(testDate)))
    }
        
    func test_actionForLog_requestsNewFile_whenFileAfterWriteWillBiggerThanMaxFileSize() throws {
        let testDate = currentDate
        let sut = makeSUT(maxFilesCount: 3, maxFilesSize: 30, config: testConfig(testDate: testDate))
        let fileMetas = [try fileMeta(size: 6)]
        
        XCTAssertEqual(sut.actionForLog(ofSize: 9, using: fileMetas), .create(fileName: fileNameByDate(testDate)))
    }

    func test_actionForLog_requestsNewFile_whenNeedCreateFileAndRecordedSizeEqualToMaxFileSize() throws {
        let testDate = currentDate
        let sut = makeSUT(maxFilesCount: 3, maxFilesSize: 30, config: testConfig(testDate: testDate))
        let fileMetas = try fileMetas(count: 2, filesSize: 10)
        
        XCTAssertEqual(sut.actionForLog(ofSize: 10, using: fileMetas), .create(fileName: fileNameByDate(testDate)))
    }
    
    func test_actionForLog_requestsNewFile_whenNewDay() throws {
        let testDate = currentDate
        let sut = makeSUT(maxFilesCount: 3, maxFilesSize: 30, config: testConfig(testDate: testDate))
        
        let filesUrls = [URL(fileURLWithPath: testConfig.fullFileName(fromFileName: fileNameByDate(dayBefore))),
                         URL(fileURLWithPath: testConfig.fullFileName(fromFileName: fileNameByDate(dayBefore)))]
        let testMetas = try fileMetas(urls: filesUrls)
        
        XCTAssertEqual(sut.actionForLog(ofSize: 5, using: testMetas), .create(fileName: fileNameByDate(testDate)))
    }
    
    // MARK: - Write Tests
    func test_actionForLog_requestsWrite_whenOneWritableFileExists() throws {
        let sut = makeSUT(maxFilesCount: 10, maxFilesSize: 100)
        let fileMetas = [try fileMeta(size: 1)]
        
        XCTAssertEqual(sut.actionForLog(ofSize: 1, using: fileMetas), .write(file: fileMetas[0]))
    }
    
    func test_actionForLog_returnCorrectFile_whenFewWritableFilesExists_andFilesOrderIsCorrect() throws {
        let sut = makeSUT(maxFilesCount: 10, maxFilesSize: 100)
        let fileMetas = try fileMetas(count: 3, filesSize: 1)
        
        XCTAssertEqual(sut.actionForLog(ofSize: 1, using: fileMetas), .write(file: fileMetas[2]))
    }
    
    func test_actionForLog_returnCorrectFile_whenFewWritableFilesExists_andFilesOrderIsIncorrect() throws {
        let sut = makeSUT(maxFilesCount: 10, maxFilesSize: 100)
        
        let firstFile = try fileMeta(size: 1)
        let secondFile = try fileMeta(size: 1)
        let thirdFile = try fileMeta(size: 1)

        let fileMetas = [secondFile, thirdFile, firstFile]
                
        XCTAssertEqual(sut.actionForLog(ofSize: 1, using: fileMetas), .write(file: fileMetas[1]))
    }

    // MARK: - Rotation Tests
    func test_actionForLog_requestsRotation_whenExistingFilesSizeEqualToMaxFilesSize() throws {
        let testDate = currentDate
        let sut = makeSUT(maxFilesCount: 3, maxFilesSize: 60, config: testConfig(testDate: testDate))
        let fileMetas = try fileMetas(count: 2, filesSize: 30)
        
        XCTAssertEqual(sut.actionForLog(ofSize: 10, using: fileMetas),
                       .rotation(dropFile: fileMetas[0], newFileName: fileNameByDate(testDate)))
    }
    
    func test_actionForLog_requestsRotation_whenRecordedSizeEqualToMaxFileSizeAndFilesCountMax() throws {
        let testDate = currentDate
        let sut = makeSUT(maxFilesCount: 3, maxFilesSize: 30, config: testConfig(testDate: testDate))
        let fileMetas = try fileMetas(count: 3, filesSize: 1)
        
        XCTAssertEqual(sut.actionForLog(ofSize: 10, using: fileMetas),
                       .rotation(dropFile: fileMetas[0], newFileName: fileNameByDate(testDate)))
    }
    
    func test_actionForLog_requestsRotation_whenMaxFilesCountAndNewDay() throws {
        let testDate = currentDate
        let sut = makeSUT(maxFilesCount: 2, maxFilesSize: 20, config: testConfig(testDate: testDate))
        
        let firsUrl = URL(fileURLWithPath: testConfig.fullFileName(fromFileName: fileNameByDate(dayBefore)))
        wait()
        let secondUrl = URL(fileURLWithPath: testConfig.fullFileName(fromFileName: fileNameByDate(dayBefore)))

        let filesUrls = [firsUrl, secondUrl]
        let testMetas = try fileMetas(urls: filesUrls)
        
        XCTAssertEqual(sut.actionForLog(ofSize: 5, using: testMetas), .rotation(dropFile: testMetas[0], newFileName: fileNameByDate(testDate)))
    }
    
    func test_actionForLog_fileForDropCorrectInRotationAction() throws {
        let testDate = currentDate
        let sut = makeSUT(maxFilesCount: 2, maxFilesSize: 2, config: testConfig(testDate: testDate))
        
        let firstFile = try fileMeta(size: 1)
        wait()
        let secondFile = try fileMeta(size: 1)
        
        let fileMetas = [secondFile, firstFile]
        
        XCTAssertEqual(sut.actionForLog(ofSize: 1, using: fileMetas),
                       .rotation(dropFile: fileMetas[1], newFileName: fileNameByDate(testDate)))
    }
    
    func test_actionForLog_newFileIsEqualToDropFile() throws {
        let testDate = currentDate
        let sut = makeSUT(maxFilesCount: 1, maxFilesSize: 10, config: testConfig(testDate: testDate))
        
        let result = sut.actionForLog(ofSize: 2, using: [try fileMeta(size: 9)])
        
        XCTAssertEqual(result.dropFileName, result.newFileName)
    }
    
    // MARK: - Skip Tests
    func test_actionForLog_noAction_whenMaxFileSizeIsZero() {
        let sut = makeSUT(maxFilesCount: 10, maxFilesSize: 0)
        
        XCTAssertEqual(sut.actionForLog(ofSize: anyFileSize(), using: try anyFileMetas()), .skip)
    }
    
    func test_actionForLog_noAction_whenMaxFilesCountIsZero() {
        let sut = makeSUT(maxFilesCount: 0, maxFilesSize: 10)
        
        XCTAssertEqual(sut.actionForLog(ofSize: anyFileSize(), using: try anyFileMetas()), .skip)
    }

    func test_actionForLog_noAction_whenRecordedSizeBiggerThanMaxFileSize() {
        let sut = makeSUT(maxFilesCount: 2, maxFilesSize: 4)
        
        XCTAssertEqual(sut.actionForLog(ofSize: 10, using: [try anyMeta()]), .skip)
    }
    
    // MARK: - Helpers
    private func makeSUT(maxFilesCount: UInt,
                         maxFilesSize: UInt,
                         config: LoggerConfig = DefaultLoggerConfig()) -> FileActionProvider {
        FileActionProviderImpl(config: config, maxFilesCount: maxFilesCount, maxFilesSize: maxFilesSize)
    }
    
    private func anyFileMetas() throws -> [FileMeta] {
        [try anyMeta(), try anyMeta(), try anyMeta()]
    }
    
    private func anyMeta() throws -> FileMeta {
        try fileMeta(size: 1)
    }
    
    private func testConfig(testDate: Date) -> TestLoggerConfig {
        TestLoggerConfig(baseConfig: testConfig, includeSlash: false, fakeCurrentDate: testDate)
    }
}

// MARK: - FileAction Extension
fileprivate extension FileAction {
    var newFileName: String? {
        switch self {
        case .create(let fileName):
            return fileName
        case .rotation(_, let newFileName):
            return newFileName
        case .write(_), .skip:
            return nil
        }
    }
    
    var dropFileName: String? {
        switch self {
        case .rotation(let dropFileName, _):
            return dropFileName.fileName
        case .write(_), .skip, .create(_):
            return nil
        }
    }
}
