//
//  EventView.swift
//  CalendarTest
//
//  Created by Andreas Maerki on 10.05.2025.
//
import SwiftUI

struct EventView: View {
  let event: CalendarEvent

  var body: some View {
    ZStack(alignment: .topLeading) {
      RoundedRectangle(cornerRadius: 4)
        .fill(event.color.opacity(0.6))

      VStack(alignment: .leading) {
        Text(event.title)
          .font(.headline)
          .foregroundColor(.white)

        HStack {
          Text(timeString(from: event.startTime))
          Text("-")
          Text(timeString(from: event.endTime))
        }
        .font(.caption)
        .foregroundColor(.white)
      }
      .padding(8)
    }
  }

  private func timeString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  }
}
