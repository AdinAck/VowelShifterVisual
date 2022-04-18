//
//  CharacterView.swift
//  VowelShifterVisual
//
//  Created by Adin Ackerman on 4/16/22.
//

import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var shifter: VowelShift
    
    var char: Char
    var id: Int?
    let color: Color?
    
    init(of char: Char) {
        self.char = char
        id = nil
        color = nil
    }
    
    init(of char: Char, focusOn id: Int, withColor color: Color) {
        self.char = char
        self.id = id
        self.color = color
    }
    
    var body: some View {
        Text(char.value)
        .font(.title)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
            .foregroundColor(char.id == id ? color : Color(hue: 0, saturation: 0, brightness: 0.3))
            .opacity(char.value == " "  && id == nil ? 0 : 1)
        )
        .opacity(char.id == id || id == nil ? 1 : 0)
    }
}

//struct CharacterView_Previews: PreviewProvider {
//    static var previews: some View {
//        CharacterView(character: "A")
//    }
//}
