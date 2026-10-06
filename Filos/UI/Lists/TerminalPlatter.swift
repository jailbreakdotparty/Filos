//
//  TerminalPlatter.swift
//  PartyUI
//
//  Created by lunginspector on 3/3/26.
//

import SwiftUI

var terminalRad: CGFloat {
    if #available(iOS 26.0, *) { return 22 } else { return 14 }
}

struct TerminalPlatter: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 250)
            .padding(.horizontal)
            .compatibleBackground(Color(.quaternarySystemFill), in: .rect(cornerRadius: terminalRad))
    }
}
