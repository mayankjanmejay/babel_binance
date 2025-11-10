import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let nativeChannel = FlutterMethodChannel(name: "com.babel.binance/native",
                                                  binaryMessenger: controller.binaryMessenger)

        nativeChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }

            switch call.method {
            case "getBatteryLevel":
                self.getBatteryLevel(result: result)
            case "getDeviceInfo":
                self.getDeviceInfo(result: result)
            case "hapticFeedback":
                if let args = call.arguments as? [String: Any],
                   let type = args["type"] as? String {
                    self.triggerHapticFeedback(type: type)
                }
                result(nil)
            case "shareContent":
                if let args = call.arguments as? [String: Any],
                   let text = args["text"] as? String {
                    let subject = args["subject"] as? String
                    self.shareContent(text: text, subject: subject, controller: controller)
                }
                result(true)
            case "openSettings":
                if let args = call.arguments as? [String: Any],
                   let section = args["section"] as? String {
                    self.openSettings(section: section)
                }
                result(nil)
            case "isAppInBackground":
                result(UIApplication.shared.applicationState == .background)
            case "getScreenBrightness":
                result(UIScreen.main.brightness)
            case "setScreenBrightness":
                if let args = call.arguments as? [String: Any],
                   let brightness = args["brightness"] as? Double {
                    UIScreen.main.brightness = CGFloat(brightness)
                }
                result(nil)
            case "copyToClipboard":
                if let args = call.arguments as? [String: Any],
                   let text = args["text"] as? String {
                    UIPasteboard.general.string = text
                }
                result(nil)
            case "getClipboardContent":
                result(UIPasteboard.general.string)
            case "isDeviceRooted":
                result(self.isDeviceJailbroken())
            case "getAppVersion":
                result(self.getAppVersion())
            default:
                result(FlutterMethodNotImplemented)
            }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func getBatteryLevel(result: FlutterResult) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        if batteryLevel < 0 {
            result(FlutterError(code: "UNAVAILABLE",
                              message: "Battery level not available",
                              details: nil))
        } else {
            result(Int(batteryLevel * 100))
        }
    }

    private func getDeviceInfo(result: FlutterResult) {
        let device = UIDevice.current
        let deviceInfo: [String: Any] = [
            "model": device.model,
            "systemName": device.systemName,
            "systemVersion": device.systemVersion,
            "name": device.name,
            "identifierForVendor": device.identifierForVendor?.uuidString ?? "unknown"
        ]
        result(deviceInfo)
    }

    private func triggerHapticFeedback(type: String) {
        switch type {
        case "light":
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case "medium":
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case "heavy":
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case "success":
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case "warning":
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        case "error":
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        default:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }

    private func shareContent(text: String, subject: String?, controller: UIViewController) {
        var itemsToShare: [Any] = [text]
        if let subject = subject {
            itemsToShare.insert(subject, at: 0)
        }

        let activityViewController = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: nil
        )

        controller.present(activityViewController, animated: true, completion: nil)
    }

    private func openSettings(section: String?) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func isDeviceJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let fileManager = FileManager.default
        let paths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]

        for path in paths {
            if fileManager.fileExists(atPath: path) {
                return true
            }
        }

        // Try to write to system directory
        let testPath = "/private/jailbreak_test.txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try fileManager.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
        #endif
    }

    private func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0.0"
    }
}
