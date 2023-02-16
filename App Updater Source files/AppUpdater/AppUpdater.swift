//
//  AppUpdater.swift
//  MyDocScan
//

import Foundation
import FirebaseRemoteConfig

class AppUpdater: NSObject{
    
    // shared
    static let shared: AppUpdater = {
        let instance = AppUpdater()
        return instance
    }()
    
    private let remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()
    private let settings = RemoteConfigSettings()
    /// Enter your app id
    private let appUrl = "https://itunes.apple.com/app/id1234567890"
    var isNotNow = false
    override init() {
        super.init()
        // Remote config for A/B Testing
        self.settings.minimumFetchInterval = 0
        self.remoteConfig.configSettings = self.settings
    }
    
    public func checkAppUpdate() {
        self.remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate { changed, error in
                    
                    let ios_update_code = Int(self.remoteConfig.configValue(forKey: FirebaseRemoteConfigKeys.ios_update_code).stringValue ?? "")
                    print("ios_update_code :- ", ios_update_code as Any)
                    
                    let ios_version = self.remoteConfig.configValue(forKey: FirebaseRemoteConfigKeys.ios_version).stringValue
                    print("ios_version :- ", ios_version as Any)

                    guard let updateType = enumAppUpdateType(rawValue: ios_update_code ?? 0), let updateVersion = ios_version else {
                        return
                    }
                    
                    var objModel: RemoteConfigModel?
                    switch updateType {
                        
                    case .No_update:
                        break
                    case .Version_updates:
                        let dialog_info = self.remoteConfig.configValue(forKey: enumAppUpdateType.Version_updates.configKey).stringValue
                        print("dialog_info :- ", dialog_info as Any)
                        objModel = dialog_info?.convertToModel()
                    case .Patch_updates:
                        let dialog_info = self.remoteConfig.configValue(forKey: enumAppUpdateType.Patch_updates.configKey).stringValue
                        print("dialog_info :- ", dialog_info as Any)
                        objModel = dialog_info?.convertToModel()
                    case .Minor_updates:
                        let dialog_info = self.remoteConfig.configValue(forKey: enumAppUpdateType.Minor_updates.configKey).stringValue
                        print("dialog_info :- ", dialog_info as Any)
                        objModel = dialog_info?.convertToModel()
                    case .Hotfix_updates:
                        let dialog_info = self.remoteConfig.configValue(forKey: enumAppUpdateType.Hotfix_updates.configKey).stringValue
                        print("dialog_info :- ", dialog_info as Any)
                        objModel = dialog_info?.convertToModel()
                    case .Major_updates:
                        let dialog_info = self.remoteConfig.configValue(forKey: enumAppUpdateType.Major_updates.configKey).stringValue
                        print("dialog_info :- ", dialog_info as Any)
                        objModel = dialog_info?.convertToModel()
                        
                    }
                    
                    guard let model = objModel, updateType != .No_update else {
                        return
                    }
                    
                    // Check current app Version
                    let info = Bundle.main.infoDictionary
                    guard let currentVersion = info?["CFBundleShortVersionString"] as? String else {
                        return
                    }
                    
                    print("Current App Version : ", currentVersion)
                    
                    if updateVersion.compare(currentVersion, options: .numeric) == .orderedDescending && self.isNotNow == false {
                        DispatchQueue.main.async {
                            self.showAlertBasedOnUpdateType(updateType: updateType, objModel: model, updateVersion: updateVersion)
                        }
                    }
                    
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    private func showAlertBasedOnUpdateType(updateType: enumAppUpdateType, objModel: RemoteConfigModel, updateVersion: String) {
        let alertTitle = objModel.title
        let alertMessage = objModel.message
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        if objModel.hideNegativeBtn == false {
            let notNowButton = UIAlertAction(title: objModel.negativeBtnText, style: .default){ (action:UIAlertAction) in
                AppUpdater.shared.isNotNow = true
            }
            alertController.addAction(notNowButton)
        }
        
        if objModel.hidePositiveBtn == false {
            let updateButton = UIAlertAction(title: objModel.positiveBtnText, style: .default) { (action:UIAlertAction) in
                guard let url = URL(string: self.appUrl) else {
                    return
                }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
            alertController.addAction(updateButton)
        }
        
        guard let topVC = UIApplication.topViewController() else {
            return
        }
        
        topVC.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - App Update Enum
enum enumAppUpdateType: Int {
    case No_update = 0
    case Version_updates = 1
    case Patch_updates = 2
    case Minor_updates = 3
    case Hotfix_updates = 4
    case Major_updates = 5
    
    var configKey: String {
        switch self {
            
        case .No_update:
            return ""
        case .Version_updates:
            return "version_update_dialog_info"
        case .Patch_updates:
            return "patch_update_dialog_info"
        case .Minor_updates:
            return "minor_update_dialog_info"
        case .Hotfix_updates:
            return "hotfix_update_dialog_info"
        case .Major_updates:
            return "force_update_dialog_info"
        }
    }
}
// MARK: - Firebase Remote ConfigKeys Constant
struct FirebaseRemoteConfigKeys {
    static let ios_update_code = "ios_update_code"
    static let ios_version = "ios_version"
}

// MARK: - RemoteConfigModel (MODEL CLASS)
struct RemoteConfigModel: Codable {
    var title: String?
    var hideNegativeBtn, hidePositiveBtn: Bool?
    var negativeBtnText, message, positiveBtnText: String?

    enum CodingKeys: String, CodingKey {
        case title
        case hideNegativeBtn = "hide_negative_btn"
        case hidePositiveBtn = "hide_positive_btn"
        case negativeBtnText = "negative_btn_text"
        case message
        case positiveBtnText = "positive_btn_text"
    }
}

extension Dictionary {
    var jsonString: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            guard let jsonString = String(bytes: jsonData, encoding: String.Encoding.utf8) else {
                return invalidJson
            }
            print(jsonString)
            return jsonString
        } catch {
            return invalidJson
        }
    }
    
    mutating func changeKey(from: Key, to: Key) -> Dictionary{
        self[to] = self[from]
        self.removeValue(forKey: from)
        return self
    }
}

extension Encodable {
    func convertToJSONString() -> String?{
        do {
            let jsonData = try JSONEncoder().encode(self)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else{
                return nil
            }
            print(jsonString)
            return jsonString == "null" ? nil : jsonString
        }catch {
            print(error)
            return nil
        }
    }
}

extension String {
    func convertToModel<T: Decodable>() -> T? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch {
            print(error)
            return nil
        }
    }
}


