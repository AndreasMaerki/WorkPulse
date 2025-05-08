import SwiftUI

struct CalendarWeekdayRow: View {
  let weekDates: [Date]
  let selectedDate: Date
  let calendar: Calendar
  let onSelect: (Date) -> Void

  var body: some View {
    HStack(spacing: 8) {
      ForEach(weekDates, id: \.self) { date in
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        VStack(spacing: 4) {
          Text(date.formatted(.dateTime.weekday(.short)))
            .font(.caption)
            .foregroundStyle(.secondary)
          Text("\(calendar.component(.day, from: date))")
            .font(.headline)
            .frame(width: 32, height: 32)
            .background(isSelected ? Color.accentColor.opacity(0.8) : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Circle())
        }
        .onTapGesture {
          onSelect(date)
        }
      }
    }
    .padding(.horizontal)
    .padding(.vertical, 12)
  }
}
