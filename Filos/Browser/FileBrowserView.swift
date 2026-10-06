//
//  FileBrowserView.swift
//  AccessiblePlus
//
//  Created by lunginspector on 5/12/26.
//

import SwiftUI

import QuickLook

enum FileSortMode: String, CaseIterable, Codable, Hashable {
    case system, name, date, type, size
    
    var id: String { label }
    
    var label: String {
        switch self {
        case .system: return "Default"
        case .name: return "Name"
        case .date: return "Date"
        case .type: return "Type"
        case .size: return "Size"
        }
    }
}

enum FileBrowserState {
    case loading, loaded, noPerms, noFiles, unknownError
    
    var description: String {
        switch self {
        case .noFiles: return "This directory is empty."
        case .noPerms: return "You don't have permission to view the files in this directory."
        case .unknownError: return "Unknown error."
        default: return ""
        }
    }
    
    var symbol: String {
        switch self {
        case .noFiles: return "questionmark.folder"
        case .noPerms: return "externaldrive.badge.xmark"
        case .unknownError: return "exclamationmark.triangle"
        default: return ""
        }
    }
}

struct FileBrowserView: View {
    @EnvironmentObject var mgr: FilosManager
    @State var item: FileItem
    
    @State private var dirFiles: [FileItem] = []
    @State private var unfilteredFiles: [FileItem] = []
    @State private var searchText = ""
    @AppStorage("chosenSort") var chosenSort: FileSortMode = .system
    @AppStorage("filesAscend") var filesAscend: Bool = true
    @AppStorage("listStyle") var listStyle = 1
    
    @State private var receivedPreviewer: FBPreviewer?
    @State private var previewer: FBPreviewer?
    @State private var quickLookURL: URL?
    @State private var currentState = FileBrowserState.loading
    @State private var showFavs = false
    @State private var showLogs = false
    @State private var showSettings = false
    @State private var showFileImporter = false
    
