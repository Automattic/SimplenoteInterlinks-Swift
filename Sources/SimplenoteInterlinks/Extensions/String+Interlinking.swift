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
    public func interlinkKeyword(at location: String.Index, opening: Character = Character("["), closing: Character = Character("]")) -> (Range<String.Index>, String)? {
        guard let (lineRange, lineText) = line(at: location),
              let locationInLine = relativeIndex(for: lineText, in: lineRange, at: location)
        else {
            return nil
        }

        let (lhs, rhs) = lineText.split(at: locationInLine)
        guard rhs.containsUnbalancedClosingCharacter(opening: opening, closing: closing) == false else {
            return nil
        }

        guard let (keywordIndex, keywordText) = lhs.trailingLookupKeyword(opening: opening, closing: closing) else {
            return nil
        }

        let absoluteIndex = index(lineRange.lowerBound, offsetBy: lhs.location(for: keywordIndex))
        let absoluteRange = range(at: absoluteIndex, length: keywordText.count)

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

    /// Converts a Location (expressed as Integer) into a String.Index
    ///
    func index(for location: Int) -> String.Index? {
        guard let unicodeLocation = utf16.index(utf16.startIndex, offsetBy: location, limitedBy: utf16.endIndex),
            let location = unicodeLocation.samePosition(in: self) else {
                return nil
        }

        return location
    }

    /// Converts a String.Index into a Location (expressed as integer)
    ///
    func location(for index: String.Index) -> Int {
        return distance(from: startIndex, to: index)
    }

    /// Returns the `Range<String.Index>` for a Substring at the specified location
    ///
    func range(at index: String.Index, length: Int) -> Range<String.Index> {
        index ..< self.index(index, offsetBy: length)
    }

    /// Maps a `String.Index`, in terms of the receiver, into an index contstrained by the specified substring
    ///
    func relativeIndex(for substring: String, in range: Range<String.Index>, at index: String.Index) -> String.Index? {
        let delta = distance(from: startIndex, to: index) - distance(from: startIndex, to: range.lowerBound)
        return substring.index(for: delta)
    }

    /// Returns a tuple with `(Range, Text)` of the Line at the specified location
    ///
    func line(at location: String.Index) -> (Range<String.Index>, String)? {
        guard let range = rangeOfLine(at: location) else {
            return nil
        }

        return (range, String(self[range]))
    }

    /// Returns the range of the line at the specified `String.Index`
    ///
    func rangeOfLine(at location: String.Index) -> Range<String.Index>? {
        lineRange(for: location..<location)
    }
}
