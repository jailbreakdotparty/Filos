//
//  ViewExtensions.swift
//  Filos
//
//  Created by lunginspector on 9/26/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func customListStyle(_ selection: Int) -> some View {
        switch selection {
        case 2: self.listStyle(.inset)
        case 3: self.listStyle(.grouped)
        default: self.listStyle(.insetGrouped)
        }
    }
    
    @ViewBuilder
    func adaptiveListMargin() -> some View {
        if #available(iOS 26.0, *) {
            self.contentMargins(.top, 0)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func noRefreshable() -> some View {
        self.environment(\EnvironmentValues.refresh as! WritableKeyPath<EnvironmentValues, RefreshAction?>, nil)
    }
}

extension ButtonRole {
    static var adaptiveConfirm: ButtonRole? {
        if #available(iOS 19.0, *) {
            return .confirm
        }
        return nil
    }
}
