//
//  FilosApp.swift
//  Filos
//
//  Created by lunginspector on 7/12/26.
//

import SwiftUI

var weOnADebugBuild: Bool = false
var pipe = Pipe()
var sema = DispatchSemaphore(value: 0)
let fm = FileManager.default

@main
struct FilosApp: App {
    @StateObject private var mgr = FilosManager.shared
    @AppStorage("sbxToken") var sbxToken = ""
    @AppStorage("consumeOnLaunch") var consumeOnLaunch = false
    
    init() {
        setvbuf(stdout, nil, _IONBF, 0)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        
        #if DEBUG
        weOnADebugBuild = true
        #else
        weOnADebugBuild = false
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mgr)
                .onAppear {
                    pipe.fileHandleForReading.readabilityHandler = { fh in
                        let data = fh.availableData
                        
                        if data.isEmpty {
                            fh.readabilityHandler = nil
                            sema.signal()
                            return
                        }
                        
                        guard let text = String(data: data, encoding: .utf8) else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            mgr.logOutput.append(text)
                        }
                    }
                    
                    print("[*] Filos v0.1 (Release)")
                    print("[*] Running on \(UIDevice.current.systemName) \(UIDevice.current.systemVersion), \(machineName())")
                    
                    if consumeOnLaunch && !sbxToken.isEmpty {
                        mgr.tokenVaild = sbxConsume(sbxToken)
                        
                        if mgr.tokenVaild {
                            print("[*] consumed=1, token valid!")
                        } else {
                            print("[!] consumed!=2, token invalid?")
                            Alertinator.shared.alert(title: "Failed to consume sandbox extension token!", body: "This token is likely invaild. Generate a new token, and put it in settings.")
                        }
                    }
                }
        }
    }
}
