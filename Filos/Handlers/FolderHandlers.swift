//
//  FolderHandlers.swift
//  Filos
//
//  Created by lunginspector on 7/22/26.
//

import SwiftUI

func folderLabel(url: URL) -> String {
    return getNameFromInfP(url) ?? getBIDFromMCM(url) ?? getBIDFromXattr(url) ?? url.lastPathComponent
}

func getBIDFromMCM(_ url: URL) -> String? {
    let path = url.path + "/.com.apple.mobile_container_manager.metadata.plist"
    guard let plist = NSDictionary(contentsOf: URL(fileURLWithPath: path)) else { return nil }
    return plist["MCMMetadataIdentifier"] as? String
}

func getNameFromInfP(_ url: URL) -> String? {
    guard let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path) else { return nil }
    
    for item in contents where item.hasSuffix(".app") {
        let infopath = url.path + "/" + item + "/Info.plist"
        guard let plist = NSDictionary(contentsOf: URL(fileURLWithPath: infopath)) else { continue }
        
        return plist["CFBundleDisplayName"] as? String ?? plist["CFBundleName"] as? String ?? plist["CFBundleExecutable"] as? String
    }
    return nil
}

func getBIDFromXattr(_ url: URL) -> String? {
    var buf = [UInt8](repeating: 0, count: 512)
    
    let len = buf.withUnsafeMutableBytes {
        getxattr(url.path, "com.apple.containermanager.identifier", $0.baseAddress, 511, 0, XATTR_NOFOLLOW)
    }
    if len < 0 {
        print("failed to read xattr: \(String(cString: strerror(errno))) (errno \(errno))")
        return nil
    }
    let bid = String(cString: buf)
    
    if !bid.isEmpty {
        return bid
    }
    return nil
}

