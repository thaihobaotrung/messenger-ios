//
//  ConversationTableViewController.swift
//  Pulse
//
//  Created by Luke Klinker on 1/2/18.
//  Copyright © 2018 Luke Klinker. All rights reserved.
//

import UIKit
import Alamofire

class ConversationTableViewController: UITableViewController {
    
    // MARK: Properties
    let sectionHeaderHeight: CGFloat = 32
    var sections = [ConversationSectionType]()

    override func viewDidLoad() {
        super.viewDidLoad()

        DataProvider.conversations { conversations in
            let section = ConversationSectionType(type: .pinned)
            section.conversations += conversations
            
            self.sections.append(section)
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].conversationCount()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sections[section].conversationCount() > 0 {
            return sectionHeaderHeight
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: sectionHeaderHeight))
        view.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: sectionHeaderHeight))
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.black
        
        switch sections[section].type {
        case .pinned:
            label.text = "Pinned"
        case .today:
            label.text = "Today"
        case .yesterday:
            label.text = "Yesterday"
        case .lastWeek:
            label.text = "Last Week"
        case . lastMonth:
            label.text = "Last Month"
        default:
            label.text = "Older"
        }
        
        view.addSubview(label)
        return view
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationTableViewCell", for: indexPath) as? ConversationTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ConversationTableViewCell.")
        }

        let conversation = sections[indexPath.section].conversations[indexPath.row]
        
        cell.title.text = conversation.title
        cell.snippet.text = conversation.snippet
        cell.conversationImage.backgroundColor = UIColor(rgb: conversation.color)
        cell.conversationImage.maskCircle()

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}