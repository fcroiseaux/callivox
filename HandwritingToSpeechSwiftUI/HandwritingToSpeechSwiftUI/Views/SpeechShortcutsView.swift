import SwiftUI
import UIKit

struct SpeechShortcutsView: View {
    @EnvironmentObject var presetManager: PresetSentenceManager
    @EnvironmentObject var speechService: SpeechService
    
    // Colonnes adaptatives pour le LazyVGrid
    let gridColumns = [
        GridItem(.adaptive(minimum: 120), spacing: 10)
    ]
    
    // Calcul de la hauteur maximale requise pour les boutons, en fonction du texte
    var maxButtonHeight: CGFloat {
        // La largeur interne disponible pour le texte (en tenant compte d'une marge horizontale)
        let horizontalPadding: CGFloat = 16
        let textWidth = 120 - horizontalPadding
        // Police fixe utilisée dans le bouton
        let font = UIFont.preferredFont(forTextStyle: .subheadline)
        // Marge verticale à ajouter
        let verticalPadding: CGFloat = 16
        // Hauteur minimale par défaut
        let minHeight: CGFloat = 50
        
        let heights = presetManager.selectedPresets.map { text -> CGFloat in
            let boundingBox = text.boundingRect(with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
            return ceil(boundingBox.height) + verticalPadding
        }
        
        let calculatedMax = heights.max() ?? minHeight
        return max(calculatedMax, minHeight)
    }
    
    var body: some View {
        if !presetManager.selectedPresets.isEmpty {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(presetManager.selectedPresets, id: \.self) { phrase in
                    Button(action: {
                        speechService.speakText(phrase)
                    }) {
                        Text(phrase)
                            .font(.subheadline) // Taille de police fixe
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: 120, height: maxButtonHeight)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}