    var body: some View {
        Group {
            if currentState == .loading {
                VStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(1.25)
                    Text("Loading Files...")
                        .compatibleForegroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else if currentState == .loaded {
                List {
                    ForEach(dirFiles) { file in
                        if file.type == .folder {
                            FolderRow(item: file, parent: item, previewer: $receivedPreviewer)
                        } else {
                            FileRow(item: file, parent: item, previewer: $receivedPreviewer)
                        }
                    }
                }
                .compatibleSearchable(text: $searchText)
                .compatibleRefreshable {
                    mgr.refreshFiles.toggle()
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: currentState.symbol)
                        .font(.largeTitle)
                    if currentState == .noFiles {
                        Text(currentState.description)
                    } else {
                        VStack {
                            Text("Failed to load files from path!")
                            Text(currentState == .unknownError ? "This folder couldn’t be opened. Try again." : currentState.description)
                                .multilineTextAlignment(.center)
                                .compatibleForegroundColor(.secondary)
                                .font(.footnote)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(item.fileURL.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
        .customListStyle(listStyle)
        .adaptiveListMargin()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(FileSortMode.allCases, id: \.self) { option in
                        Button {
                            chosenSort = option
                        } label: {
                            if chosenSort == option {
                                Label(option.label, systemImage: "checkmark")
                                    .tag(option)
                            } else {
                                Text(option.label)
                                    .tag(option)
                            }
                        }
                    }
                    Divider()
                    Button {
                        filesAscend.toggle()
                    } label: {
                        if filesAscend {
                            Label("Ascending", systemImage: "chevron.up")
                        } else {
                            Label("Descending", systemImage: "chevron.down")
                        }
                    }
                    .disabled(chosenSort == .system)
                } label: {
                    Label("Sort", systemImage: "line.3.horizontal.decrease")
                        .labelStyle(.iconOnly)
                }
                .labelStyle(.iconOnly)
                .disabled(currentState != .loaded)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if #unavailable(iOS 15.0) {
                        Button {
                            mgr.refreshFiles.toggle()
                        } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        Divider()
                    }
                    if item.writable {
                        Menu {
                            Button {
                                Alertinator.shared.prompt(title: "What would you like to call your new file? Make sure you attach an extension at the end.", placeholder: "new.txt", completion: { name in
                                    let name = name ?? ""
                                    if !name.isEmpty {
                                        do {
                                            let fileURL = item.fileURL.appendingPathComponent(name)
                                            try Data().write(to: fileURL)
                                            mgr.refreshFiles.toggle()
                                        } catch {
                                            print("(fm) failed to create file: \(error)")
                                            
                                        }
                                    }
                                })
                            } label: {
                                Label("File", systemImage: "doc")
                            }
                            
                            Button {
                                Alertinator.shared.prompt(title: "What would you like to call your new property list?", placeholder: "Plist Name", completion: { name in
                                    let name = name ?? ""
                                    if !name.isEmpty {
                                        do {
                                            let fileURL = item.fileURL.appendingPathComponent(name + ".plist")
                                            let data = try PropertyListSerialization.data(fromPropertyList: NSMutableDictionary(), format: .xml, options: 0)
                                            try data.write(to: fileURL)
                                            mgr.refreshFiles.toggle()
                                        } catch {
                                            print("(fm) failed to create plist: \(error)")
                                            Alertinator.shared.alert(title: "Failed to create property list!", body: Errors.checkLogs)
                                        }
                                    }
                                })
                            } label: {
                                Label("Property List", systemImage: "tablecells")
                            }
                            
                            Button {
                                Alertinator.shared.prompt(title: "What would you like to call your new folder?", placeholder: "Folder Name", completion: { name in
                                    let name = name ?? ""
                                    if !name.isEmpty {
                                        do {
                                            try fm.createDirectoryIfNeeded(at: item.fileURL.appendingPathComponent(name))
                                            mgr.refreshFiles.toggle()
                                        } catch {
                                            print("(fm) failed to create folder: \(error)")
                                            Alertinator.shared.alert(title: "Failed to create folder!", body: Errors.checkLogs)
                                        }
                                    }
                                })
                            } label: {
                                Label("Folder", systemImage: "folder")
                            }
                            
                            Button {
                                Alertinator.shared.prompt(title: "Where would you like your new symlink to point to?", placeholder: "/path/to/dir", completion: { symPath in
                                    let symPath = symPath ?? ""
                                    if !symPath.isEmpty {
                                        do {
                                            try fm.createSymbolicLink(atPath: item.fileURL.appendingPathComponent(URL(fileURLWithPath: symPath).lastPathComponent).path, withDestinationPath: symPath)
                                            mgr.refreshFiles.toggle()
                                        } catch {
                                            print("(fm) failed to create symlink: \(error)")
                                            Alertinator.shared.alert(title: "Failed to create symlink!", body: "Check the destination path, then try again.")
                                        }
                                    }
                                })
                            } label: {
                                Label("Symlink", systemImage: "arrow.up.right.circle")
                            }
                        } label: {
                            Label("New...", systemImage: "plus")
                        }
                        .disabled(currentState != .loaded && currentState != .noFiles)
                        
                        Button {
                            showFileImporter.toggle()
                        } label: {
                            Label("Import File", systemImage: "arrow.down.doc")
                        }
                        .disabled(currentState != .loaded && currentState != .noFiles)
                        
                        Divider()
                    }
                    
                    Button {
                        showFavs.toggle()
                    } label: {
                        Label("Favorites", systemImage: "star")
                    }
                    
                    Button {
                        Alertinator.shared.prompt(title: "Where would you like to go?", text: item.fileURL.path, completion: { path in
                            let path = generateNavPath(path: path ?? "")
                            
                            if !path.isEmpty {
                                mgr.push(URL(fileURLWithPath: path))
                            }
                        })
                    } label: {
                        Label("Go to Directory...", systemImage: "arrow.right.arrow.left")
                    }
                    
                    Divider()
                    
                    Button {
                        showLogs.toggle()
                    } label: {
                        Label("Logs", systemImage: "terminal")
                    }
                    
                    Button {
                        showSettings.toggle()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis")
                }
                .labelStyle(.iconOnly)
            }
        }
        .onChange(of: receivedPreviewer) { receivedPrev in
            if receivedPrev?.type == .quickLook {
                quickLookURL = receivedPrev?.file.fileURL
            } else {
                previewer = receivedPrev
            }
        }
        .sheet(item: $previewer) { newPrev in
            switch newPrev.type {
            case .info: InfoViewer(newPrev.file, onClose: { previewer = nil })
            case .plist: PlistViewer(newPrev.file.fileURL, onClose: { previewer = nil })
            case .text: TextViewer(newPrev.file.fileURL, onClose: { previewer = nil })
            default: EmptyView()
            }
        }
        .quickLookPreview($quickLookURL)
        .sheet(isPresented: $showFavs) {
            FavoritesSheet(onClose: { showFavs = false })
        }
        .sheet(isPresented: $showLogs) {
            LogView(onClose: { showLogs = false })
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(onClose: { showSettings = false })
        }
        .sheet(isPresented: $showFileImporter) {
            DocumentImportPicker(isPresented: $showFileImporter) { url in
                handleImport(.success(url))
            }
        }
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                loadDirFiles()
            }
        }
        .onChange(of: searchText) { newSearch in
            if newSearch.isEmpty {
                dirFiles = unfilteredFiles
            } else {
                dirFiles = unfilteredFiles.filter { $0.name.localizedCaseInsensitiveContains(newSearch) }
            }
        }
        .onChange(of: chosenSort) { _ in
            dirFiles = sortFiles(files: dirFiles)
        }
        .onChange(of: filesAscend) { _ in
            dirFiles = sortFiles(files: dirFiles)
        }
        .onChange(of: mgr.refreshFiles) { _ in
            DispatchQueue.global(qos: .userInitiated).async {
                loadDirFiles()
            }
        }
    }
    
