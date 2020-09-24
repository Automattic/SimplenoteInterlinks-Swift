import Foundation
import SimplenoteFoundation


// MARK: - String + Interlinking API(s)
//
extension String {

    /// Returns the Interlink Keyword at the receiver's location, if any.
    ///
    /// - Parameters:
    ///     - index: String.Index at which we should perform our analysis
    ///     - opening: Opening Keyword Character
    ///     - closing: Closing Keyword Character
    ///
    /// - Returns: Keyword, if any.
    /// - Note: This API extracts the keyword at a given String.Index, with this shape: `[keyword`.
    /// - Important: If a closing character is found on the right hand side, this API returns nil
    ///
    public func interlinkKeyword(at index: String.Index, opening: Character = Character("["), closing: Character = Character("]")) -> (Range<String.Index>, String)? {
        // Step #0: Determine the Line where we're standing
        let (lineRange, lineText) = line(at: index)

        // Step #1: Determine the relative String.Index, with regards of the line of text we're analyzing
        let locationInLine = transportIndex(index, to: lineRange, in: lineText)

        // Step #2: Split + Analyzer
        let (lhs, rhs) = lineText.split(at: locationInLine)

        guard rhs.containsUnbalancedClosingCharacter(opening: opening, closing: closing) == false else {
            return nil
        }

        guard let (keywordIndex, keywordText) = lhs.trailingLookupKeyword(opening: opening, closing: closing) else {
            return nil
        }

        // Step #3: keywordStartIndex = Line Start + Keyword Start
        let absoluteIndex = self.index(lineRange.lowerBound, offsetBy: lhs.distance(from: lhs.startIndex, to: keywordIndex))
        let absoluteRange = absoluteIndex ..< self.index(absoluteIndex, offsetBy: keywordText.count)

        return (absoluteRange, keywordText)
    }

    /// Returns **true** whenever the receiver contains an unbalanced Closing Character
    ///
    func containsUnbalancedClosingCharacter(opening: Character, closing: Character) -> Bool {
        var stack = [Character]()

        for character in self.reversed() {
            switch character {
            case closing:
                stack.append(character)

            case opening:
                _ = stack.popLast()
                // Note: We *don't care* about unbalanced opening characters!

            default:
                continue
            }
        }

        return stack.isEmpty == false
    }

    /// Looks up for the first `Opening Character` occurrence, starting from the tail of the receiver.
    /// If located, this API will return the substring succeeding such character, only if such does not contain the Closing Character.
    ///
    /// - Example: `Text [keyword`
    /// - Result: `keyword`
    ///
    func trailingLookupKeyword(opening: Character, closing: Character) -> (String.Index, String)? {
        guard let lastOpeningCharacterIndex = lastIndex(of: opening) else {
            return nil
        }

        let keywordIndex = index(lastOpeningCharacterIndex, offsetBy: 1)
        let keywordString = self[keywordIndex..<endIndex]
        if keywordString.contains(closing) || keywordString.isEmpty {
            return nil
        }

        return (keywordIndex, String(keywordString))
    }

    /// Splits the receiver at the specified location
    ///
    func split(at location: String.Index) -> (String, String) {
        let lhs = String(self[startIndex..<location])
        let rhs = String(self[location..<endIndex])

        return (lhs, rhs)
    }

    /// Returns a tuple with `(Range, Text)` of the Line at the specified location
    ///
    func line(at index: String.Index) -> (Range<String.Index>, String) {
        let range = rangeOfLine(at: index)
        return (range, String(self[range]))
    }

    /// Returns the range of the line at the specified `String.Index`
    ///
    func rangeOfLine(at index: String.Index) -> Range<String.Index> {
        lineRange(for: index..<index)
    }
}
