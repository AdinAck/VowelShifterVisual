//
//  VowelShift.swift
//  VowelShifterVisual
//
//  Created by Adin Ackerman on 4/16/22.
//

import Foundation
import SwiftUI

class VowelShift: ObservableObject {
    @Published var text: [Char] = []
    @Published var speed: UInt64 = 500_000_000
    
    @Published var leftCursor: Int!
    @Published var rightCursor: Int!
    
    @Published var running: Bool = false
    @Published var swapping: Bool = false
    @Published var swapStage: Int = 0
    @Published var heldCharStage: Int = 0
    @Published var heldCharValue: Char = Char()
    
    var __leftCursor: Int!
    var __rightCursor: Int!
    
    let vowels: String = "aeiou"
    
    private func update(perform action: @escaping () -> Void) {
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                action()
            }
        }
    }
    
    func shift(in textArr: [String]) async {
        // initialize left cursor (find last vowel)
        __leftCursor = text.count - 1
        update {
            self.leftCursor = self.__leftCursor
            self.heldCharStage = 0
        }
        
        try? await Task.sleep(nanoseconds: speed)
        
        while !vowels.contains(text[__leftCursor].value.lowercased()) {
            if __leftCursor <= 0 {
                update {
                    self.running = false
                    self.leftCursor = nil
                    self.rightCursor = nil
                }
                return
            }
            __leftCursor -= 1
            
            update { self.leftCursor = self.__leftCursor }
            
            try? await Task.sleep(nanoseconds: speed)
        }
        
        // record last vowel position
        let lastVowelPos = __leftCursor
        
        // store last vowel for later
        let lastVowel = text[__leftCursor].value
        
        update {
            self.heldCharStage = 1
            self.heldCharValue.value = lastVowel
        }
        
        // iterate
        for (i, char) in textArr.enumerated() {
            // check for stop event
            guard running else {
                update {
                    self.leftCursor = nil
                    self.rightCursor = nil
                }
                
                return
            }
            
            __rightCursor = i
            
            update { self.rightCursor = self.__rightCursor }
            
            // place saved vowel and end
            if __rightCursor == lastVowelPos {
                try? await Task.sleep(nanoseconds: speed)
                
                update { self.heldCharStage = 2 }
                
                try? await Task.sleep(nanoseconds: speed)
                
                update {
                    self.text[self.__leftCursor] = Char(id: self.__leftCursor, value: lastVowel, swapped: true)
                    
                    self.heldCharStage = 3
                    
                    self.leftCursor = nil
                    self.rightCursor = nil
                }
                
                break
            }
            
            // swap
            if vowels.contains(char.lowercased()) {
                let moved: (Int, Char) = (__leftCursor, Char(id: __leftCursor, value: char, swapped: true))
                
                // stage one
                update { self.swapStage = 0 }
                
                try? await Task.sleep(nanoseconds: speed)
                
                update {
                    self.swapping = true
                    self.swapStage = 1
                }
                
                try? await Task.sleep(nanoseconds: speed)
                
                // stage two (do swap)
                update { self.swapStage = 2 }
                
                try? await Task.sleep(nanoseconds: speed)
                
                __leftCursor = __rightCursor
                
                update {
                    self.swapping = false
                    self.swapStage = 3
                }
                
                try? await Task.sleep(nanoseconds: speed)
                
                update {
                    self.text[moved.0] = moved.1
                    self.leftCursor = self.__rightCursor
                    self.swapStage = 4
                }
            }
            
            try? await Task.sleep(nanoseconds: speed)
        }
        
        update { self.running = false }
    }
}
