//
//  ViewController.swift
//  TextViewWithPlaceholders
//
//  Created by Bart van Kuik on 03/04/2017.
//  Copyright © 2017 DutchVirtual. All rights reserved.
//

import UIKit

extension String {
    func allRanges(of string: String) -> [Range<String.Index>] {
        var allRanges = [Range<String.Index>]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            allRanges.append(range)
            searchStartIndex = range.upperBound
        }
        
        return allRanges
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    let placeholder = "{....}"
    var ranges = [Range<String.Index>]()
    
    // MARK: - Actions
    
    @IBAction func previousButtonTapped(_ sender: UIButton) {
        print("previous")
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        print("next")
        self.selectNextPlaceholder()
    }
    
    // MARK: - Private functions
    
    private func updatePlaceholderRanges() {
        guard let text = self.textView.text else {
            self.ranges = []
            return
        }

        self.ranges = text.allRanges(of: self.placeholder)
        print("Found \(self.ranges.count) ranges")
    }
    
    
    private func selectNextPlaceholder() {
        guard let text = self.textView.text else {
            return
        }
        
        self.textView.becomeFirstResponder()

        self.updatePlaceholderRanges()
        
        // Find current cursor position
        guard let currentlySelectedRange = self.textView.selectedTextRange else {
            print("Couldn't find current range")
            return
        }
            
        var cursorPosition = self.textView.offset(from: self.textView.beginningOfDocument, to: currentlySelectedRange.start)
        print("Current position: \(cursorPosition)")
        
        for range in self.ranges {
            let rangeStart = text.distance(from: text.startIndex, to: range.lowerBound)
            let rangeEnd = text.distance(from: text.startIndex, to: range.upperBound)
            print("Range: \(range)")

            if rangeStart > cursorPosition {
                // Convert to UITextPosition, and set new selection
                let textPositionStart = self.textView.position(from: self.textView.beginningOfDocument, offset: rangeStart)
                let textPositionEnd = self.textView.position(from: self.textView.beginningOfDocument, offset: rangeEnd)

                if let start = textPositionStart, let end = textPositionEnd {
                    self.textView.selectedTextRange = self.textView.textRange(from: start, to: end)
                    cursorPosition = self.textView.offset(from: self.textView.beginningOfDocument, to: currentlySelectedRange.start)
                }
                return
            }
        }
    }
    
    // MARK: - View cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Reset cursor position to 0
        let newPosition = self.textView.beginningOfDocument
        self.textView.selectedTextRange = self.textView.textRange(from: newPosition, to: newPosition)
    }

}

