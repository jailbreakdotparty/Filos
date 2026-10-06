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
    var onClose: () -> Void
    
    @AppStorage("favList") var favList: [FavoriteItem] = []
    
    @State private var label = ""
    @State private var path = ""
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        mgr.push(URL.documentsDirectory)
                        onClose()
                    } label: {
                        NavigationLabel(text: "Documents")
                    }
                    
                    Button {
                        mgr.push(fm.temporaryDirectory)
                        onClose()
                    } label: {
                        NavigationLabel(text: "Temp")
                    }
                    
                    Button {
                        mgr.push(URL.documentsDirectory.deletingLastPathComponent())
                        onClose()
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
                                mgr.push(URL(fileURLWithPath: path))
                                onClose()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(fav.label)
                                        Text(fav.path)
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Chevron()
                                }
                            }
                            .foregroundColor(Color(.label))
                            .padding(.vertical, 1)
                            .contextMenu {
                                Button {
                                    favList.removeAll { $0.id == fav.id }
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                                .foregroundColor(.red)
                            }
                        }
                    } header: {
                        HeaderLabel("Favorites", symbol: "star")
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)

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
                        onClose()
                    } label: {
                        Text("Close")
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

                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showAddSheet = false
                            } label: {
                                Text("Cancel")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                if label.isEmpty || label.isEmpty || favList.compactMap({ $0.path }).contains(path) {
                                    Alertinator.shared.alert(title: "Invaild Favorite!", body: "Please make sure that you've typed in both the label and path fields, and that the path you put in is not the same as any paths currently added as favorites.")
                                } else {
                                    favList.append(FavoriteItem(label: label, path: path))
                                    showAddSheet = false
                                }
                            } label: {
                                Text("Save")
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
