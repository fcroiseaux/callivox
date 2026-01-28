//
//  ScannableContainer.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 11.3: Scannable Container View
//  Generic wrapper that enables scanning mode for any button group.
//  Manages scanning lifecycle (start/stop) and tap-to-select behavior.
//

import SwiftUI

// MARK: - Task 4.1, 4.2: ScannableContainer

/// Story 11.3 AC2, AC3: Generic container that enables scanning for button groups
/// Wraps content and provides tap-to-select functionality for scanning mode
struct ScannableContainer<Content: View>: View {

    // Task 4.3: Item count for scanning
    let itemCount: Int

    /// Callback when an item is selected via scanning (receives selected index)
    let onSelect: (Int) -> Void

    /// Content builder that receives the currently highlighted index
    @ViewBuilder let content: (_ highlightedIndex: Int?) -> Content

    // Task 4.5: Controller and settings references
    @ObservedObject private var controller = ScanningModeController.shared
    @ObservedObject private var settings = ScanningModeSettings.shared

    var body: some View {
        // Pass highlighted index to content
        content(settings.isEnabled ? controller.currentHighlightedIndex : nil)
            // Task 4.4: Tap gesture for selection (AC3)
            .contentShape(Rectangle())  // Entire area tappable
            .onTapGesture {
                handleTap()
            }
            // Task 4.6: Start/stop scanning on appear/disappear
            .onAppear {
                if settings.isEnabled {
                    controller.startScanning(itemCount: itemCount)
                }
            }
            .onDisappear {
                controller.stopScanning()
            }
            // Task 4.6: Respond to settings.isEnabled changes
            // M1 Fix: iOS 17+ onChange zero-parameter syntax (use settings.isEnabled directly)
            .onChange(of: settings.isEnabled) {
                controller.handleEnabledChange(settings.isEnabled, itemCount: itemCount)
            }
    }

    // MARK: - Tap Handling

    /// Handle tap gesture for scanning selection or resume
    private func handleTap() {
        // Only process if scanning is enabled
        guard settings.isEnabled else { return }

        if controller.isPaused {
            // AC4: Resume from pause
            controller.resumeScanning()
        } else if let selectedIndex = controller.selectCurrentItem() {
            // AC3: Activate selected item
            onSelect(selectedIndex)
        }
    }
}

// MARK: - Alternative Initializer for Simple Use Cases

extension ScannableContainer {
    /// Convenience initializer when content doesn't need highlighted index
    /// (for views that use ScanningHighlightModifier internally)
    init(
        itemCount: Int,
        onSelect: @escaping (Int) -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) where Content: View {
        self.itemCount = itemCount
        self.onSelect = onSelect
        self.content = { _ in content() }
    }
}

// MARK: - Preview

#if DEBUG
struct ScannableContainer_Previews: PreviewProvider {
    static var previews: some View {
        ScannableContainer(
            itemCount: 3,
            onSelect: { index in
                print("Selected index: \(index)")
            }
        ) { highlightedIndex in
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { index in
                    Text("Button \(index + 1)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                        .scanningHighlight(index: index, highlightedIndex: highlightedIndex, cornerRadius: 12)
                }
            }
            .padding()
        }
        .previewDisplayName("Scannable Container")
    }
}
#endif
