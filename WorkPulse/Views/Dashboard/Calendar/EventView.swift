//
//  EventView.swift
//  CalendarTest
//
//  Created by Andreas Maerki on 10.05.2025.
//
import SwiftUI

struct EventView: View {
  let event: CalendarEvent
  @State private var isHovering = false

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: 4)
          .fill(event.color.opacity(isHovering ? 0.8 : 0.6))

        if geometry.size.height >= 40 {
          VStack(alignment: .leading, spacing: 2) {
            Text(event.title)
              .font(.footnote)
              .lineLimit(1)
              .foregroundColor(.white)

            if geometry.size.height >= 55 {
              HStack {
                Text(timeString(from: event.startTime))
                Text("-")
                Text(timeString(from: event.endTime))
              }
              .font(.footnote)
              .foregroundColor(.white.opacity(0.9))
            }
          }
          .padding(4)
          .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .topLeading)
        }
      }
      .onHover { hovering in
        isHovering = hovering
      }
      .help("\(event.title)\n\(timeString(from: event.startTime)) - \(timeString(from: event.endTime))")
    }
  }

  private func timeString(from date: Date) -> String {
    date.hourMinuteString
  }
}
