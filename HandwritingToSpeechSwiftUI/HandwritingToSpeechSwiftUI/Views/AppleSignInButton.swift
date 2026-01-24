import SwiftUI
import AuthenticationServices

struct SignInWithAppleButton: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    var onRequest: ((ASAuthorizationAppleIDRequest) -> Void)?
    var onCompletion: ((Result<ASAuthorization, Error>) -> Void)?
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: type, style: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTapButton), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onRequest: onRequest, onCompletion: onCompletion)
    }
    
    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        var onRequest: ((ASAuthorizationAppleIDRequest) -> Void)?
        var onCompletion: ((Result<ASAuthorization, Error>) -> Void)?
        
        init(onRequest: ((ASAuthorizationAppleIDRequest) -> Void)?, onCompletion: ((Result<ASAuthorization, Error>) -> Void)?) {
            self.onRequest = onRequest
            self.onCompletion = onCompletion
        }
        
        @objc func didTapButton() {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            onRequest?(request)
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            onCompletion?(.success(authorization))
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            onCompletion?(.failure(error))
        }
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            // Get the active window scene for iOS 15+
            if #available(iOS 15.0, *) {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                return windowScene?.windows.first { $0.isKeyWindow } ?? UIWindow()
            } else {
                // Fallback for older iOS versions
                return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
            }
        }
    }
}
