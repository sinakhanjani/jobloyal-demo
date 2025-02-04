//
//  SwiftUIExtention.swift
//  JobLoyal
//
//  Created by Sina khanjani on 12/13/1399 AP.
//

import SwiftUI

// MARK: - Font Extension
extension Font {
    /// Custom font: 'Avenir Next' font
    static func avenirNext(size: CGFloat, relativeTo: TextStyle) -> Font {
        if #available(iOS 14.0, *) {
            return .custom("Avenir Next", size: size, relativeTo: relativeTo)
        } else {
            return .system(size: size, weight: .medium)
        }
    }
}

// MARK: - Color Extention
extension Color {
    /// Color Assets
    static let heavyBlue: Color = Color(.heavyBlue)
    static let heavyRed: Color = Color(.heavyRed)
    static let heavyGreen: Color = Color(.heavyGreen)
}

// MARK: - View Extention
extension View {
    /// Custom edges border
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
