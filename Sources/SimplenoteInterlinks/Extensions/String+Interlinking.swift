import Foundation


// MARK: - String + Interlinking API(s)
//
extension String {

    /// Returns the Interlink Keyword at the receiver's location, if any.
    ///
    /// - Parameters:
    ///     - location: Location to analyze
    ///     - opening: Opening Keyword Character
    ///     - closing: Closing Keyword Character
    ///
    /// - Returns: Keyword, if any.
    /// - Note: This API extracts the keyword at a given location, with this shape: `[keyword`.
    /// - Important: If a closing character is found on the right hand side, this API returns nil
    ///
    public func interlinkKeyword(at location: Int, opening: Character = Character("["), closing: Character = Character("]")) -> (Range<String.Index>, String)? {
        guard let (lineRange, lineText) = line(at: location) else {
            return nil
        }

        let locationInLine = relativeLocation(for: location, in: lineRange)
        let (lhs, rhs) = lineText.split(at: locationInLine)
        guard rhs.containsUnbalancedClosingCharacter(opening: opening, closing: closing) == false else {
            return nil
        }

        guard let (keywordIndex, keywordText) = lhs.trailingLookupKeyword(opening: opening, closing: closing) else {
            return nil
        }

        let keywordLocation = self.location(for: lineRange.lowerBound) + lhs.location(for: keywordIndex)
        let keywordRange = rangeOfSubstring(at: keywordLocation, length: keywordText.count)

        return (keywordRange, keywordText)
    }

    /// Returns **true** whenever the receiver contains an unbalanced Closing Character
    ///
    func containsUnbalancedClosingCharacter(opening: Character, closing: Character) -> Bool {
        var stack = [Character]()

        for character in self {
            switch character {
            case opening:
                stack.append(character)

            case closing where !stack.isEmpty:
                _ = stack.popLast()

            case closing where stack.isEmpty:
                return true

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
    func split(at location: Int) -> (String, String) {
        let locationAsIndex = index(for: location)
        let lhs = String(self[startIndex..<locationAsIndex])
        let rhs = String(self[locationAsIndex..<endIndex])

        return (lhs, rhs)
    }

    /// Converts a Location (expressed as Integer) into a String.Index
    ///
    func index(for location: Int) -> String.Index {
        return index(startIndex, offsetBy: location)
    }

    /// Converts a String.Index into a Location (expressed as integer)
    ///
    func location(for index: String.Index) -> Int {
        return distance(from: startIndex, to: index)
    }

    /// Returns the `Range<String.Index>` for a Substring at the specified location
    ///
    func rangeOfSubstring(at location: Int, length: Int) -> Range<String.Index> {
        let substringStartIndex = index(for: location)
        let substringEndIndex = index(substringStartIndex, offsetBy: length)

        return substringStartIndex ..< substringEndIndex
    }

    /// Returns the Relative Location of a given Location, within the specified range.
    /// For instance:
    /// - Location: 10
    /// - Range: (Location = 10, Length = 10)
    /// - Relative Location: Zero!
    ///
    func relativeLocation(for location: Int, in range: Range<String.Index>) -> Int {
        return location - self.location(for: range.lowerBound)
    }

    /// Returns a tuple with `(Range, Text)` of the Line at the specified location
    ///
    func line(at location: Int) -> (Range<String.Index>, String)? {
        guard let range = rangeOfLine(at: location) else {
            return nil
        }

        return (range, String(self[range]))
    }

    /// Returns the range of the line at the specified `String.Index`
    ///
    func rangeOfLine(at location: Int) -> Range<String.Index>? {
        guard count >= location else {
            return nil
        }

        let locationStartIndex = index(for: location)
        return lineRange(for: locationStartIndex..<locationStartIndex)
    }
}
