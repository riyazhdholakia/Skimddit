//
//  FavoritesViewController.swift
//  Skimddit
//
//  Created by Riyazh Dholakia on 10/18/17.
//  Copyright © 2017 Riyazh. All rights reserved.
//

import UIKit

class FavoritesViewController: UITableViewController {
    var favReddits: [RedditPage] = []
    var currentPage = RedditPage.frontPage(.hot)
    var userFavSelected: RedditPage?
    var filters: [Filter] = [.hot, .new, .rising, .controversial, .top]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: loginNotificationCenterName, object: nil, queue: .main) { (_) in
            requestSubscriptions { (result) in
                switch result {
                case .success(let subsribePages):
                    self.favReddits = subsribePages
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                case .failure(let error):
                    print(error)
                }
            }
        }
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        UIApplication.shared.open(oauth!)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return favReddits.count
        } else {
            return filters.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "B", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = "r/" + favReddits[indexPath.row].title
            return cell
        } else {
            cell.textLabel?.text = currentPage.subredditName + "/" + filters[indexPath.row].rawValue
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            userFavSelected = favReddits[indexPath.row]
            performSegue(withIdentifier: "UnWindFavVC", sender: self)
        } else {
            switch currentPage {
            case .frontPage(_):
                userFavSelected = RedditPage.frontPage(filters[indexPath.row])
            case .subreddit(let name, _):
                userFavSelected = RedditPage.subreddit(name, filters[indexPath.row])
            }
            performSegue(withIdentifier: "UnWindFavVC", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Filters"
        } else {
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        favReddits.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
