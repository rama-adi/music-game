//
//  TimeInterval+FormatDuration.swift
//  MusicGame
//
//  Created by Rama Adi Nugraha on 13/05/24.
//

import Foundation

extension TimeInterval {
    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        let formattedDuration = formatter.string(from: self) ?? ""
        
        return formattedDuration
    }
}
