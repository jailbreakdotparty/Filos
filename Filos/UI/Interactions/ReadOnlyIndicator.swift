import SwiftUI

struct ReadOnlyIndicator: View {
    var body: some View {
        HStack {
            Spacer()
            Button {
                Alertinator.shared.alert(title: "View-Only File", body: "You can only read this file.")
            } label: {
                Image(systemName: "lock")
                    .padding(10)
            }
            .foregroundColor(.accentColor)
            .padding(.trailing)
            .ignoresSafeArea()
        }
    }
}
