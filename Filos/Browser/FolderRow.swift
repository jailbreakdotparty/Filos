//
//  FolderRow.swift
//  AccessiblePlus
//
//  Created by lunginspector on 5/20/26.
//

import SwiftUI

import QuickLook
import ZIPFoundation

struct FolderRow: View {
    @EnvironmentObject var mgr: FilosManager
    var item: FileItem
    var parent: FileItem
    @Binding var previewer: FBPreviewer?
    
    @State private var folderType: FolderType = .normal
    
    var body: some View {
        Button {
            mgr.push(item.destURL)
        } label: {
            HStack(spacing: fileRowSpacing) {
                Group {
                    if fm.fileExists(atPath: item.fileURL.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist").path) || fm.fileExists(atPath: item.fileURL.appendingPathComponent("Info.plist").path) {
                        Image(systemName: "app")
                            .frame(width: 20, alignment: .center)
                        VStack(alignment: .leading) {
                            Text(getNameFromInfP(item.fileURL) ?? getBIDFromMCM(item.fileURL) ?? item.name)
                                .compatibleForegroundColor(item.hidden ? .secondary : .primary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Text(item.fileURL.lastPathComponent)
                                .font(.footnote)
                                .compatibleForegroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    } else {
                        Image(systemName: "folder")
                            .frame(width: 20, alignment: .center)
                            .compatibleForegroundColor(item.hidden ? .secondary : .primary)
                        Text(item.name)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .compatibleForegroundColor(item.hidden ? .secondary : .primary)
                    }
                }
                
                Spacer()
                
                Button {
                    previewer = FBPreviewer(type: .info, file: item)
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
                .compatibleForegroundColor(Color.accentColor)
                .opacity(item.hidden ? 0.8 : 1.0)
                
                Chevron()
            }
        }
        .compatibleForegroundColor(Color(.label))
        .contextMenu {
            if item.readable {
                Button {
                    previewer = FBPreviewer(type: .quickLook, file: item)
                } label: {
                    Label("Quick Look", systemImage: "eye")
                }
            }
            
            Button {
                previewer = FBPreviewer(type: .info, file: item)
            } label: {
                Label("Get Info", systemImage: "info.circle")
            }
            
            Divider()
            
            if parent.writable && item.readable {
                Button {
                    Alertinator.shared.prompt(title: "What would you like to rename this folder to?", text: item.fileURL.lastPathComponent) { res in
                        if let newName = res {
                            do {
                                let newFolderURL = item.fileURL.deletingLastPathComponent().appendingPathComponent(newName)
                                if fm.fileExists(atPath: newFolderURL.path) {
                                    throw "A folder with the same name already exists here."
                                }
                                try fm.createDirectory(at: newFolderURL, withIntermediateDirectories: true)
                                let folderURLs = try fm.contentsOfDirectory(at: item.fileURL, includingPropertiesForKeys: [])
                                for url in folderURLs {
                                    try fm.moveItem(at: url, to: newFolderURL.appendingPathComponent(url.lastPathComponent))
                                }
                                try fm.removeItem(at: item.fileURL)
                                mgr.refreshFiles.toggle()
                            } catch {
                                print("[!] failed to rename folder: \(error)")
                                Alertinator.shared.alert(title: "Failed to rename folder!", body: (error as? String) ?? "Choose a different name, then try again.")
                            }
                        }
                    }
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
                
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
            
            Divider()
            if mgr.isFavorited(item) {
                Button {
                    mgr.removeFavorite(item)
                } label: {
                    Label("Unfavorite", systemImage: "star.slash")
                }
            } else {
                Button {
                    mgr.addFavorite(item)
                } label: {
                    Label("Favorite", systemImage: "star")
                }
            }
            
            Button {
                Alertinator.shared.prompt(title: "Where would you like to move this folder to?") { res in
                    if let path = res {
                        do {
                            let newFolderURL = URL(fileURLWithPath: path).appendingPathComponent(item.fileURL.lastPathComponent)
                            if fm.fileExists(atPath: newFolderURL.path) {
                                throw "A folder with the same name already exists in that destination."
                            }
                            let info = getFileItem(at: item.fileURL)
                            if info.uttype != .folder {
                                throw "Choose a folder as the destination."
                            }
                            try fm.createDirectory(at: newFolderURL, withIntermediateDirectories: true)
                            let folderURLs = try fm.contentsOfDirectory(at: item.fileURL, includingPropertiesForKeys: [])
                            for url in folderURLs {
                                try fm.moveItem(at: url, to: newFolderURL.appendingPathComponent(url.lastPathComponent))
                            }
                            try fm.removeItem(at: item.fileURL)
                            mgr.refreshFiles.toggle()
                        } catch {
                            print("[!] failed to move folder: \(error)")
                            Alertinator.shared.alert(title: "Failed to move folder!", body: (error as? String) ?? "Choose another folder, then try again.")
                        }
                    }
                }
            } label: {
                Label("Move", systemImage: "rectangle.portrait.and.arrow.right")
            }
            
            Button {
                if let url = makeTemp(item.fileURL) {
                    presentShareSheet(with: url)
                }
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            if item.writable {
                CompatibleButton(role: .destructive) {
                    try? fm.removeItem(at: item.fileURL)
                    mgr.refreshFiles.toggle()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
