//
//  HeaderLabel.swift
//  PartyUI
//
//  Created by lunginspector on 3/3/26.
//

import SwiftUI

struct HeaderLabel: View {
    var label: String
    var symbol: String
    
    init(_ label: String, symbol: String) {
        self.label = label
        self.symbol = symbol
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .frame(width: 18, alignment: .center)
            Text(label)
        }
    }
}
