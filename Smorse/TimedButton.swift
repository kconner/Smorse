//
//  TimedButton.swift
//  Smorse
//
//  Created by Kevin Conner on 2023-04-23.
//

import SwiftUI

struct TimedButton<T>: View where T: View {
    
    struct Touches {
        var up: Date?
        var down: Date?
    }
    
    @State private var touches = Touches()

    var action: (TimeInterval?, TimeInterval) -> Void
    var label: (Bool) -> T
    
    var body: some View {
        label(touches.down != nil)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if touches.down == nil {
                            touches.down = Date()
                        }
                    }
                    .onEnded { value in
                        if let down = touches.down {
                            let now = Date()
                            
                            let upDuration = touches.up.map { priorUp in
                                down.timeIntervalSince(priorUp)
                            }
                            
                            action(upDuration, now.timeIntervalSince(down))
                            
                            touches = .init(up: now, down: nil)
                        }
                    }
            )
    }
    
}

struct TimedButton_Previews: PreviewProvider {
    static var previews: some View {
        PreviewState((nil as TimeInterval?, nil as TimeInterval?)) { $times in
            VStack {
                TimedButton { upDuration, downDuration in
                    $times.wrappedValue = (upDuration, downDuration)
                } label: { isTouching in
                    Text(isTouching ? "BOOP" : "boop")
                }
                .font(.title.bold())
                
                if let upDuration = $times.wrappedValue.0 {
                    Text("up: \(upDuration)")
                }
                
                if let downDuration = $times.wrappedValue.1 {
                    Text("down: \(downDuration)")
                }
            }
        }
    }
}
