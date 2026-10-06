//
//  ExtraHelpers.swift
//  Filos
//
//  Created by lunginspector on 7/22/26.
//

import SwiftUI


// thanks to skadz108 for this helper
func sbxConsume(_ token: String) -> Bool {
    typealias sbxConsumeFunc = @convention(c) (UnsafePointer<CChar>?) -> Int64
    
    guard let sbxLib = dlopen("/usr/lib/system/libsystem_sandbox.dylib", RTLD_NOW) else {
        return false
    }
    defer { dlclose(sbxLib) }
    
    guard let sbxConsumeSymbol = dlsym(sbxLib, "sandbox_extension_consume") else {
        return false
    }
    
    let consume = unsafeBitCast(sbxConsumeSymbol, to: sbxConsumeFunc.self)
    
    let result = consume(token)
    if result >= 1 {
        return true
    }
    return false
}

// make strings compatiable with errors
extension String: Error {}

// allows us to put arrays into AppStorage
extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

func machineName() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    return machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
}
