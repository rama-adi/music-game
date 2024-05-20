//
//  DisplayLinkManager.swift
//  MusicGame
//
//  Created by Rama Adi Nugraha on 07/05/24.
//

import Foundation
import UIKit

class DisplayLinkManager: ObservableObject {
    private var displayLink: CADisplayLink?
    var onUpdate: (() -> Void)?
    
    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func update() {
        onUpdate?()
    }
}
