//
//  DashboardView.swift
//  WorkPulse
//
//  Created by Andreas Maerki on 04.05.2025.
//

import SwiftUI

struct DashboardView: View {
  @Environment(GlobalEnvironment.self) private var viewModel

  var body: some View {
    VStack {
      HStack {
        Text("Dashboard")
          .font(.largeTitle)
        Spacer()
      }
      VStack {
        HStack {
          Text(viewModel.elapsedTime.formattedHHMMSS())
            .font(.title) +
          Text(" Logged today")

          Spacer()
        }
      }
      .padding()
      .background(Color.gray.opacity(0.1))
      .cornerRadius(8)

      Spacer()
    }
    .padding()
  }
}

#Preview {
  DashboardView()
    .environment(GlobalEnvironment())
}
