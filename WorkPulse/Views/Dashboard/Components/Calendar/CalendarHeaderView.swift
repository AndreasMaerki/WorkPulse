import SwiftUI

struct CalendarHeaderView: View {
  let monthYear: String
  let onPrev: () -> Void
  let onNext: () -> Void

  var body: some View {
    HStack {
      Button(action: onPrev) {
        Image(systemName: "chevron.left")
          .foregroundStyle(.secondary)
      }
      .buttonStyle(.plain)
      Spacer()
      Text(monthYear)
        .font(.title2.bold())
      Spacer()
      Button(action: onNext) {
        Image(systemName: "chevron.right")
          .foregroundStyle(.secondary)
      }
      .buttonStyle(.plain)
    }
    .padding(.horizontal)
    .padding(.top, 20)
  }
}
