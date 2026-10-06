//
//  LogView.swift
//  dirtyZero
//
//  Created by lunginspector on 4/17/26.
//

import SwiftUI


struct LogView: View {
    @EnvironmentObject var mgr: FilosManager
    var onClose: () -> Void
    
    var body: some View {
        NavigationView {
            SelectableTextView(text: mgr.logOutput, size: 11, followOutput: true)
            .navigationTitle("Logs")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            UIPasteboard.general.string = mgr.logOutput
                        } label: {
                            Label("Copy Output", systemImage: "doc.on.doc")
                        }
                        
                        Button {
                            do {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "MM-dd-yyyy-HHmmss"
                                let date = formatter.string(from: Date())
                                
                                let tempURL = fm.temporaryDirectory.appendingPathComponent("Filos-Log-\(date)").appendingPathExtension("txt")
                                guard let data = mgr.logOutput.data(using: .utf8) else {
                                    throw "failed to create data from log string"
                                }
                                
                                try data.write(to: tempURL)
                                presentShareSheet(with: tempURL)
                            } catch {
                                print("[*] failed to export logs: \(error)")
                            }
                        } label: {
                            Label("Export Logs", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Label("Menu", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onClose()
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
