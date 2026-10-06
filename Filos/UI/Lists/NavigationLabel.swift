//
//  NavigationLabel.swift
//  PartyUI
//
//  Created by lunginspector on 3/3/26.
//

import SwiftUI

struct NavigationLabel: View {
    var text: String
    var symbol: String = ""
    var footer: String = ""
    var showChevron: Bool = false
    
    var body: some View {
        HStack(spacing: 10) {
            if !symbol.isEmpty {
                Image(systemName: symbol)
                    .frame(width: 22, height: 22, alignment: .center)
            }
            if footer.isEmpty {
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading) {
                    Text(text)
                    Text(footer)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            if showChevron {
                Chevron()
            }
        }
        .foregroundColor(Color(.label))
    }
}

struct Chevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.body.weight(.semibold))
            .foregroundColor(Color(.tertiaryLabel))
            .imageScale(.small)
    }
}
