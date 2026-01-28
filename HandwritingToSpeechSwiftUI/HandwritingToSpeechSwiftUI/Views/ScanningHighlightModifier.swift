//
//  ScanningHighlightModifier.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 11.3: Scanning Highlight Modifier
//  Visual highlight effect for scanning mode (AC2).
//  Applies bright border and scale effect to currently scanned element.
//

import SwiftUI

// MARK: - Task 3.1, 3.2: ScanningHighlightModifier

/// Story 11.3 AC2: Visual modifier for highlighting scanned elements
/// Applies bright yellow border (4pt) and scale effect (1.05) when highlighted
struct ScanningHighlightModifier: ViewModifier {

    // Task 3.3: Parameters
    let index: Int
    let isHighlighted: Bool
    // L1 Fix: Configurable corner radius to match different button styles
    let cornerRadius: CGFloat

    // Task 3.5: Animation configuration
    private let animationDuration: Double = 0.2

    func body(content: Content) -> some View {
        content
            // Task 3.4: Bright border highlight (4pt, Color.yellow)
            // L1 Fix: Use configurable cornerRadius
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isHighlighted ? Color.yellow : Color.clear,
                        lineWidth: 4
                    )
            )
            // Task 3.4: Scale effect for visibility
            .scaleEffect(isHighlighted ? 1.05 : 1.0)
            // Task 3.5: Smooth animation
            .animation(.easeInOut(duration: animationDuration), value: isHighlighted)
            // Task 3.7: VoiceOver traits for highlighted state
            .accessibilityAddTraits(isHighlighted ? .isSelected : [])
    }
}

// MARK: - Task 3.6: View Extension

extension View {
    /// Story 11.3 AC2: Apply scanning highlight to a view
    /// - Parameters:
    ///   - index: The index of this item in the scanning sequence
    ///   - highlightedIndex: The currently highlighted index (nil when not scanning)
    ///   - cornerRadius: The corner radius for the highlight border (default: 16 to match most buttons)
    /// - Returns: Modified view with scanning highlight effect
    /// L1 Fix: Added configurable cornerRadius parameter with default of 16
    func scanningHighlight(index: Int, highlightedIndex: Int?, cornerRadius: CGFloat = 16) -> some View {
        modifier(ScanningHighlightModifier(
            index: index,
            isHighlighted: index == highlightedIndex,
            cornerRadius: cornerRadius
        ))
    }
}

// MARK: - Preview

#if DEBUG
struct ScanningHighlightModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Not highlighted
            Text("Button 1")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)
                .scanningHighlight(index: 0, highlightedIndex: 1, cornerRadius: 12)

            // Highlighted
            Text("Button 2 (Highlighted)")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)
                .scanningHighlight(index: 1, highlightedIndex: 1, cornerRadius: 12)

            // Not highlighted
            Text("Button 3")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)
                .scanningHighlight(index: 2, highlightedIndex: 1, cornerRadius: 12)
        }
        .padding()
        .previewDisplayName("Scanning Highlight")
    }
}
#endif
