//
//  JNMentionTextView+UITextViewDelegate.swift
//  JNMentionTextView
//
//  Created by JNDisrupter 💡 on 6/17/19.
//

import UIKit

/// UITextViewDelegate
extension JNMentionTextView: UITextViewDelegate {
    
    /**
     Should Change Text In
     */
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // return if delegate indicate that it sohuld not chnage text in the selected range.
        if let delegate = self.mentionDelegate, !(delegate.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true) {
            return false
        }
        
        // ShouldChangeText
        var shouldChangeText = true
        
        // In Filter Process
        if self.isInMentionProcess() {
            
            // delete text
            if text.isEmpty {
                
                // delete the special symbol string
                if range.location == self.selectedSymbolLocation {
                    
                    // end mention process
                    self.endMentionProcess()
                    
                } else {
                    
                    // deleted index
                    let deletedIndex = range.location - self.selectedSymbolLocation - 1
                    
                    // deleted index greter than -1
                    guard deletedIndex > -1 && deletedIndex < self.searchString.count
                        else {
                            self.endMentionProcess()
                            return true
                    }
                    
                    let index = self.searchString.index(self.searchString.startIndex, offsetBy: deletedIndex)
                    self.searchString.remove(at: index)
                    
                    // Retrieve Picker Data
                    self.pickerViewRetrieveData()
                }
                
            } else {
                self.searchString += text
               
                // Retrieve Picker Data
                self.pickerViewRetrieveData()
            }
                        
        } else {
            
            /// mentionDeletionProcess
            var mentionDeletionProcess = false
            
            // check if delete already mentioned item
            if let selectedRange = self.selectedTextRange {
                
                // cursor position
                let cursorPosition = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
                guard cursorPosition > 0 else { return true }
                
                // iterate through all range
                self.attributedText.enumerateAttributes(in: NSRange(0..<self.textStorage.length), options: []) { (attributes, rangeAttributes, stop) in
                    
                    // get value for JNMentionNSAttribute
                    if let mentionedItem = attributes[JNMentionTextView.JNMentionAttributeName] as? JNMentionEntity,
                       cursorPosition > rangeAttributes.location && (text.isEmpty ? cursorPosition - 1 : cursorPosition) <= rangeAttributes.location + rangeAttributes.length {
                        
                        // init replacement string
                        // if entity can be trimmed, replace the text with a empty, else with the mention
                        let replacementString = options.entityCanBeTrimmed ? "" : mentionedItem.symbol + mentionedItem.item.getPickableTitle()

                        // replace the mentioned item with (symbol with mentioned title)
                        self.textStorage.replaceCharacters(in: rangeAttributes, with: NSAttributedString(string: replacementString, attributes: self.normalAttributes))
                        
                        // move cursor to the end of replacement string
                        self.moveCursor(to: rangeAttributes.location + replacementString.count)

                        if options.entityCanBeTrimmed {
                            // end mention process
                            self.endMentionProcess()

                            // set mention deletion process false
                            mentionDeletionProcess = false
                        }  else {
                            /// set selected symbol information
                            self.selectedSymbol = mentionedItem.symbol
                            self.selectedSymbolLocation = rangeAttributes.location
                            self.selectedSymbolAttributes = attributes

                            /// start mention process with search string for tem title
                            self.searchString = mentionedItem.item.getPickableTitle()
                            self.startMentionProcess()

                            // set mention deletion process true
                            mentionDeletionProcess = true
                        }

                        // skip this change in text
                        shouldChangeText = false
                    }
                }
                
                
                // check to start mention process for special characters
                if text.isEmpty && !mentionDeletionProcess {
                    
                    /* This Code Needs Will be added later because it will do the calculations every time we delete char.
                    // get special chracters
                    let charactersArray = Array(self.textStorage.string)
                    var indexArray: [Int] = []

                    for key in self.mentionReplacements.keys {
                        let indices = charactersArray.enumerated()
                            .compactMap { $0.element == Character(key) ? $0.offset : nil }

                        indexArray.append(contentsOf: indices)
                    }

                    // filter index less than my index
                    if !indexArray.isEmpty {
                        indexArray = indexArray.filter({ $0 <= cursorPosition })
                        if let minDifference = indexArray.map({ cursorPosition - $0 }).min() {
                            self.selectedSymbolLocation = cursorPosition - minDifference
                            self.selectedSymbol = String(Array(self.textStorage.string)[self.selectedSymbolLocation])
                            self.selectedSymbolAttributes = self.mentionReplacements[self.selectedSymbol]
                            self.searchString = self.textStorage.attributedSubstring(from: NSRange(location: self.selectedSymbolLocation + 1, length: minDifference - 2)).string

                            self.startMentionProcess()
                         
                        }
                    }
                    */
                } else {
                    
                    // set normal attributes
                    self.normalAttributes = self.typingAttributes
                }
            }
        }
        
        return shouldChangeText
    }
    
    /**
     Text View Did Change
     */
    open func textViewDidChange(_ textView: UITextView) {
        
        // calculate range
        let range = NSRange(location: 0, length: self.attributedText.string.count)
        self.applyMentionEngine(searchRange: range)
        
        // call delegate
        self.mentionDelegate?.textViewDidChange?(textView)
    }
    
    /**
     Text View should begin editing
     */
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return self.mentionDelegate?.textViewShouldBeginEditing?(textView) ?? true
    }
    
    /**
     Text View should end editing
     */
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return self.mentionDelegate?.textViewShouldEndEditing?(textView) ?? true
    }
    
    /**
     Text View Did begin editing
     */
    open func textViewDidBeginEditing(_ textView: UITextView) {
        self.mentionDelegate?.textViewDidBeginEditing?(textView)
    }
    
    /**
     Text View Did end editing
     */
    open func textViewDidEndEditing(_ textView: UITextView) {
        
        // end mention process
        self.endMentionProcess {
            self.mentionDelegate?.textViewDidEndEditing?(textView)
        }
    }
    
    /**
     Text View did change selection
     */
    open func textViewDidChangeSelection(_ textView: UITextView) {
        self.mentionDelegate?.textViewDidChangeSelection?(textView)
    }
    
    /**
     Text View should interact with url.
     */
    open func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return self.mentionDelegate?.textView?(textView, shouldInteractWith: URL, in: characterRange) ?? true
    }
    
    /**
     Text View should interact with url in range with interaction.
     */
    @available(iOS 10.0, *)
    open func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return self.mentionDelegate?.textView?(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true
    }
    
    /**
     Text View should interact with text attachment in range with interaction.
     */
    @available(iOS 10.0, *)
    open func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return self.mentionDelegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true
    }
    
    /**
     Text View should interact with text attachment in range.
     */
    open func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        return self.mentionDelegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange) ?? true
    }
}