    // MARK: handle files
    private func loadDirFiles() {
        do {
            currentState = .loading
            let pathFiles = try fm.contentsOfDirectory(at: item.fileURL, includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .fileSizeKey, .contentModificationDateKey])
            
            let unsortedFiles = pathFiles.map { fileURL in
                return getFileItem(at: fileURL)
            }
            dirFiles = sortFiles(files: unsortedFiles)
            unfilteredFiles = sortFiles(files: unsortedFiles)
            if dirFiles.isEmpty {
                currentState = .noFiles
            } else {
                currentState = .loaded
            }
        } catch {
            let nserror = error as NSError
            print("[!] failed to load files from \(item.fileURL.path): \(nserror.localizedDescription) (code \(nserror.code))")
            if nserror.code == NSFileReadNoPermissionError {
                currentState = .noPerms
            } else {
                currentState = .unknownError
            }
        }
    }
    
    private func sortFiles(files: [FileItem]) -> [FileItem] {
        var sortedFiles: [FileItem]
        
        switch chosenSort {
        case .system:
            sortedFiles = files
        case .name:
            sortedFiles = files.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .date:
            sortedFiles = files.sorted { $0.modifiedDate > $1.modifiedDate }
        case .type:
            sortedFiles = files.sorted { $0.type.sortOrder < $1.type.sortOrder }
        case .size:
            sortedFiles = files.sorted { $0.size < $1.size }
        }

        sortedFiles = filesAscend ? sortedFiles : sortedFiles.reversed()
        sortedFiles = sortedFiles.sorted { a, b in
            a.hidden && !b.hidden
        }
        return sortedFiles
    }
    
    // MARK: handle import
    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let fileURL):
            do {
                let stopAccess = fileURL.startAccessingSecurityScopedResource()
                defer {
                    if stopAccess {
                        fileURL.stopAccessingSecurityScopedResource()
                    }
                }
                let data = try Data(contentsOf: fileURL)
                
                let newURL = item.fileURL.appendingPathComponent(fileURL.lastPathComponent)
                try? fm.removeItem(at: newURL)
                
                try data.write(to: newURL)
                mgr.refreshFiles.toggle()
            } catch {
                print("(fm) failed to import file: \(error)")
                Alertinator.shared.alert(title: "Failed to import file!", body: "Try again, or choose another file.")
            }
        case .failure(let error):
            print("(fm) failed to import file: \(error)")
            Alertinator.shared.alert(title: "Failed to import file!", body: "Try again, or choose another file.")
        }
    }
}
