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

        if lineText.isEmpty {
            return nil
        }

        // Step #1: Determine the relative String.Index, with regards of the line of text we're analyzing
        guard let indexInLine = transportIndex(index, to: lineRange, in: lineText) else {
            return nil
        }

        // Step #2: Split the Line exactly at the position we're analyzing for Keywords
        let (lhs, rhs) = lineText.split(at: indexInLine)

        // Step #3: If the RHS contains an unbalanced `]`, we should not proceed
        if rhs.containsUnbalancedClosingCharacter(opening: opening, closing: closing) {
            return nil
        }

        // Step #4: Extract any keywords on the LHS of the cursor's Index
        guard let (keywordIndex, keywordText) = lhs.trailingLookupKeyword(opening: opening, closing: closing) else {
            return nil
        }

        // Step #5: keywordStartIndex = Line Start + Keyword Start
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
        guard let openingTailIndex = lastIndex(of: opening), let keywordIndex = index(openingTailIndex, offsetBy: 1, limitedBy: endIndex) else {
            return nil
        }

        let keywordString = self[keywordIndex..<endIndex]
        if keywordString.contains(closing) || keywordString.isEmpty {
            return nil
        }

        return (keywordIndex, String(keywordString))
    }
}
