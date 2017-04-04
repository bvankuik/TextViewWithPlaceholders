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

    // MARK: - Actions
    
    @IBAction func previousButtonTapped(_ sender: UIButton) {
        guard let text = self.textView.text else {
            return
        }

        let ranges = text.allRanges(of: self.placeholder)
        self.selectPlaceholder(in: ranges.reversed(), with: smallerThan)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let text = self.textView.text else {
            return
        }

        let ranges = text.allRanges(of: self.placeholder)
        self.selectPlaceholder(in: ranges, with: greaterThan)
    }
    
    // MARK: - Private functions
    
    private func smallerThan(operandA: Int, operandB: Int) -> Bool {
        return operandA < operandB
    }

    private func greaterThan(operandA: Int, operandB: Int) -> Bool {
        return operandA > operandB
    }

    private func selectPlaceholder(in ranges: [Range<String.Index>], with closure: (Int, Int) -> Bool) {
        guard let text = self.textView.text else {
            return
        }

        self.textView.becomeFirstResponder()

        // Find current cursor position
        guard let currentlySelectedRange = self.textView.selectedTextRange else {
            return
        }

        var cursorPosition = self.textView.offset(from: self.textView.beginningOfDocument, to: currentlySelectedRange.start)

        for range in ranges {
            let rangeStart = text.distance(from: text.startIndex, to: range.lowerBound)
            let rangeEnd = text.distance(from: text.startIndex, to: range.upperBound)

            if closure(rangeStart, cursorPosition) {
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

