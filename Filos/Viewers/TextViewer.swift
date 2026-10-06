//
//  TextViewer.swift
//  Filos
//
//  Created by lunginspector on 5/20/26.
//

import SwiftUI


struct TextViewer: View {
    @EnvironmentObject var mgr: FilosManager
    var onClose: () -> Void
    
    @AppStorage("textViewerSize") var textViewerSize = 11
    @AppStorage("useMonospaced") var useMonospaced = true
    
    var fileURL: URL
    
    @State private var file = clearFileItem
    @State private var fileText = ""
    @State private var editText = ""
    @State private var isEditing = false
    
    init(_ fileURL: URL, onClose: @escaping () -> Void) {
        self.fileURL = fileURL
        self.onClose = onClose
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Group {
                    if isEditing {
                        TextEditor(text: $editText)
                            .font(.system(size: CGFloat(textViewerSize), design: useMonospaced ? .monospaced : .default))
                    } else {
                        SelectableTextView(text: fileText, size: CGFloat(textViewerSize), monospaced: useMonospaced)
                    }
                }

                if !file.writable {
                    ReadOnlyIndicator()
                }
            }
            .navigationTitle(fileURL.deletingPathExtension().lastPathComponent)
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if isEditing {
                        Button {
                            isEditing = false
                            editText = fileText
                        } label: {
                            Text("Cancel")
                        }
                    }
                    
                    Menu {
                        if file.writable && !isEditing {
                            Button {
                                isEditing = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                        
                        Button {
                            Haptic.shared.play(.soft)
                            UIPasteboard.general.string = fileText
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        
                        Button {
                            if let url = makeTemp(fileURL) {
                                presentShareSheet(with: url)
                            }
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Label("Menu", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button {
                            let res = writeTextIntoFile(fileURL, string: editText)
                            if res {
                                isEditing = false
                                fileText = getFileText(fileURL)
                            }
                        } label: {
                            Text("Save")
                        }
                    } else {
                        Button {
                            onClose()
                            mgr.refreshFiles.toggle()
                        } label: {
                            Text("Close")
                        }
                    }
                }
            }
            .onAppear {
                file = getFileItem(at: fileURL)
                let text = getFileText(fileURL)
                fileText = text
                editText = text
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func writeTextIntoFile(_ url: URL, string: String) -> Bool {
        do {
            let data = Data(string.utf8)
            try data.write(to: url)
            return true
        } catch {
            print("[!] failed to write data: \(error)")
        }
        return false
    }
}
