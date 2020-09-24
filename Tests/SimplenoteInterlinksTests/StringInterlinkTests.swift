import XCTest
@testable import SimplenoteInterlinks


// MARK: - String+Interlink Unit Tests
//
class StringInterlinkTests: XCTestCase {

    /// Verifies that `interlinkKeyword(at:)` returns nil whenever the `[keyword` is not located at the left hand side of the specified location
    ///
    func testInterlinkKeywordReturnsNilWheneverTheSpecifiedLocationDoesNotContainTrailingOpeningBrackets() {
        let lhs = "irrelevant prefix string here ["
        let keyword = "Some long keyword should be here"
        let text = lhs + keyword

        for location in Int.zero ..< lhs.count {
            let index = text.index(text.startIndex, offsetBy: location)
            XCTAssertNil(text.interlinkKeyword(at: index))
        }
    }

    /// Verifies that `interlinkKeyword(at:)` returns the `[keyword substring` at the specified location
    /// We use a `sample text containing [a simplenote innerlink`, and verify the keyword on the left hand side is always returned
    ///
    func testInterlinkKeywordReturnsTheTextOnTheLeftHandSideOfTheSpecifiedLocationAndPerformsSuper() {
        let keyword = "Some long keyword should be here"
        let lhs = String(repeating: "an extremely long text should probably go here ", count: 2048)
        let text = lhs + "[" + keyword

        let rangeOfKeyword = text.range(of: keyword)!
        let locationOfKeyword = text.distance(from: text.startIndex, to: rangeOfKeyword.lowerBound) + 1

        for location in locationOfKeyword...text.count {
            let currentIndex = text.index(text.startIndex, offsetBy: location)
            let expectedKeywordSlice = String(text[rangeOfKeyword.lowerBound ..< currentIndex])

            guard let (resultingKeywordRange, resultingKeywordSlice) = text.interlinkKeyword(at: currentIndex) else {
                XCTFail()
                continue
            }

            XCTAssertEqual(resultingKeywordSlice, expectedKeywordSlice)
            XCTAssertEqual(expectedKeywordSlice, String(text[resultingKeywordRange]))
        }
    }

    /// Verifies that `interlinkKeyword(at:)` returns nil whenever the receiver contains an Opening Bracket, but no text
    ///
    func testInterlinkKeywordReturnsNilWheneverThereIsNoTextAfterOpeningBracket() {
        let text = "["
        XCTAssertNil(text.interlinkKeyword(at: text.startIndex))
    }

    /// Verifies that `interlinkKeyword(at:)` returns nil whenever the receiver contains a properly closed Interlink
    ///
    func testInterlinkKeywordReturnsNilWheneverTheBracketsAreClosed() {
        let text = "irrelevant prefix string here [Some text should also go here maybe!]"

        for location in Int.zero ..< text.count {
            let index = text.index(text.startIndex, offsetBy: location)
            XCTAssertNil(text.interlinkKeyword(at: index))
        }
    }

    /// Verifies that `interlinkKeyword(at:)` can extract a new keyword being edited, located in between two closed keywords
    ///
    func testInterlinkKeywordReturnsTheProperSubstringWhenEditingSomeNewLinkInBetweenTwoProperlyFormedLinks() {
        let keyword = "new keyword"
        let text = "Hexadecimal 🇮🇳 🌍 is made up of [numbers](simplenote://note/123456) and [" + keyword + " 🇮🇳 🌍 [letters](simplenote://note/abcdef)."

        let rangeOfKeyword = text.range(of: keyword)!
        let locationOfKeyword = text.distance(from: text.startIndex, to: rangeOfKeyword.lowerBound) + 1

        // Starting after the first character!
        for location in locationOfKeyword ... locationOfKeyword + keyword.count {
            let currentIndex = text.index(text.startIndex, offsetBy: location)
            let expectedKeywordSlice = String(text[rangeOfKeyword.lowerBound ..< currentIndex])

            guard let (resultingKeywordRange, resultingKeywordSlice) = text.interlinkKeyword(at: currentIndex) else {
                XCTFail()
                continue
            }

            XCTAssertEqual(resultingKeywordSlice, expectedKeywordSlice)
            XCTAssertEqual(expectedKeywordSlice, String(text[resultingKeywordRange]))
        }
    }

    /// Verifies that `containsUnbalancedClosingCharacter` returns true whenever the receiver contains unbalanced balanced `[]` pairs
    ///
    func testContainsUnbalancedClosingCharacterReturnsTrueWhenTheReceiverContainsUnbalancedClosingCharacters() {
        let samples = [
            "][]",
            "[]]",
        ]

        for sample in samples {
            XCTAssertTrue(sample.containsUnbalancedClosingCharacter(opening: Character("["), closing: Character("]")))
        }
    }

    /// Verifies that `containsUnbalancedClosingCharacter` returns false whenever the receiver contains properly balanced `[]` pairs
    ///
    func testContainsUnbalancedClosingCharacterReturnsFalseWhenTheReceiverDoesNotContainUnbalancedClosingCharacters() {
        let samples = [
            "[]",
            "[[]]",
            "[[[]]]",
            "[][][]"
        ]

        for sample in samples {
            XCTAssertFalse(sample.containsUnbalancedClosingCharacter(opening: Character("["), closing: Character("]")))
        }
    }

