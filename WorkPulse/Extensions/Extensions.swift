//
//  Extensions.swift
//  WorkPulse
//
//  Created by Andreas Maerki on 04.05.2025.
//

import Foundation


extension TimeInterval {
  func formattedHHMMSS() -> String {
    let hours = Int(self) / 3600
    let minutes = Int(self) / 60 % 60
    let seconds = Int(self) % 60
    
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
  }
}
