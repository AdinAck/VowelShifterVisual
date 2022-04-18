//
//  VowelShift.swift
//  VowelShifterVisual
//
//  Created by Adin Ackerman on 4/16/22.
//

import Foundation
import SwiftUI

class VowelShift: ObservableObject {
    @Published var leftCursor: Int!
    @Published var rightCursor: Int!
    
    private let vowels: String = "aeiou"
    
    func shift(in textArr: [String]) async -> [String] {
        // copy input
        var result = textArr
        
        // initialize left cursor (find last vowel)
        leftCursor = result.count - 1
        
        while !vowels.contains(result[leftCursor].lowercased()) || leftCursor < 0 {
            leftCursor -= 1
        }
        
        // record last vowel position
        let lastVowelPos = leftCursor
        
        // store last vowel for later
        let lastVowel = result[leftCursor]
        
        // iterate
        for (i, char) in textArr.enumerated() {
            DispatchQueue.main.async {
                withAnimation {
                    self.rightCursor = i // so it's published
                    print(i)
                }
            }
            
            if rightCursor == lastVowelPos {
                result[leftCursor] = lastVowel
                return result
            }
            
            if vowels.contains(char.lowercased()) {
                result[leftCursor] = char
                DispatchQueue.main.async {
                    withAnimation {
                        self.leftCursor = self.rightCursor
                    }
                }
            }
            
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        
        return result
    }
}
