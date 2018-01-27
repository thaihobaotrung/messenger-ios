//
//  FcmHandler.swift
//  Pulse
//
//  Created by Luke Klinker on 1/11/18.
//  Copyright © 2018 Luke Klinker. All rights reserved.
//

import Foundation
import SwiftyJSON
import UserNotifications

let FcmHandler = _FcmHandler()

class _FcmHandler {
    
    private var appForegroundedTime = Date().millisecondsSince1970
    
    func handle(operation: String, json: JSON) {
        if shouldIgnoreFcmMessage() {
            return
        }
        
        switch operation {
        case "added_message":           addedMessage(json: json)
        case "read_conversation":       readConversation(json: json)
        case "added_conversation":      invalidateConversationList()
        case "removed_conversation":    invalidateConversationList()
        case "archive_conversation":    invalidateConversationList()
        case "dismissed_notification":  dismissNotification(json: json)
        case "show_notification":       showNotification(json: json)
        default:                        throwAway(operation: operation, json: json)
        }
    }
    
    func notifyAppForegrounded() {
        self.appForegroundedTime = Date().millisecondsSince1970
    }
    
    //
    // We throw out FCM messages that come in immediately when the app is opened. The amount
    // and content of those messages can be unpredicatable, so we handle app changes outside of FCM
    // by checking the conversation list in the AppOpenedUpdateHelper.
    // The logic here could obviously be improved. On slow data connections, it could take longer
    // than 3 seconds to receive the missed messages, while it takes much less than that, typically,
    // on my WiFi connection.
    //
    private func shouldIgnoreFcmMessage() -> Bool {
        if Date().millisecondsSince1970 - appForegroundedTime < 3000 {
            return true
        } else {
            return false
        }
    }
    
    private func addedMessage(json: JSON) {
        let message = Message(json: json)
        debugPrint("added message: \(message.description)")
        
        if (json["sent_device"].stringValue != Account.deviceId!) {
            DataProvider.addMessage(conversationId: Int64(json["conversation_id"].stringValue)!, message: message)
        }
    }
    
    private func invalidateConversationList() {
        debugPrint("invalidate conversation list")
        
        DataProvider.clear()
        DataProvider.loadConversations()
    }
    
    private func readConversation(json: JSON) {
        debugPrint("read conversation: \(json["id"])")
        
        DataProvider.markAsRead(conversationId: Int64(json["id"].stringValue)!)
    }
    
    private func dismissNotification(json: JSON) {
        debugPrint("dismiss notifications. From device: \(json["device_id"].stringValue)")
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func showNotification(json: JSON) {
        debugPrint("show notification")
        
        let notification = UNMutableNotificationContent()
        notification.title = Account.encryptionUtils!.decrypt(data: json["title"].stringValue)!
        notification.body = Account.encryptionUtils!.decrypt(data: json["snippet"].stringValue)!
        notification.sound = UNNotificationSound.default()
        
        let identifier = json["conversation_id"].stringValue
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request)
        
        if let count = Int(json["badge"].stringValue) {
            UIApplication.shared.applicationIconBadgeNumber = count
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    private func throwAway(operation: String, json: JSON) {
        
    }
}
