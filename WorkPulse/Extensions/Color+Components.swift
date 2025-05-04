//
//  Color+Components.swift
//  WorkPulse
//
//  Created by Andreas Maerki on 04.05.2025.
//

import SwiftUICore
import AppKit

extension Color {
  var components: (red: Double, green: Double, blue: Double, opacity: Double)? {
    let nsColor = NSColor(self)
    // Convert to sRGB color space
    guard let sRGBColor = nsColor.usingColorSpace(.sRGB) else {
      return nil
    }

    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var opacity: CGFloat = 0

    sRGBColor.getRed(&red, green: &green, blue: &blue, alpha: &opacity)

    return (Double(red), Double(green), Double(blue), Double(opacity))
  }
}
