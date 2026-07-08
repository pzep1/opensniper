import XCTest
@testable import OpenSniperCore

final class TextPostProcessorTests: XCTestCase {
    func testKeepsLinesWhenJoiningIsDisabled() {
        let processor = TextPostProcessor(joinsLinesIntoParagraphs: false)

        XCTAssertEqual(
            processor.normalize(lines: ["  First line  ", "", "Second line"]),
            "First line\nSecond line"
        )
    }

    func testJoinsLikelyContinuationLines() {
        let processor = TextPostProcessor(joinsLinesIntoParagraphs: true)

        XCTAssertEqual(
            processor.normalize(lines: ["Open source OCR", "for macOS menu bars"]),
            "Open source OCR for macOS menu bars"
        )
    }

    func testRemovesHyphenationAcrossLines() {
        let processor = TextPostProcessor(joinsLinesIntoParagraphs: true)

        XCTAssertEqual(
            processor.normalize(lines: ["recog-", "nition"]),
            "recognition"
        )
    }

    func testPreservesLikelyHeadings() {
        let processor = TextPostProcessor(joinsLinesIntoParagraphs: true)

        XCTAssertEqual(
            processor.normalize(lines: ["Title", "Next Section"]),
            "Title\nNext Section"
        )
    }
}
