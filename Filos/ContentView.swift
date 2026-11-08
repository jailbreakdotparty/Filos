//
//  ContentView.swift
//  Filos
//
//  Created by lunginspector on 7/12/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var mgr: FilosManager
    @AppStorage("startDir") var startDir = "/"
    
    var body: some View {
        NavigationStack(path: $mgr.fmNavPath) {
            FileBrowserView(item: getFileItem(at: URL(fileURLWithPath: startDir)))
                .navigationDestination(for: URL.self) { url in
                    FileBrowserView(item: getFileItem(at: url))
                }
        }
    }
}

#Preview {
    ContentView()
}
