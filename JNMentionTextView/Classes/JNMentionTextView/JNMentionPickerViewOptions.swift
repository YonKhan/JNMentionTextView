//
//  JNMentionOptions.swift
//  JNMentionTextView
//
//  Created by JNDisrupter 💡 on 6/17/19.
//

import UIKit

/// JNMention Picker View Position Mode
public struct JNMentionPickerViewPositionwMode: OptionSet {
    
    /// Raw Value
    public var rawValue: UInt
    
    /**
     Init With rawValue
     - Paramerter rawValue: Raw Value.
     */
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// Picker View Positionw Mode Up
    public static let up = JNMentionPickerViewPositionwMode(rawValue: 0)
    
    /// Picker View Positionw Mode Down
    public static let down = JNMentionPickerViewPositionwMode(rawValue: 1)
    
    /// Picker View Positionw Mode automatic
    public static let automatic = JNMentionPickerViewPositionwMode(rawValue: 2)
}

/// JNMention Picker View Options
public struct JNMentionPickerViewOptions {
    
    /// Background Color
    var backgroundColor: UIColor
    
    /// View Position Mode
    var viewPositionMode: JNMentionPickerViewPositionwMode

    /// Bolean indicates if a given mention can be 'trimmed'. Trimming is a feature of the mentions plug-in that allows the mention to be truncated if and only if the user taps 'Delete' while the cursor is at the end of the mention.
    var entityCanBeTrimmed: Bool

    /**
     Initializer
     - Parameter backgroundColor: Background color.
     - Parameter viewPositionMode: JNMention View Mode.
     */
    public init(backgroundColor: UIColor = UIColor.white,
                viewPositionMode: JNMentionPickerViewPositionwMode,
                entityCanBeTrimmed: Bool = false) {

        // background Color
        self.backgroundColor = backgroundColor
        
        // view position mode
        self.viewPositionMode = viewPositionMode

        self.entityCanBeTrimmed = entityCanBeTrimmed
    }
}
