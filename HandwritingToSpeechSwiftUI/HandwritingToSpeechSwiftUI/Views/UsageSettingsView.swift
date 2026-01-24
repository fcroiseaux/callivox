import SwiftUI
import CoreLocation

struct UsageSettingsView: View {
    @StateObject private var usageManager = UsageLogManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var refreshView = false // Used to force view refresh
    @State private var isLocationDisabled = false // Track if location services are disabled
    @State private var isLocationUnavailable = false // Track if location services are unavailable for this app
    
    // Don't use init with NotificationCenter in a struct - let's use onAppear instead
    
    // Helper function to convert authorization status to user-friendly string
    private func authStatusToString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "Non déterminé"
        case .restricted:
            return "Restreint"
        case .denied:
            return "Refusé"
        case .authorizedAlways:
            return "Toujours"
        case .authorizedWhenInUse:
            return "Utilisation"
        @unknown default:
            return "Inconnu"
        }
    }
    
    // Helper function to get color for status
    private func authStatusColor(_ status: CLAuthorizationStatus) -> Color {
        switch status {
        case .notDetermined:
            return .orange
        case .restricted, .denied:
            return .red
        case .authorizedAlways, .authorizedWhenInUse:
            return .green
        @unknown default:
            return .gray
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Hidden dummy element to force view refresh
                Text("").hidden()
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LocationAuthorizationChanged"))) { _ in
                        // Force a view refresh when location authorization changes
                        refreshView.toggle()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LocationServicesDisabled"))) { _ in
                        // System-level location services are disabled
                        isLocationDisabled = true
                        isLocationUnavailable = false
                        refreshView.toggle()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LocationServicesUnavailable"))) { _ in
                        // Location services are unavailable for this app
                        isLocationUnavailable = true
                        isLocationDisabled = false
                        refreshView.toggle()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LocationPermissionDenied"))) { _ in
                        // Location permission has been explicitly denied
                        isLocationDisabled = false
                        isLocationUnavailable = false
                        refreshView.toggle()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        // Refresh the view when app becomes active (returning from Settings)
                        refreshView.toggle()
                        // Also force refresh the location status
                        usageManager.checkCurrentAuthorizationStatus()
                    }
                Section(header: Text("Collecte de données")) {
                    Toggle("Enregistrer l'utilisation", isOn: $usageManager.isLoggingEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    if usageManager.isLoggingEnabled {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Nous collectons les phrases utilisées pour améliorer notre service et personnaliser votre expérience.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Text("Toutes les données sont pseudonymisées et ne peuvent pas être utilisées pour vous identifier personnellement.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                Section(header: Text("Localisation")) {
                    // Status with detailed info
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Statut")
                            Spacer()
                            Text(usageManager.isLocationEnabled ? "Autorisé" : "Non autorisé")
                                .foregroundColor(usageManager.isLocationEnabled ? .green : .red)
                                .fontWeight(.bold)
                        }
                        
                        // Show actual authorization status
                        HStack {
                            Text("Autorisation")
                            Spacer()
                            Text(usageManager.isLocationEnabled ? "Autorisée" : "Non autorisée")
                                .foregroundColor(usageManager.isLocationEnabled ? .green : .red)
                                .fontWeight(.semibold)
                        }
                        .font(.footnote)
                        
                        // Show appropriate warning based on the current state
                        if isLocationDisabled {
                            Text("⚠️ Les services de localisation sont désactivés sur cet appareil. Activez-les dans Réglages > Confidentialité > Service de localisation.")
                                .font(.footnote)
                                .foregroundColor(.orange)
                                .padding(.top, 2)
                                .padding(.bottom, 4)
                        } else if isLocationUnavailable {
                            Text("⚠️ Les services de localisation ne sont pas disponibles pour cette application. Vérifiez les restrictions ou autorisations système.")
                                .font(.footnote)
                                .foregroundColor(.orange)
                                .padding(.top, 2)
                                .padding(.bottom, 4)
                        } else if !usageManager.isLocationEnabled && usageManager.locationManager.authorizationStatus == .denied {
                            Text("⚠️ Vous avez refusé l'accès à la localisation. Vous pouvez le réactiver dans les Réglages.")
                                .font(.footnote)
                                .foregroundColor(.orange)
                                .padding(.top, 2)
                        } else if !usageManager.isLocationEnabled {
                            Text("Autorisation requise pour utiliser la localisation")
                                .font(.footnote)
                                .foregroundColor(.orange)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.vertical, 5)
                    
                    // Primary action button - now more explicit about what it does
                    Button(action: {
                        // Always request permission when the button is clicked
                        if isLocationDisabled {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } else if !isLocationUnavailable {
                            usageManager.requestLocationPermission()
                        } else {
                            // Service unavailable, just log this case
                            print("⚠️ Location services unavailable for this app")
                        }
                    }) {
                        HStack {
                            if usageManager.isLocationEnabled {
                                Image(systemName: "location.fill")
                                Text("Statut: Autorisé")
                            } else if isLocationDisabled {
                                Image(systemName: "gear")
                                Text("Activer dans Réglages")
                            } else if isLocationUnavailable {
                                Image(systemName: "exclamationmark.triangle")
                                Text("Services non disponibles")
                            } else if usageManager.locationManager.authorizationStatus == .denied {
                                Image(systemName: "location.slash")
                                Text("Ouvrir Réglages")
                            } else {
                                Image(systemName: "location.slash")
                                Text("Autoriser la localisation")
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(
                            usageManager.isLocationEnabled ? Color.green :
                            (isLocationDisabled || isLocationUnavailable) ? Color.orange : Color.blue
                        )
                        .cornerRadius(8)
                    }
                    .padding(.vertical, 5)
                    .disabled(isLocationUnavailable)
                    
                    // Secondary action - open settings
                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Ouvrir les Réglages")
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.top, 5)
                    
                    // Special action to check location services status
                    Button(action: {
                        // Force a fresh check of location status
                        let isEnabled = CLLocationManager.locationServicesEnabled()
                        print("📱 Location services enabled at system level: \(isEnabled)")
                        
                        // Update our state based on the check
                        isLocationDisabled = !isEnabled
                        
                        // Also check the authorization status
                        usageManager.checkCurrentAuthorizationStatus()
                        
                        // Force UI refresh
                        refreshView.toggle()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Vérifier le statut")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Nous utilisons votre localisation approximative pour analyser les tendances régionales et améliorer les services localisés.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
                
                if usageManager.pendingLogsCount > 0 {
                    Section(header: Text("Données locales")) {
                        HStack {
                            Text("Phrases en attente d'envoi")
                            Spacer()
                            Text("\(usageManager.pendingLogsCount)")
                                .foregroundColor(.secondary)
                        }
                        
                        Button(action: {
                            usageManager.submitOfflineLogs()
                        }) {
                            Text("Envoyer maintenant")
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            usageManager.clearOfflineLogs()
                        }) {
                            Text("Supprimer toutes les données locales")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("À propos")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Protection de la vie privée")
                            .font(.headline)
                        
                        Text("Toutes les données sont pseudonymisées avant d'être envoyées. Elles ne contiennent pas d'informations permettant de vous identifier directement. La localisation est approximative (précision au kilomètre).")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Text("Vous pouvez désactiver la collecte de données à tout moment en utilisant le bouton ci-dessus.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Confidentialité et données")
            .navigationBarItems(trailing: Button("Fermer") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct UsageSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UsageSettingsView()
    }
}
