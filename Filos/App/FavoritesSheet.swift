//
//  FavoritesSheet.swift
//  AccessiblePlus
//
//  Created by lunginspector on 5/20/26.
//

import SwiftUI


struct FavoriteItem: Identifiable, Codable {
    var id: String { path }
    var label: String
    var path: String
}

struct FavoritesSheet: View {
    @EnvironmentObject private var mgr: FilosManager
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("favList") var favList: [FavoriteItem] = []
    
    @State private var label = ""
    @State private var path = ""
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        mgr.fmNavPath.append(URL.documentsDirectory)
                        dismiss()
                    } label: {
                        NavigationLabel(text: "Documents")
                    }
                    
                    Button {
                        mgr.fmNavPath.append(URL.temporaryDirectory)
                        dismiss()
                    } label: {
                        NavigationLabel(text: "Temp")
                    }
                    
                    Button {
                        mgr.fmNavPath.append(URL.documentsDirectory.deletingLastPathComponent())
                        dismiss()
                    } label: {
                        NavigationLabel(text: "Container")
                    }
                } header: {
                    HeaderLabel("Filos", symbol: "folder")
                }
                
                if !favList.isEmpty {
                    Section {
                        ForEach(favList) { fav in
                            Button {
                                let path = generateNavPath(path: fav.path)
                                mgr.fmNavPath.append(URL(fileURLWithPath: path))
                                dismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(fav.label)
                                        Text(fav.path)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Chevron()
                                }
                            }
                            .foregroundStyle(Color(.label))
                            .padding(.vertical, !isSolariumUI() ? 1 : 0)
                            .contextMenu {
                                Button(role: .destructive) {
                                    favList.removeAll { $0.id == fav.id }
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        HeaderLabel("Favorites", symbol: "star")
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .noRefreshable()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        ToolbarLabel("Close", symbol: "xmark")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                NavigationView {
                    List {
                        HStack {
                            Text("Label")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            TextField("Label", text: $label)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Path")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            TextField("Path", text: $path)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .navigationTitle("Add Item")
                    .navigationBarTitleDisplayMode(.inline)
                    .noRefreshable()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showAddSheet = false
                            } label: {
                                ToolbarLabel("Cancel", symbol: "xmark")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(role: .adaptiveConfirm) {
                                if label.isEmpty || label.isEmpty || favList.compactMap({ $0.path }).contains(path) {
                                    Alertinator.shared.alert(title: "Invaild Favorite!", body: "Please make sure that you've typed in both the label and path fields, and that the path you put in is not the same as any paths currently added as favorites.")
                                } else {
                                    favList.append(FavoriteItem(label: label, path: path))
                                    showAddSheet = false
                                }
                            } label: {
                                ToolbarLabel("Save", symbol: "checkmark")
                            }
                        }
                    }
                    .onDisappear {
                        label = ""
                        path = ""
                    }
                }
            }
        }
    }
}
