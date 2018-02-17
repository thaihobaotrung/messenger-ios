//
//  ReceivedImageTableViewCell.swift
//  Pulse
//
//  Created by Luke Klinker on 1/6/18.
//  Copyright © 2018 Luke Klinker. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class ReceivedImageTableViewCell : MessageTableViewCell {
    
    @IBOutlet weak var message: UIImageView!
    
    override func bind(conversation: Conversation, message: Message) {
        super.bind(conversation: conversation, message: message)
        
        var url = URL(string: "https://api.messenger.klinkerapps.com/api/v1/media/\(message.id)?account_id=\(Account.accountId!)")!
        if message.mimeType == MimeType.MEDIA_MAP {
            if let dataFromString = message.data.data(using: .utf8, allowLossyConversion: false) {
                do {
                    let json = try JSON(data: dataFromString)
                    url = URL(string: handleMap(json: json))!
                } catch { }
            }
        }
        
        self.message.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        
        self.messageContainer.backgroundColor = UIColor(rgb: conversation.color)
        self.message.backgroundColor = UIColor(rgb: conversation.color)
        
        if conversation.isGroup() && message.sender != nil {
            self.timestamp.text = "\(self.timestamp.text!) - \(message.sender!)"
        }
    }
    
    private func handleMap(json: JSON) -> String {
        let lat =  json["latitude"].string!
        let long = json["longitude"].string!
        let url = "https://maps.googleapis.com/maps/api/staticmap" +
            "?size=600x400" +
            "&markers=color:red%7C\(lat),\(long)" +
            "&key=AIzaSyAHq1IIIdGz01rEbEtUtDwEFJWwvAI_lww"
        
        return url
    }
    
}
