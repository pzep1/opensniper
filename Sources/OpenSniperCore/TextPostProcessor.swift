import Foundation

public struct TextPostProcessor: Sendable {
    public var joinsLinesIntoParagraphs: Bool

    public init(joinsLinesIntoParagraphs: Bool) {
        self.joinsLinesIntoParagraphs = joinsLinesIntoParagraphs
    }

    public func normalize(lines: [String]) -> String {
        let cleanedLines = lines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard joinsLinesIntoParagraphs else {
            return cleanedLines.joined(separator: "\n")
        }

        return joinLines(cleanedLines)
    }

    private func joinLines(_ lines: [String]) -> String {
        var result = ""

        for line in lines {
            if result.isEmpty {
                result = line
                continue
            }

            if result.hasSuffix("-") {
                result.removeLast()
                result += line
            } else if lineLooksLikeContinuation(line) {
                result += " " + line
            } else {
                result += "\n" + line
            }
        }

        return result
    }

    private func lineLooksLikeContinuation(_ line: String) -> Bool {
        guard let firstScalar = line.unicodeScalars.first else {
            return false
        }

        return CharacterSet.lowercaseLetters.contains(firstScalar)
            || CharacterSet.decimalDigits.contains(firstScalar)
            || "([{".unicodeScalars.contains(firstScalar)
    }
}
