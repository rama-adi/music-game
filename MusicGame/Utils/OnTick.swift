//
//  OnTick.swift
//  MusicGame
//
//  Created by Rama Adi Nugraha on 13/05/24.
//

import Foundation
import SwiftUI

struct OnTickModifier: ViewModifier {
    let action: () -> Void
    @StateObject private var displayLinkManager = DisplayLinkManager()

    func body(content: Content) -> some View {
        content
            .onAppear {
                displayLinkManager.onUpdate = action
                displayLinkManager.start()
            }
            .onDisappear {
                displayLinkManager.stop()
            }
    }
}

extension View {
    func onTick(perform action: @escaping () -> Void) -> some View {
        self.modifier(OnTickModifier(action: action))
    }
}
