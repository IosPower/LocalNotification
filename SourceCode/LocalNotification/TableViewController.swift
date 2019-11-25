//
//  TableViewController.swift
//  LocalNotification
//
//  Created by Piyush Sinroja on 25/11/19.
//  Copyright © 2019 Piyush. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    // MARK: - Variables
    
    let notifications = ["Local Notificationb Test"]
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    // MARK: - View Controller Life Cycles
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Table view data source
    
    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = notifications[indexPath.row]
        return cell
    }
    
    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notificationType = notifications[indexPath.row]
        let alert = UIAlertController(title: "",
                                      message: "After 5 seconds " + notificationType + " will appear",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.appDelegate?.scheduleNotification(notificationType: notificationType, timer: 5)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func stopNotification(_ sender: AnyObject) {
        print("Removed all pending notifications")
        guard let requestIdentifier =  appDelegate?.requestIdentifier else {
            return
        }
        appDelegate?.notificationCenter.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
    }
}
