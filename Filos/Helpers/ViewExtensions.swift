//
//  ViewExtensions.swift
//  Filos
//
//  Created by lunginspector on 9/26/26.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

extension View {
    @ViewBuilder
    func customListStyle(_ selection: Int) -> some View {
        switch selection {
        case 2: self.listStyle(.inset)
        case 3: self.listStyle(.grouped)
        default: self.listStyle(.insetGrouped)
        }
    }
    
    @ViewBuilder
    func adaptiveListMargin() -> some View {
        if #available(iOS 26.0, *) {
            self.contentMargins(.top, 0)
        } else {
            self
        }
    }
    
    // Keep newer SwiftUI APIs on supported systems and confine older APIs to iOS 14.
    @ViewBuilder
    func compatibleForegroundColor(_ color: Color) -> some View {
        if #available(iOS 15.0, *) {
            self.foregroundStyle(color)
        } else {
            self.foregroundColor(color)
        }
    }

    @ViewBuilder
    func compatibleBackground<V: View>(@ViewBuilder content: () -> V) -> some View {
        if #available(iOS 15.0, *) {
            self.background(content: content)
        } else {
            self.background(content())
        }
    }

    func compatibleBackground<S: Shape>(_ color: Color, in shape: S) -> some View {
        compatibleBackground { color.clipShape(shape) }
    }

    @ViewBuilder
    func compatibleOverlay<V: View>(@ViewBuilder content: () -> V) -> some View {
        if #available(iOS 15.0, *) {
            self.overlay(content: content)
        } else {
            self.overlay(content())
        }
    }

    @ViewBuilder
    func compatibleBottomInset<V: View>(@ViewBuilder content: () -> V) -> some View {
        if #available(iOS 15.0, *) {
            self.safeAreaInset(edge: .bottom, content: content)
        } else {
            VStack(spacing: 0) {
                self
                content()
            }
        }
    }

    @ViewBuilder
    func compatibleSearchable(text: Binding<String>) -> some View {
        if #available(iOS 15.0, *) {
            self.searchable(text: text)
        } else {
            VStack(spacing: 0) {
                FileSearchField(text: text)
                    .fixedSize(horizontal: false, vertical: true)
                self
            }
        }
    }

    @ViewBuilder
    func compatibleRefreshable(action: @escaping @Sendable () async -> Void) -> some View {
        if #available(iOS 15.0, *) {
            self.refreshable(action: action)
        } else {
            self
        }
    }

    @ViewBuilder
    func compatibleGlassEffect<S: Shape>(in shape: S) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self
        }
        #else
        self
        #endif
    }
}

enum CompatibleButtonRole: Equatable {
    case destructive, adaptiveConfirm
}

struct CompatibleButton<Label: View>: View {
    let role: CompatibleButtonRole
    let action: () -> Void
    let label: () -> Label

    init(role: CompatibleButtonRole, action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.role = role
        self.action = action
        self.label = label
    }

    init(_ title: LocalizedStringKey, role: CompatibleButtonRole, action: @escaping () -> Void) where Label == Text {
        self.init(role: role, action: action) { Text(title) }
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            Button(role: role == .destructive ? .destructive : .adaptiveConfirm, action: action, label: label)
        } else {
            Button(action: action, label: label)
                .foregroundColor(role == .destructive ? .red : nil)
        }
    }
}

private struct FileSearchField: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search files"
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ searchBar: UISearchBar, context: Context) {
        context.coordinator.text = $text
        if searchBar.text != text { searchBar.text = text }
    }

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    class Coordinator: NSObject, UISearchBarDelegate {
        var text: Binding<String>
        init(text: Binding<String>) { self.text = text }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text.wrappedValue = searchText
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
}

struct SelectableTextView: UIViewRepresentable {
    let text: String
    let size: CGFloat
    var monospaced = true
    var followOutput = false

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = false
        view.isSelectable = true
        view.backgroundColor = .clear
        view.textColor = .label
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        view.font = monospaced ? .monospacedSystemFont(ofSize: size, weight: .regular) : .systemFont(ofSize: size)
        if view.text != text {
            view.text = text
            if followOutput {
                view.scrollRangeToVisible(NSRange(location: (text as NSString).length, length: 0))
            }
        }
    }
}

struct DocumentImportPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onImport: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ picker: UIDocumentPickerViewController, context: Context) {
        context.coordinator.parent = self
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentImportPicker
        init(parent: DocumentImportPicker) { self.parent = parent }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.isPresented = false
            if let url = urls.first { parent.onImport(url) }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.isPresented = false
        }
    }
}
