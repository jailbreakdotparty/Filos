//
//  LinkCreditCell.swift
//  PartyUI
//
//  Created by lunginspector on 3/3/26.
//

import SwiftUI

var creditCell: CGFloat {
    if #available(iOS 26.0, *) { return 14 } else { return 16 }
}

struct LinkCreditCell: View {
    var image: Image? = nil
    var name: String
    var description: String
    var url: String
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button {
            if !url.isEmpty { openURL(URL(string: url)!) }
        } label: {
            HStack(spacing: creditCell) {
                if let image = image {
                    LinkCreditIcon(image: image)
                }
                VStack(alignment: .leading) {
                    Text(name)
                        .fontWeight(.semibold)
                    Text(description)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if !url.isEmpty {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .compatibleForegroundColor(Color(.tertiaryLabel))
                        .imageScale(.small)
                }
            }
        }
        .compatibleForegroundColor(Color(.label))
    }
}

// icon for credits cell
struct LinkCreditIcon: View {
    var image: Image
    
    var body: some View {
        if #available(iOS 26.0, *) {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .background(Color(.systemGray6))
                .clipShape(.capsule)
                .compatibleGlassEffect(in: .capsule)
        } else {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .background(Color(.systemGray6))
                .clipShape(.rect(cornerRadius: 12))
                .compatibleOverlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                }
        }
    }
}
