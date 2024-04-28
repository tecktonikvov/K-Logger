//
//  LoggerStorageImplTests.swift
//  Main
//
//  Created by Volodymyr Kotsiubenko (21.01.2022).
//

import XCTest
@testable import K_Logger

final class LoggerStorageImplTests: BaseLoggerTests {
    // MARK: - metaForAllFiles method tests
    func test_metaForAllFiles_returnZeroItems_ifFilesNotExist() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.metaForAllFiles().count, 0)
    }
    
    func test_metaForAllFiles_returnCorrectCountOfExistingFiles() throws {
        let sut = makeSUT()
        
        for _ in 1...anyTestFileCount {
            wait()
            try createTestFile()
        }
        
        XCTAssertEqual(sut.metaForAllFiles().count, anyTestFileCount)
    }
    
    func test_metaForAllFiles_returnedResultValidItems_afterInit() throws {
        let testMeta = try createTwoTestFilesWithUniqueData()
        
        let sut = makeSUT()
        
        checkForEquality(first: sut.metaForAllFiles(), second: testMeta)
    }
    
    func test_metaForAllFiles_returnedResultValidItemsInList_afterLogSizeCall() throws {
        let testMeta = try createTwoTestFilesWithUniqueData()
        
        let sut = makeSUT()
        _ = sut.logSize(anyString)
        
        checkForEquality(first: sut.metaForAllFiles(), second: testMeta)
    }
    
    func test_metaForAllFiles_returnedResultValidItemsInList_afterCurrentFileMetaCall() throws {
        let testMeta = try createTwoTestFilesWithUniqueData()

        let sut = makeSUT()
        _ = sut.currentFileMeta()
 
        checkForEquality(first: sut.metaForAllFiles(), second: testMeta)
    }
    
    func test_metaForAllFiles_returnedResultContainsCreatedFile_afterCreate() throws {
        let sut = makeSUT()
        
        let createdFile = try createTestFile()
        
        checkForEquality(first: sut.metaForAllFiles(), second: [createdFile])
    }
    
    // MARK: - log method tests
    func test_log_returnEmpty_after_delete() throws {
        let sut = makeSUT()
        let fileMeta = try createTestFile( content: anyString)
        
        delete(file: fileMeta)
        
        let result = sut.log(fromFile: fileMeta, offset: 0)
        XCTAssertEqual(result, "")
    }
    
    func test_log_returnEmpty_afterSaveThenDelete() throws {
        let sut = makeSUT()
        let fileMeta = try createTestFile( content: anyString)

        sut.saveLog(anyString, to: fileMeta)
        delete(file: fileMeta)
        
        XCTAssertEqual(sut.log(fromFile: fileMeta, offset: 0), "")
    }
    
    func test_log_returnedResultValid_ifFileExistAndEmpty() throws {
        let fileMeta = try createTestFile(content: "")
        let sut = makeSUT()
        
        XCTAssertEqual(sut.log(fromFile: fileMeta, offset: 0), "")
    }
    
    func test_log_returnedResultValid_ifFileExistAndEmpty_andOffsetNotZero() throws {
        let fileMeta = try createTestFile(content: "")
        let sut = makeSUT()
        
        XCTAssertEqual(sut.log(fromFile: fileMeta, offset: anyNonZeroOffset), "")
    }
    
    func test_log_returnedResultValid_ifFileNotEmpty() throws {
        let fileMeta = try createTestFile(content: "Initial String")
        let sut = makeSUT()
        
        XCTAssertEqual(sut.log(fromFile: fileMeta, offset: 0), "Initial String")
    }
    
    func test_log_returnedResultValid_ifFileNotEmpty_andOffsetNotZero() throws {
        let fileMeta = try createTestFile(content: "Initial String")
        let sut = makeSUT()
        
        XCTAssertEqual(sut.log(fromFile: fileMeta, offset: 5), "al String")
    }
    
    // MARK: - saveLog method tests
    func test_saveLog_ensureFileNamesInExistingFilesAreNotChanged_afterSave() throws {
        var testMeta = [try createTestFile(), try createTestFile()]
        testMeta.sort()
        
        let fileNamesBeforeSave = testMeta.map { $0.fileName }
        
        let sut = makeSUT()
        sut.saveLog(anyString, to: testMeta[0])
        
        let fileNamesAfterSave = testMeta.map { $0.fileName }
        
        XCTAssertEqual(fileNamesBeforeSave, fileNamesAfterSave)
    }
    
    func test_saveLog_ensureFileSizesInExistingFilesAreNotChanged_afterSaveZeroSizeData() throws {
        var testMeta = [try createTestFile(content: "Some String"),
                        try createTestFile(content: "Another Some String"),
                        try createTestFile(content: "Any Some String")]
        testMeta.sort()
        
        let fileSizesBeforeSave = testMeta.map { $0.fileSize }
        
        let sut = makeSUT()
        sut.saveLog("", to: testMeta[0])
        
        let fileSizesAfterSave = testMeta.map { $0.fileSize }
        
        XCTAssertEqual(fileSizesBeforeSave, fileSizesAfterSave)
    }
    
    func test_saveLog_ensureFileSizesInOtherFilesAreNotChanged_afterSaveNonZeroSizeData() throws {
        var testMeta = [try createTestFile(content: "Some String"),
                        try createTestFile(content: "Another Some String"),
                        try createTestFile(content: "Any Some String")]
        testMeta.sort()

        let testMetaWithoutRecordingFile = Array(testMeta.dropFirst())
        let fileSizesBeforeSave = testMetaWithoutRecordingFile.map { $0.fileSize }
        
        let sut = makeSUT()
        sut.saveLog(anyString, to: testMeta[0])
        
        let fileSizesAfterSave = testMetaWithoutRecordingFile.map { $0.fileSize }
        
        XCTAssertEqual(fileSizesBeforeSave, fileSizesAfterSave)
    }
    
    func test_saveLog_ensureCreationDatesInExistingFilesAreNotChanged_afterSave() throws {
        let testMeta = try createTestFiles(number: 3).sorted()

        let creationDatesBeforeSave = testMeta.map { $0.creationDate }
        
        let sut = makeSUT()
        sut.saveLog("", to: testMeta[0])
        
        let creationDatesAfterSave = testMeta.map { $0.creationDate }
        
        XCTAssertEqual(creationDatesAfterSave, creationDatesBeforeSave)
    }
    
    func test_saveLog_ensureContentInExistingFilesAreNotChanged_afterSaveZeroSizeData() throws {
        let testMeta = try createTestFiles(withContent: tenBytesString, number: 3)

        let sut = makeSUT()
        let logsContentBeforeSave = testMeta.sorted().map { sut.log(fromFile: $0, offset: 0) }
        
        sut.saveLog("", to: testMeta[0])
        
        let logsContentAfterSave = (sut.metaForAllFiles() as? [FileMetaImpl])?.sorted().map { sut.log(fromFile: $0, offset: 0) }
        
        XCTAssertEqual(logsContentBeforeSave, logsContentAfterSave)
    }
    
    func test_saveLog_ensureContentInOtherFilesAreNotChanged_afterSaveNonZeroSizeData() throws {
        let testMeta = try createTestFiles(withContent: tenBytesString, number: 3)
                      
        let sut = makeSUT()
        
        let testMetaWithoutRecordingFile = Array(testMeta.dropFirst())
        let filesContentBeforeSave = testMetaWithoutRecordingFile.sorted().map { sut.log(fromFile: $0, offset: 0) }
        
        sut.saveLog(anyString, to: testMeta[0])
        
        var filesAfterSave = sut.metaForAllFiles() as? [FileMetaImpl]
        filesAfterSave?.removeAll(where: { $0 == testMeta[0] })
        let filesContentAfterSave = filesAfterSave?.sorted().map { sut.log(fromFile: $0, offset: 0) }
        
        XCTAssertEqual(filesContentBeforeSave, filesContentAfterSave)
    }
    
    func test_saveLog_ensureTargetFileContentChanged_afterSave() throws {
        let testMeta = try createTestFile(content: anyString)
        let sut = makeSUT()
        let testMetaContentBeforeSave = sut.log(fromFile: testMeta, offset: 0)
        
        sut.saveLog(anyString, to: testMeta)
        
        let testMetaContentAfterSave = sut.log(fromFile: testMeta, offset: 0)
        
        XCTAssert(testMetaContentBeforeSave != testMetaContentAfterSave)
    }
    
    func test_saveLog_ensureTargetFileContentChangedCorrectly_afterSave() throws {
        let testMeta = try createTestFile(content: anyString)
        let sut = makeSUT()
        
        sut.saveLog(anyString, to: testMeta)
        
        let testMetaContentAfterSave = sut.log(fromFile: testMeta, offset: 0)
        
        XCTAssertEqual(testMetaContentAfterSave, anyString + anyString)
    }
    
    // MARK: - delete method tests
    func test_delete_ensureFilesCountCorrect_afterDelete() throws {
        let testMeta = try createTestFiles(number: 3)
        
        let sut = makeSUT()
        sut.deleteFile(testMeta[1])
        
        XCTAssertEqual(existingLogFiles().count, 2)
    }
    
    func test_delete_ensureFilesValid_afterDelete() throws {
        var testMeta = try createTwoTestFilesWithUniqueData()
        
        let sut = makeSUT()
        sut.deleteFile(testMeta[0])
        
        let existingFiles = existingLogFiles().sorted()
        
        testMeta = Array(testMeta.dropFirst()).sorted()
        
        XCTAssertEqual(existingFiles, testMeta)
    }
    
    // MARK: - createFile method tests
    func test_createFile_ensureLogsFolderWasCreated() throws {
        deleteLogFolder()
        
        let sut = makeSUT()
        try createFile(inSut: sut)
        
        XCTAssert(fileManager.fileExists(atPath: testConfig.logsFolder))
    }
    
    func test_createFile_ensureFilesCountCorrect_afterCreate() throws {
        let sut = makeSUT()
        
        try createFile(inSut: sut)
        wait()
        try createFile(inSut: sut)

        XCTAssertEqual(existingLogFiles().count, 2)
    }
    
    func test_createFile_ensureReturnedResultFileSizeCorrect() throws {
        let sut = makeSUT()
        
        let createFile = try createFile(inSut: sut)

        XCTAssertEqual(createFile.fileSize, 0)
    }
    
    func test_createFile_ensureNewFileHaveSameNameAsRequested() throws {
        let sut = makeSUT()
        
        let newFileName = fileNameByDate(currentDate)
        let newFile = try createFile(inSut: sut, withFileName: newFileName)
        
        XCTAssertEqual(newFile.fileName, newFileName,
                       "Expected a file has the same name as provided in createFile method")
    }
    
    func test_createFile_ensureReturnedResultCreationDateValid() throws {
        let sut = makeSUT()
        
        let testFile = try createFile(inSut: sut)
        wait()
        
        XCTAssert(testFile.creationDate < Date())
    }
    
    func test_createFile_ensureNewFileExist() throws {
        let sut = makeSUT()
        
        let newFile = try createFile(inSut: sut)
        
        XCTAssertNotNil(existingLogFiles().first { $0.url == newFile.url }, fileNonExistentMess)
    }
    
    func test_createFile_ensureCreatedFileIsEmpty() throws {
        let sut = makeSUT()
        
        let newFile = try createFile(inSut: sut)
        let content = try logFrom(file: newFile)
        
        XCTAssertTrue(content.isEmpty)
    }
    
    func test_createFile_ensureNNewFileExist_afterCreationNFilesOneByOne() throws {
        let sut = makeSUT()
        
        let newFile1 = try createFile(inSut: sut)
        wait()
        let newFile2 = try createFile(inSut: sut)
        wait()
        let newFile3 = try createFile(inSut: sut)
        wait()
        
        XCTAssertNotNil(existingLogFiles().first { $0.url == newFile1.url }, fileNonExistentMess)
        XCTAssertNotNil(existingLogFiles().first { $0.url == newFile2.url }, fileNonExistentMess)
        XCTAssertNotNil(existingLogFiles().first { $0.url == newFile3.url }, fileNonExistentMess)
    }
    
    func test_createFile_ensureCurrentFileMetaCorrect_afterCreationNFilesOneByOne() throws {
        let sut = makeSUT()
        
        try createFile(inSut: sut)
        let newFile = try createFile(inSut: sut)
        
        XCTAssertEqual(sut.currentFileMeta()?.url, newFile.url)
    }
    
    func test_createFile_ensureCreatedFileContainsExtensionSuffix() throws {
        let sut = makeSUT()
        let newFile = try createFile(inSut: sut)
        
        XCTAssert(newFile.fileName.hasSuffix(testConfig.fileExtension))
    }
    
    func test_createFile_ensureCreatedFileContainsOnlyOneExtensionSuffix() throws {
        let sut = makeSUT()
        let newFile = try createFile(inSut: sut)
        
        XCTAssertFalse(newFile.fileName.dropLast(testConfig.fileExtension.count).hasSuffix(testConfig.fileExtension))
    }
    
    func test_createFile_ensureFileCreated_ifLogsFolderPathHaveSlashInEnd() throws {
        let sut = makeSUT(config: TestLoggerConfig(baseConfig: testConfig, includeSlash: true))
        
        try createFile(inSut: sut)
        XCTAssertEqual(existingLogFiles().count, 1)
    }
    
    func test_createFile_ensureFileCreated_ifLogsFolderPathNotHaveSlashInEnd() throws {
        let sut = makeSUT(config: TestLoggerConfig(baseConfig: testConfig, includeSlash: false))
        
        try createFile(inSut: sut)
        XCTAssertEqual(existingLogFiles().count, 1)
    }
    
    // MARK: - logSize method tests
    func test_logSize_returnedResultValid_whenInputEmpty() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.logSize(""), 0)
    }
    
    func test_logSize_returnedResultValid_whenInputNotEmpty() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.logSize(tenBytesString), 10)
    }
    
    // MARK: - currentFileMeta method tests
    func test_currentFileMeta_returnedResultNil_afterInit() {
        let sut = makeSUT()
        
        XCTAssertNil(sut.currentFileMeta())
    }
    
    func test_currentFileMeta_returnedResultNil_afterLogCall() throws {
        let testFileMeta = try createTestFile()
        let sut = makeSUT()
        
        _ = sut.log(fromFile: testFileMeta, offset: 0)
        XCTAssertNil(sut.currentFileMeta())
    }
    
    func test_currentFileMeta_returnedResultNil_afterDeleteCall() throws {
        let testFileMeta = try createTestFile()
        let sut = makeSUT()
        
        sut.deleteFile(testFileMeta)
        XCTAssertNil(sut.currentFileMeta())
    }
    
    func test_currentFileMeta_returnedResultNil_afterMetaForAllFilesCall() {
        let sut = makeSUT()
        
        _ = sut.metaForAllFiles()
        XCTAssertNil(sut.currentFileMeta())
    }
    
    func test_currentFileMeta_returnedResultNil_afterLogSizeCall_ForEmptyLog() {
        let sut = makeSUT()
        
        _ = sut.logSize("")
        XCTAssertNil(sut.currentFileMeta())
    }
    
    func test_currentFileMeta_returnedResultNil_afterLogSizeCall_ForNonEmptyLog() {
        let sut = makeSUT()
        
        _ = sut.logSize(anyString)
        XCTAssertNil(sut.currentFileMeta())
    }
    
    func test_currentFileMeta_returnedResultNotNil_afterCreate() throws {
        let sut = makeSUT()
        
        try createFile(inSut: sut)
        XCTAssertNotNil(sut.currentFileMeta())
    }
    
    func test_currentFileMeta_returnedResultNotNil_afterSaveLog() throws {
        let anyTestFile = try createTestFile()
        let sut = makeSUT()
        
        sut.saveLog(anyString, to: anyTestFile)
        XCTAssertNotNil(sut.currentFileMeta())
    }
    
    func test_currentFileMeta_ensureCurrentMetaFileSizeNotChanged_afterSaveLogWithZeroSizeData() throws {
        let anyTestFile = try createTestFile(content: tenBytesString)
        let testFileSizeBeforeSave = anyTestFile.fileSize
        let sut = makeSUT()
        
        sut.saveLog("", to: anyTestFile)
        
        XCTAssertEqual(sut.currentFileMeta()?.fileSize, testFileSizeBeforeSave)
    }
    
    func test_currentFileMeta_ensureCurrentMetaFileSizeChangedCorrectly_afterSaveLogWithNonZeroSizeData() throws {
        let anyTestFile = try createTestFile(content: tenBytesString)
        let testFileSizeBeforeSave = anyTestFile.fileSize
        let sut = makeSUT()
        
        sut.saveLog(tenBytesString, to: anyTestFile)
        XCTAssertEqual(sut.currentFileMeta()?.fileSize, testFileSizeBeforeSave + 10)
    }
    
    func test_currentFileMeta_ensureCurrentMetaFileFileNameCorrect_afterSaveLogCall() throws {
        let anyTestFile = try createTestFile(content: tenBytesString)
        let testFileNameBeforeSave = anyTestFile.fileName
        let sut = makeSUT()
        
        sut.saveLog(anyString, to: anyTestFile)
        XCTAssertEqual(sut.currentFileMeta()?.fileName, testFileNameBeforeSave)
    }
    
    func test_currentFileMeta_ensureCurrentMetaFileNil_afterDelete_ifItWasNotNilBefore() throws {
        let sut = makeSUT()
        let createdFile = try createFile(inSut: sut)
        
        sut.deleteFile(createdFile)
        XCTAssertNil(sut.currentFileMeta())
    }
    
    func test_currentFileMeta_ensureCurrentMetaFileNil_afterDeleteExistingFile_ifItWasNilBefore() throws {
        let anyTestFile = try createTestFile()
        let sut = makeSUT()
        
        sut.deleteFile(anyTestFile)
        XCTAssertNil(sut.currentFileMeta())
    }
    
    func test_currentFileMeta_ensureCurrentMetaFileExist_afterDeleteAnotherFile_ifItExistBefore() throws {
        let anyTestFile = try createTestFile()
        wait()

        let sut = makeSUT()
        
        try createFile(inSut: sut)
        wait()

        sut.deleteFile(anyTestFile)
        XCTAssertNotNil(sut.currentFileMeta())
    }
    
    // MARK: - logFiles method test
    func test_logFiles_resultEmptyIfNoFilesExists() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.logFiles().isEmpty)
    }
    
    func test_logFiles_resultNotEmptyIfAnyFilesExist() throws {
        let sut = makeSUT()
        
        try createTestFile()
        XCTAssertFalse(sut.logFiles().isEmpty)
    }
    
    func test_logFiles_resultIsCorrect() throws {
        let sut = makeSUT()

        let testFile1 = try createTestFile(content: "")
        wait()
        let testFile2 = try createTestFile(content: "")

        let files = [testFile1, testFile2]

        let result = sut.logFiles().sorted()
        let expect = files.map { LogFile(fileUrl: $0.url) }.sorted()

        XCTAssertEqual(result, expect)
    }

    func test_logFiles_newFileWillBeAddedInToList() throws {
        try createTestFile(content: "")
        wait()

        let sut = makeSUT()
        let newTestFile = try createTestFile(content: "")
        let result = sut.logFiles()

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains(LogFile(fileUrl: newTestFile.url)))
    }

    func test_logFiles_deletedFileWillNotContainsInList() throws {
        try createTestFile(content: "")
        wait()
        
        let testFile = try createTestFile(content: "")
        let sut = makeSUT()

        XCTAssertEqual(sut.logFiles().count, 2)

        delete(file: testFile)

        XCTAssertEqual(sut.logFiles().count, 1)
        XCTAssertFalse(sut.logFiles().contains(LogFile(fileUrl: testFile.url)))
    }
    
    // MARK: - Helpers
    private let fileNonExistentMess = "Expected a file with the same URL exists on the disk after created"
    
    private let tenBytesString = "ten bytes "
    private let anyNonZeroOffset: UInt = 1
    private let anyTestFileCount = 3
        
    @discardableResult
    private func createFile(inSut sut: LoggerStorage, withFileName fileName: String? = nil) throws -> FileMeta {
        let fileName = fileName ?? fileNameByDate(currentDate)
        
        return try sut.createFile(withName: fileName)
    }
        
    private func makeSUT(config: LoggerConfig? = nil) -> LoggerStorage {
        var config_: LoggerConfig = testConfig
        
        if let config = config {
            config_ = config
        }
        
        return LoggerStorageImpl(fileManager: fileManager,
                                 fileAttributeLoader: fileManager,
                                 config: config_)
    }
    
    private func delete(file: FileMeta) {
        try? fileManager.removeItem(atPath: file.url.path)
    }
    
    private func logFrom(file: FileMeta) throws -> String {
        try String(contentsOf: file.url, encoding: testConfig.encoding.stringEncoding)
    }
    
    private func checkForEquality(first: [FileMeta], second: [FileMeta],
                                  file: StaticString = #filePath, line: UInt = #line) {
        let sortedFirst = first.sorted(by: {$0.creationDate < $1.creationDate})
        
        XCTAssertEqual(sortedFirst as? [FileMetaImpl], second as? [FileMetaImpl], file: file, line: line)
    }
    
    private func createTwoTestFilesWithUniqueData() throws -> [FileMetaImpl] {
        let firstFile = try createTestFile(content: "some string")
        wait()
        let secondFile = try createTestFile(content: "any string")

        return [firstFile, secondFile]
    }
}
