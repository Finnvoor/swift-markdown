/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

/// A heading.
public struct Heading: BlockMarkup, InlineContainer {
    public var _data: _MarkupData

    init(_ raw: RawMarkup) throws {
        guard case .heading = raw.data else {
            throw RawMarkup.Error.concreteConversionError(from: raw, to: Heading.self)
        }
        let absoluteRaw = AbsoluteRawMarkup(markup: raw, metadata: MarkupMetadata(id: .newRoot(), indexInParent: 0))
        self.init(_MarkupData(absoluteRaw))
    }

    init(_ data: _MarkupData) {
        self._data = data
    }
}

// MARK: - Public API

public extension Heading {
    // MARK: Primitive

    /// Create a heading with a level and a sequence of children.
    init<Children: Sequence>(level: Int, setext: Bool, _ children: Children) where Children.Element == InlineMarkup {
        try! self.init(.heading(level: level, setext: setext, parsedRange: nil, children.map { $0.raw.markup }))
    }

    /// The level of the heading, starting at `1`.
    var level: Int {
        get {
            guard case let .heading(level, _) = _data.raw.markup.data else {
                fatalError("\(self) markup wrapped unexpected \(_data.raw)")
            }
            return level
        }
        set {
            precondition(newValue > 0, "Heading level must be 1 or greater")
            guard level != newValue else {
                return
            }
            _data = _data.replacingSelf(.heading(level: newValue, setext: setext, parsedRange: nil, _data.raw.markup.copyChildren()))
        }
    }
    
    var setext: Bool {
        get {
            guard case let .heading(_, setext) = _data.raw.markup.data else {
                fatalError("\(self) markup wrapped unexpected \(_data.raw)")
            }
            return setext
        }
        set {
            guard setext != newValue else {
                return
            }
            _data = _data.replacingSelf(.heading(level: level, setext: newValue, parsedRange: nil, _data.raw.markup.copyChildren()))
        }
    }

    // MARK: Secondary

    /// Create a heading with a level and a sequence of children.
    init(level: Int, setext: Bool, _ children: InlineMarkup...) {
        self.init(level: level, setext: setext, children)
    }

    // MARK: Visitation

    func accept<V: MarkupVisitor>(_ visitor: inout V) -> V.Result {
        return visitor.visitHeading(self)
    }
}
