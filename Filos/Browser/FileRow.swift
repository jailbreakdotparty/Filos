//
//  FileRow.swift
//  AccessiblePlus
//
//  Created by lunginspector on 5/20/26.
//

import SwiftUI

import QuickLook
import ZIPFoundation

struct FBPreviewer: Identifiable, Equatable {
    let id = UUID()
    var type: FBPreviewTypes
    var file: FileItem
}

enum FBPreviewTypes: Equatable {
    case info, plist, text, quickLook
}

struct FileRow: View {
    @EnvironmentObject var mgr: FilosManager
    @AppStorage("hideDates") var hideDates = false
    var item: FileItem
    var parent: FileItem
    @Binding var previewer: FBPreviewer?
    
    @State private var conformsText = false
    @State private var conformsPlist = false
    @State private var conformsZip = false
    
    var body: some View {
        Button {
            fileTapAction()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: item.type == .file ? "doc" : "arrow.up.right.circle")
                    .foregroundColor(item.hidden ? .secondary : .primary)
                    .frame(width: 20, alignment: .center)
                
                VStack(alignment: .leading) {
                    Text(item.name)
                        .foregroundColor(item.hidden ? .secondary : .primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    if !hideDates && !item.modifiedDateStr.isEmpty && item.type == .file {
                        Text(item.modifiedDateStr)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                
                if item.type == .file {
                    Text("\(ByteCountFormatter.string(fromByteCount: Int64(item.size), countStyle: .file))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Button {
                    previewer = FBPreviewer(type: .info, file: item)
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
                .foregroundColor(Color.accentColor)
                .opacity(item.hidden ? 0.8 : 1.0)
                
                if item.type == .symlink {
                    Chevron()
                }
            }
        }
        .padding(.vertical, !hideDates && !item.modifiedDateStr.isEmpty && item.type == .file ? 1 : 0)
        .foregroundColor(Color(.label))
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                conformsText = conformsToTextViewer(item.fileURL)
                conformsPlist = conformsToPlistViewer(item.fileURL)
                if item.uttype.conforms(to: .zip) {
                    conformsZip = true
                }
            }
        }
        // MARK: cell actions
        .contextMenu {
            if parent.readable {
                if conformsText || conformsPlist {
                    Menu {
                        Button {
                            previewer = FBPreviewer(type: .quickLook, file: item)
                        } label: {
                            Label("Quick Look", systemImage: "eye")
                        }
                        
                        if conformsPlist {
                            Button {
                                previewer = FBPreviewer(type: .plist, file: item)
                            } label: {
                                Label("Plist Viewer", systemImage: "tablecells")
                            }
                        }
                        
                        if conformsText {
                            Button {
                                previewer = FBPreviewer(type: .text, file: item)
                            } label: {
                                Label("Text Viewer", systemImage: "doc.plaintext")
                            }
                        }
                    } label: {
                        Label("View In...", systemImage: "doc.text.magnifyingglass")
                    }
                } else {
                    Button {
                        previewer = FBPreviewer(type: .quickLook, file: item)
                    } label: {
                        Label("Quick Look", systemImage: "eye")
                    }
                }
            }
            
            Button {
                previewer = FBPreviewer(type: .info, file: item)
            } label: {
                Label("Get Info", systemImage: "info.circle")
            }
            
            Divider()
            
            if item.type == .file && parent.writable && item.readable {
                Button {
                    Alertinator.shared.prompt(title: "What would you like to call this file?", text: item.name, completion: { result in
                        if let name = result {
                            let res = renameFile(item.fileURL, to: name)
                            if res {
                                mgr.refreshFiles.toggle()
                            } else {
                                Alertinator.shared.alert(title: "Failed to rename file!", body: Errors.checkLogs)
                            }
                        }
                    })
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
            }
            
            if item.type == .file && parent.writable && item.readable {
                if conformsZip {
                    Button {
                        if !fm.fileExists(atPath: item.fileURL.deletingPathExtension().path) {
                            let res = unzipFile(item.fileURL)
                            if res {
                                mgr.refreshFiles.toggle()
                            }
                        } else {
                            Alertinator.shared.alert(title: "Failed to uncompress file!", body: "An item with the same name already exists here.")
                        }
                    } label: {
                        Label("Uncompress", systemImage: "archivebox")
                    }
                } else {
                    Button {
                        if !fm.fileExists(atPath: item.fileURL.appendingPathExtension("zip").path) {
                            let res = zipFile(item.fileURL)
                            if res {
                                mgr.refreshFiles.toggle()
                            }
                        } else {
                            Alertinator.shared.alert(title: "Failed to comrpess file!", body: "An archive with the same name already exists here.")
                        }
                    } label: {
                        Label("Compress", systemImage: "archivebox")
                    }
                }
            }
            
            if item.type == .file && parent.writable {
                Button {
                    let res = duplicateFile(item.fileURL)
                    if res {
                        mgr.refreshFiles.toggle()
                    } else {
                        Alertinator.shared.alert(title: "Failed to duplicate file!", body: Errors.checkLogs)
                    }
                } label: {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
            }
            
            Divider()
            
            Button {
                let res = copyFileToClipboard(item.fileURL)
                if !res {
                    Alertinator.shared.alert(title: "Failed to copy file!", body: Errors.checkLogs)
                }
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            
            if item.readable {
                Button {
                    Alertinator.shared.prompt(title: "Where would you like to move this file to?") { res in
                        if let path = res {
                            do {
                                let targetURL = URL(fileURLWithPath: path).appendingPathComponent(item.fileURL.lastPathComponent)
                                try fm.copyItem(at: item.fileURL, to: targetURL)
                                Alertinator.shared.alert(title: "Successfully moved file!", body: "Would you like to delete the original file?", actionLabel: "Yes", action: {
                                    try? fm.removeItem(at: item.fileURL)
                                    mgr.refreshFiles.toggle()
                                })
                            } catch {
                                print("[!] failed to copy file: \(error.localizedDescription)")
                                Haptic.shared.play(.heavy)
                            }
                        }
                    }
                } label: {
                    Label("Move", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
            
            Button {
                if let url = makeTemp(item.fileURL) {
                    presentShareSheet(with: url)
                }
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            if item.writable {
                Button {
                    do {
                        try fm.removeItem(at: item.fileURL)
                        mgr.refreshFiles.toggle()
                    } catch {
                        print("[!] failed to delete file: \(error)")
                        Alertinator.shared.alert(title: "Failed to delete file!", body: Errors.checkLogs)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .foregroundColor(.red)
            }
        }
    }
    
    // MARK: functions
    private func fileTapAction() {
        if item.type == .symlink {
            mgr.push(item.destURL)
        } else {
            if conformsZip {
                if !fm.fileExists(atPath: item.fileURL.deletingPathExtension().path) {
                    let res = unzipFile(item.fileURL)
                    if res {
                        mgr.refreshFiles.toggle()
                    }
                } else {
                    Alertinator.shared.alert(title: "Failed to uncompress file!", body: "An item with the same name already exists here.")
                }
            } else {
                if conformsPlist {
                    previewer = FBPreviewer(type: .plist, file: item)
                } else if conformsText {
                    previewer = FBPreviewer(type: .text, file: item)
                } else {
                    previewer = FBPreviewer(type: .quickLook, file: item)
                }
            }
        }
    }
}
