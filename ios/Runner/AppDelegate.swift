import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var secureView: UIView?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Prevent screenshots and screen recording
    setupSecureScreen()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func setupSecureScreen() {
    // Create a secure text field to prevent screenshots
    // This technique works because UITextField with isSecureTextEntry blocks screenshots
    guard let window = UIApplication.shared.windows.first else { return }
    
    let secureField = UITextField()
    secureField.isSecureTextEntry = true
    secureField.isUserInteractionEnabled = false
    
    // Add the secure text field's layer to the window
    // This makes the entire window secure
    if let secureLayer = secureField.layer.sublayers?.first {
      secureLayer.addSublayer(window.layer)
      window.layer.superlayer?.addSublayer(secureLayer)
    }
    
    // Listen for screenshot notification (optional: to show warning)
    NotificationCenter.default.addObserver(
      forName: UIApplication.userDidTakeScreenshotNotification,
      object: nil,
      queue: .main
    ) { _ in
      // You could show an alert here if needed
      print("Screenshot attempted - content may be protected")
    }
  }
}