    /// Verifies that `containsUnbalancedClosingCharacter` returns false whenever there are unbalanced Opening Characters, but not Closing
    ///
    func testContainsUnbalancedClosingCharacterReturnsFalseWhenThereAreOnlyUnblancedOpeningCharacters() {
        let samples = [
            "[",
            "[][",
            "[[]][",
            "[[[]]][",
        ]

        for sample in samples {
            XCTAssertFalse(sample.containsUnbalancedClosingCharacter(opening: Character("["), closing: Character("]")))
        }
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` returns nil whenever the receiver does not contain any lookup keywords
    ///
    func testTrailingLookupKeywordReturnsNilWhenThereAreNoLookupKeywords() {
        let text = "qwertyuiop"
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertNil(result)
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` returns nil whenever the receiver contains a closed keyword
    ///
    func testTrailingLookupKeywordReturnsNilWhenTheLookupKeywordIsClosedYetEmpty() {
        let text = "[]"
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertNil(result)
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` returns nil whenever the receiver contains multiple closed keywords
    ///
    func testTrailingLookupKeywordReturnsNilWhenThereAreNoUnclosedLookupKeywords() {
        let text = "[keyword 1] lalalala [keyword 2] lalalalaa [keyword 3]"
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertNil(result)
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` returns any trailing `[lookup keyword`
    /// - Note: It must not contain a closing `]`!
    ///
    func testTrailingLookupKeywordReturnsTheKeywordAfterTheOpeningCharacter() {
        let keyword = "some keyword here"
        let text = "qwertyuiop [" + keyword
        let range = text.range(of: keyword)

        guard let (resultIndex, resultText) = text.trailingLookupKeyword(opening: "[", closing: "]") else {
            XCTFail()
            return
        }

        XCTAssertEqual(resultText, keyword)
        XCTAssertEqual(range?.lowerBound, resultIndex)
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` returns the trailing `[lookup keyword`, whenever there's more than one keyword
    ///
    func testTrailingLookupKeywordReturnsTheLastKeywordWhenThereAreManyKeywords() {
        let keyword1 = "some keyword here"
        let keyword2 = "the real keyword"

        let text = "qwertyuiop [" + keyword1 + "] asdfghjkl [" + keyword2
        let range = text.range(of: keyword2)

        guard let (resultIndex, resultText) = text.trailingLookupKeyword(opening: "[", closing: "]") else {
            XCTFail()
            return
        }

        XCTAssertEqual(resultText, keyword2)
        XCTAssertEqual(range?.lowerBound, resultIndex)
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` works as expected, when the receiver actually starts with the `[lookup keyword`
    ///
    func testTrailingLookupKeywordWorksAsExpectedWheneverTheInputStringStartsWithTheOpeningCharacter() {
        let keyword = "some keyword here"
        let text = "[" + keyword
        let range = text.range(of: keyword)

        guard let (resultIndex, resultText) = text.trailingLookupKeyword(opening: "[", closing: "]") else {
            XCTFail()
            return
        }

        XCTAssertEqual(resultText, keyword)
        XCTAssertEqual(range?.lowerBound, resultIndex)
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` returns nil whenever the receiver only contains an  opening character `[`
    ///
    func testTrailingLookupKeywordReturnsNilWhenTheActualKeywordIsEmpty() {
        let text = "["
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertNil(result)
    }


    /// Verifies that `split(at:)` properly cuts the receiver at the specified location
    ///
    func testSplitAtLocationReturnsTheExpectedSubstrings() {
        let lhs = "some random 🇮🇳 text on the left hand side"
        let rhs = "and some more 🌎 random text on the right hand side"
        let text = lhs + rhs
        let lhsEndIndex = text.index(text.startIndex, offsetBy: lhs.count)

        let (splitLHS, splitRHS) = text.split(at: lhsEndIndex)
        XCTAssertEqual(lhs, splitLHS)
        XCTAssertEqual(rhs, splitRHS)
    }

    /// Verifies that `split(at:)` properly handles Empty Strings
    ///
    func testSplitAtLocationReturnsEmptyStringsWhenTheReceiverIsEmpty() {
        let text = ""
        let (lhs, rhs) = text.split(at: text.startIndex)

        XCTAssertTrue(lhs.isEmpty)
        XCTAssertTrue(rhs.isEmpty)
    }

    /// Verifies that `split(at:)` returns an empty `RHS` string, whenever the cut location matches the end of the receiver
    ///
    func testSplitAtLocationProperlyHandlesLocationsAtTheEndOfTheString() {
        let text = "this is supposed to be a single but relatively long line of text"
        let (lhs, rhs) = text.split(at: text.endIndex)

        XCTAssertEqual(lhs, text)
        XCTAssertEqual(rhs, "")
    }

    /// Verifies that `line(at:)` returns a touple with Range + Text for the Line at the specified Location
    ///
    func testLineAtIndexReturnsTheExpectedLineForTheSpecifiedLocation() {
        let lines = [
            "alala lala long long le long long long!\n",
            "this is supposed to be the second line\n",
            "and this would be the third line in the document\n",
            "only to be followed by a trailing and final line!"
        ]

        let text = lines.joined()
        var padding = Int.zero

        for line in lines {
            for location in Int.zero ..< line.count {
                let index = text.index(text.startIndex, offsetBy: location + padding)
                let (lineRange, lineText) = text.line(at: index)

                XCTAssertEqual(lineText, line)
                XCTAssertEqual(String(text[lineRange]), lineText)
            }

            padding += line.count
        }
    }
}

