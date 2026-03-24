import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Resolves a real Maps SDK key from Info.plist. When `ios/Secrets.xcconfig` is missing,
  /// Xcode leaves `$(GOOGLE_MAPS_API_KEY)` literally in the plist; that string is non-empty
  /// but invalid and makes `GMSServices` abort when the map view is created.
  private func resolvedGoogleMapsApiKey() -> String? {
    guard let raw = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String else {
      return nil
    }
    let key = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !key.isEmpty else { return nil }
    if key.contains("$(") { return nil }
    guard key.hasPrefix("AIza"), key.count >= 35 else { return nil }
    return key
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let key = resolvedGoogleMapsApiKey() {
      GMSServices.provideAPIKey(key)
    } else {
      #if DEBUG
      assertionFailure(
        "Missing or unresolved GMSApiKey. Copy ios/Secrets.xcconfig.example to ios/Secrets.xcconfig, " +
          "set GOOGLE_MAPS_API_KEY to your iOS Maps SDK key, then clean and rebuild."
      )
      #endif
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
