//
//  SettingsView.swift
//  Filos
//
//  Created by lunginspector on 7/13/26.
//

import SwiftUI


struct SettingsView: View {
    @EnvironmentObject var mgr: FilosManager
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("sbxToken") var sbxToken = ""
    @AppStorage("consumeOnLaunch") var consumeOnLaunch = false
    
    @AppStorage("startDir") var startDir = "/"
    @AppStorage("showPreviews") var showPreviews = false
    @AppStorage("listStyle") var listStyle = 1
    @AppStorage("hideFavs") var hideFavs = false
    @AppStorage("hideDates") var hideDates = false
    @AppStorage("textViewerSize") var textViewerSize = 10
    @AppStorage("useMonospaced") var useMonospaced = true
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Token", text: $sbxToken)
                        .onLongPressGesture {
                            UIPasteboard.general.string = sbxToken
                        }
                    HStack {
                        HStack {
                            Image(systemName: mgr.tokenVaild ? "checkmark.circle" : "xmark.circle")
                            Text(mgr.tokenVaild ? "Valid" : "Invalid")
                        }
                        .foregroundStyle(mgr.tokenVaild ? .green : .red)
                        Spacer()
                        if !mgr.tokenVaild {
                            Button("Consume") {
                                if !sbxToken.isEmpty {
                                    mgr.tokenVaild = sbxConsume(sbxToken)
                                    
                                    if mgr.tokenVaild {
                                        print("[*] consumed=1, token valid!")
                                    } else {
                                        print("[!] consumed!=2, token invalid?")
                                        Haptic.shared.play(.heavy)
                                    }
                                }
                            }
                        } else {
                            Button("Eject", role: .destructive) {
                                sbxToken = ""
                                mgr.tokenVaild = false
                                Alertinator.shared.alert(title: "Token Ejected", body: "To reset file permissions, you'll have to restart the app. Would you like to exit now?", actionLabel: "Confirm", action: { exitinator() })
                            }
                        }
                    }
                    Toggle("Consume on Launch", isOn: $consumeOnLaunch)
                } header: {
                    HeaderLabel("Sandbox Extension Token", symbol: "loupe")
                }
                
                Section {
                    HStack {
                        Text("Start Directory")
                        Spacer()
                        TextField("/", text: $startDir)
                            .multilineTextAlignment(.trailing)
                            .lineLimit(1)
                    }
                    Picker("List Style", selection: $listStyle) {
                        Text("Default").tag(1)
                        Text("Plain").tag(2)
                        Text("Grouped").tag(3)
                    }
                } header: {
                    HeaderLabel("View Options", symbol: "eyes")
                }
                
                Section {
                    Toggle("Show File Previews", isOn: $showPreviews)
                    Toggle("Hide \"Favorite\" Button", isOn: $hideFavs)
                    Toggle("Hide Dates", isOn: $hideDates)
                }
                
                Section {
                    Stepper(value: $textViewerSize) {
                        HStack {
                            Text("Text Size")
                            Spacer()
                            Text(textViewerSize.description)
                        }
                    }
                    Toggle("Monospaced Font", isOn: $useMonospaced)
                } header: {
                    HeaderLabel("Text Viewer", symbol: "doc.plaintext")
                }
                
                Section {
                    AppInfoCell(build: "Release")
                    NavigationLink("Credits") {
                        List {
                            LinkCreditCell(image: Image("lunginspector"), name: "lunginspector", description: "Primary developer.", url: "https://github.com/lunginspector")
                            LinkCreditCell(image: Image("skadz"), name: "Skadz", description: "SBX-related stuff and some file browser things.", url: "https://github.com/skadz108")
                            LinkCreditCell(image: Image("roooot"), name: "roooot", description: "Archiving utilities.", url: "https://github.com/rooootdev")
                        }
                        .navigationTitle("Credits")
                    }
                } header: {
                    HeaderLabel("About", symbol: "info.circle")
                } footer: {
                    Text("Made with love by [jailbreak.party](https://jailbreak.party) team.\nNeed support? Join our [Discord server!](https://jailbreak.party/discord)")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .noRefreshable()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        ToolbarLabel("Close", symbol: "xmark")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

