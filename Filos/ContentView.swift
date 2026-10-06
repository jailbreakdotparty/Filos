//
//  ContentView.swift
//  Filos
//
//  Created by lunginspector on 7/12/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var mgr: FilosManager
    
    var body: some View {
        NavigationView {
            FileBrowserContainer(level: 0, url: URL(fileURLWithPath: "/"))
                .environmentObject(mgr)
        }
        .navigationViewStyle(.stack)
    }
}

struct FileBrowserContainer: View {
    @EnvironmentObject var mgr: FilosManager
    let level: Int
    let url: URL
    
    var body: some View {
        FileBrowserView(item: getFileItem(at: url))
            .environmentObject(mgr)
            .compatibleBackground {
                NavigationLink(
                    destination: destView,
                    isActive: Binding(get: {
                        mgr.navArray.count > level
                    }, set: { newValue in
                        if !newValue, mgr.navArray.count > level {
                            mgr.navArray.removeSubrange(level...)
                        }
                    })
                ) {
                    EmptyView()
                }
            }
    }
    
    private var destView: some View {
        Group {
            if mgr.navArray.count > level {
                FileBrowserContainer(level: level + 1, url: mgr.navArray[level].url)
            } else {
                VStack {
                    HStack {
                        ProgressView()
                        Text("Loading...")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
