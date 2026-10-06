import SwiftUI
import UIKit

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
