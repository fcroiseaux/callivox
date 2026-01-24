import SwiftUI
import AuthenticationServices

struct AppleSignInView: View {
    @EnvironmentObject var userModel: UserModel
    
    var body: some View {
        VStack {
            SignInWithAppleButton(
                type: .signIn,
                onRequest: { request in
                    // Request email and full name scopes
                    request.requestedScopes = [.fullName, .email]
                    print("Requesting Apple Sign In with scopes: fullName, email")
                },
                onCompletion: { result in
                    print("Apple Sign In completion received")
                    handleSignInWithAppleCompletion(result)
                }
            )
            .frame(width: 280, height: 45)
            .padding()
            
            if userModel.isAuthenticating {
                ProgressView("Authentification en cours...")
                    .padding()
            }
            
            if let errorMessage = userModel.authErrorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    private func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            // Gestion des identifiants Apple ID
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Debug information about the credential
                print("Apple ID Credential received:")
                print("- User: \(appleIDCredential.user)")
                print("- Full Name: \(String(describing: appleIDCredential.fullName))")
                print("- Email: \(String(describing: appleIDCredential.email))")
                
                // Note: Apple may not provide email on subsequent sign-ins if the user
                // has already authorized the app. This is expected behavior.
                
                // Utiliser la nouvelle méthode d'authentification avec le backend
                userModel.authenticateWithApple(appleIDCredential: appleIDCredential)
            }
            // Gestion des identifiants de mot de passe
            else if let passwordCredential = authorization.credential as? ASPasswordCredential {
                // Pour cette méthode, on utilise toujours l'ancienne approche
                // car elle n'est pas concernée par l'intégration backend
                let userId = passwordCredential.user
                userModel.signIn(
                    userId: userId,
                    userName: nil,
                    userEmail: nil
                )
            }
            // En mode développement/simulateur, option rapide
            else {
                #if DEBUG
                // Utiliser un identifiant simulé en développement
                userModel.signIn(
                    userId: "dev-user-id",
                    userName: "Utilisateur Test",
                    userEmail: "test@example.com"
                )
                #else
                userModel.authErrorMessage = "Méthode d'authentification non prise en charge"
                #endif
            }
        case .failure(let error):
            print("Erreur d'authentification Apple: \(error.localizedDescription)")
            
            // En développement, permettre de contourner l'erreur
            #if DEBUG
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Authentification simulée pour le développement
                userModel.signIn(
                    userId: "dev-user-id",
                    userName: "Mode Développement",
                    userEmail: "dev@example.com"
                )
            }
            #else
            userModel.authErrorMessage = "Impossible de vous connecter: \(error.localizedDescription)"
            #endif
        }
    }
}
