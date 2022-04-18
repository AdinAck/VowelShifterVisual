//
//  ContentView.swift
//  VowelShifterVisual
//
//  Created by Adin Ackerman on 4/16/22.
//

import SwiftUI

struct ContentView: View {
    @State var rawText: String = ""
    @State var chars: [Char] = []
    @StateObject var shifter = VowelShift()
    
    var body: some View {
        ZStack {
            TextEditor(text: $rawText)
            .opacity(0)
            .onChange(of: rawText) { newValue in
                withAnimation {
                    chars = rawText.enumerated().map { (i, char) in Char(id: i, value: String(char)) }
                }
            }
            
            VStack {
                ZStack {
                    HStack {
                        ForEach(chars, id: \.id) { char in
                            CharacterView(of: char)
                            .environmentObject(shifter)
                            .transition(.scale)
                        }
                    }
                    .padding()
                    
                    if let cursor = shifter.leftCursor {
                        HStack {
                            ForEach(chars, id: \.id) { char in
                                CharacterView(of: char, focusOn: cursor, withColor: .green)
                                .environmentObject(shifter)
                            }
                        }
                        .padding()
                    }
                    
                    if let cursor = shifter.rightCursor {
                        HStack {
                            ForEach(chars, id: \.id) { char in
                                CharacterView(of: char, focusOn: cursor, withColor: .blue)
                                .environmentObject(shifter)
                            }
                        }
                        .padding()
                    }
                }
                
                Button {
                    Task {
                        await shifter.shift(in: chars.map { $0.value })
                    }
                } label: {
                    Image(systemName: "play.circle.fill")
                    .renderingMode(.original)
                    .foregroundColor(.blue)
                    .font(.system(size: 40))
                    .padding()
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

struct Char: Identifiable, Hashable {
    var id: Int
    var value: String
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
