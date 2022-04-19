//
//  MainView.swift
//  VowelShifterVisual
//
//  Created by Adin Ackerman on 4/18/22.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var keyView: KeyView
    @EnvironmentObject var shifter: VowelShift
    
    @State var speedProxy: Float = 1
    
    private func getCharPos(id: Int, center: CGPoint) -> CGFloat {
        return center.x - CGFloat((shifter.text.count/2 - id) * 30)
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height)
                
                ZStack {
                    ForEach(shifter.text, id: \.id) { char in
                        let pos = getCharPos(id: char.id, center: center)
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(char.swapped ? .orange : Color(hue: 0, saturation: 0, brightness: 0.3))
                        .frame(width: 25, height: 35, alignment: .center)
                        .opacity(char.value == " "  || shifter.leftCursor == char.id || shifter.rightCursor == char.id ? 0 : 1)
                        .position(x: pos, y: center.y)
                        .transition(.move(edge: .trailing))
                    }
                    
                    if shifter.rightCursor != nil {
                        let pos = getCharPos(id: shifter.text[shifter.rightCursor].id, center: center)

                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.blue)
                        .blendMode(.lighten)
                        .frame(width: 25, height: 35, alignment: .center)
                        .position(x: pos, y: shifter.swapping ? center.y - 40 : center.y)
                    }
                    
                    if shifter.leftCursor != nil {
                        let pos = getCharPos(id: shifter.text[shifter.leftCursor].id, center: center)

                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.green)
                        .blendMode(.lighten)
                        .frame(width: 25, height: 35, alignment: .center)
                        .position(x: pos, y: shifter.swapping ? center.y - 40 : center.y)
                    }
                    
                    ForEach(shifter.text, id: \.id) { char in
                        let pos = getCharPos(id: char.id, center: center)
                        Text(char.value)
                        .font(.title)
                        .position(x: pos, y: center.y)
                        .opacity(shifter.leftCursor == char.id && shifter.swapStage == 3 ? 0 : 1)
                        .transition(.move(edge: .trailing))
                    }
                    
                    if shifter.rightCursor != nil {
                        let pos1 = getCharPos(id: shifter.text[shifter.rightCursor].id, center: center)
                        let pos2 = getCharPos(id: shifter.text[shifter.leftCursor].id, center: center)
                        
                        Text(shifter.text[shifter.rightCursor].value)
                        .font(.title)
                        .position(x: shifter.swapStage <= 1 ? pos1 : pos2, y: shifter.swapping ? center.y - 40 : center.y)
                        .opacity(0 < shifter.swapStage && shifter.swapStage < 4 ? 1 : 0)
                    }
                }
            }
            .onChange(of: keyView.count) { _ in
                if !shifter.running {
                    withAnimation(.spring()) {
                        if keyView.key.value == "\\delete" {
                            let _ = shifter.text.popLast()
                            return
                        }
                        
                        shifter.text.append(keyView.key)
                    }
                }
            }
            
            HStack {
                Button {
                    if shifter.running {
                        shifter.running = false
                    } else {
                        for i in 0..<shifter.text.count {
                            withAnimation(.spring()) {
                                shifter.text[i].swapped = false
                            }
                        }
                        
                        shifter.running = true
                        
                        Task {
                            print(await shifter.shift(in: shifter.text.map { $0.value }))
                        }
                    }
                } label: {
                    if shifter.running {
                        Image(systemName: "stop.circle.fill")
                        .renderingMode(.original)
                        .foregroundColor(.blue)
                        .font(.system(size: 40))
                        .padding()
                    } else {
                        Image(systemName: "play.circle.fill")
                        .renderingMode(.original)
                        .foregroundColor(.blue)
                        .font(.system(size: 40))
                        .padding()
                    }
                    
                }
                .buttonStyle(.borderless)
                
                Slider(value: $speedProxy, in: 0.5...4)
                    .frame(idealWidth: 100, maxWidth: 200)
                .padding()
                .onChange(of: speedProxy) { newValue in
                    shifter.speed = UInt64(500_000_000 / speedProxy)
                }
            }
        }
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
