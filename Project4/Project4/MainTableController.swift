//
//  MainTableController.swift
//  Project4
//
//  Created by Meitar Basson on 16/09/2024.
//

import UIKit

class MainTableController: UITableViewController {
    
    var websites = ["apple.com", "hackingwithswift.com", "google.com", "chess.com",
                    "snowball-analytics.com", "chatgpt.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Favorite Websites"
    }

    // UITableViewController Implementation
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkCell", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "WebsitePage") as? ViewController {
            vc.websites = websites
            vc.chosenWebsite = websites[indexPath.row]
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }


}
