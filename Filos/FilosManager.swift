//
//  FilosManager.swift
//  Filos
//
//  Created by lunginspector on 7/12/26.
//

import SwiftUI
import UIKit
import Combine

import UniformTypeIdentifiers

enum Errors {
    static var checkLogs = "Check error logs for more detailed information."
}

struct NavItem {
    let id = UUID()
    let url: URL
}

final class FilosManager: ObservableObject {
    static let shared = FilosManager()
    
    @Published var refreshFiles = false
    @Published var logOutput = ""
    @Published var tokenVaild = false
    @Published var fmNavPath = NavigationPath()
    @AppStorage("favList") var favorites: [FavoriteItem] = []
    
    init() { }
    
    func isFavorited(_ item: FileItem) -> Bool {
        if let _ = favorites.firstIndex(where: { $0.path == item.fileURL.path }) {
            return true
        }
        return false
    }

    func addFavorite(_ item: FileItem) {
        favorites.append(FavoriteItem(label: item.name, path: item.fileURL.path))
    }

    func removeFavorite(_ item: FileItem) {
        if let index = favorites.firstIndex(where: { $0.path == item.fileURL.path }) {
            favorites.remove(at: index)
        }
    }
}

// ios 15 surprise!
extension URL {
    static var temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
    static var documentsDirectory: URL = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
}
