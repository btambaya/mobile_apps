import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Register for screenshot notifications
    setupScreenshotNotification()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func setupScreenshotNotification() {
    // Listen for screenshot notification (optional: to show warning)
    NotificationCenter.default.addObserver(
      forName: UIApplication.userDidTakeScreenshotNotification,
      object: nil,
      queue: .main
    ) { _ in
      // You could show an alert here if needed
      print("Screenshot detected")
    }
  }
  
  // Hide content when app goes to background (app switcher protection)
  override func applicationWillResignActive(_ application: UIApplication) {
    // Add blur overlay when app goes to background
    if let window = self.window {
      let blurEffect = UIBlurEffect(style: .light)
      let blurView = UIVisualEffectView(effect: blurEffect)
      blurView.frame = window.bounds
      blurView.tag = 999
      window.addSubview(blurView)
    }
    super.applicationWillResignActive(application)
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    // Remove blur overlay when app becomes active
    if let window = self.window {
      window.viewWithTag(999)?.removeFromSuperview()
    }
    super.applicationDidBecomeActive(application)
  }
}
