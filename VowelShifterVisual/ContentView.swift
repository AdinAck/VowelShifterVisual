//
//  ContentView.swift
//  VowelShifterVisual
//
//  Created by Adin Ackerman on 4/16/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var shifter = VowelShift()
    @StateObject var keyView = KeyView()
    
    var body: some View {
        ZStack(alignment: .center) {
            // capture key events
            KeyEventHandling()
            .environmentObject(keyView)
            
            MainView()
            .environmentObject(keyView)
            .environmentObject(shifter)
        }
    }
}

class KeyView: NSView, ObservableObject {
    @Published var key: Char = Char()
    var count: Int = 0
    
    override var acceptsFirstResponder: Bool { true }
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 51 {
            key = Char(value: "\\delete")
            
            if count > 0 { count -= 1}
            
        } else if let _key = event.charactersIgnoringModifiers {
            if _key[_key.startIndex].isASCII {
                key = Char(id: count, value: _key)
                count += 1
            }
        }
    }
}

struct KeyEventHandling: NSViewRepresentable {
    @EnvironmentObject var view: KeyView
    
    func makeNSView(context: Context) -> NSView {
        DispatchQueue.main.async { // wait till next event cycle
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
    }
}

struct Char: Identifiable, Hashable {
    var id: Int
    var value: String
    var swapped: Bool
    
    init() { // null char
        id = -1
        value = ""
        swapped = false
    }
    
    init(value: String) { // delete char
        id = -1
        self.value = value
        swapped = false
    }
    
    init(id: Int, value: String) { // normal char
        self.id = id
        self.value = value
        swapped = false
    }
    
    init(id: Int, value: String, swapped: Bool) { // normal char
        self.id = id
        self.value = value
        self.swapped = swapped
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
