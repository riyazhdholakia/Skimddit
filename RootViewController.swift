//
//  RootViewController.swift
//  Skimddit
//
//  Created by Riyazh Dholakia on 10/16/17.
//  Copyright © 2017 Riyazh. All rights reserved.
//

import UIKit
import SafariServices

class RootViewController: UITableViewController, UISearchBarDelegate {
    
    var posts: [Post] = []
    var currentPage = RedditPage.frontPage(.hot) //or var currentPage: RedditPage = frontPage
    var favRedditPages: [RedditPage] = []
    @IBOutlet weak var favButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = currentPage.title
        goTo(currentPage)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let restoredFavs = UserDefaults.standard.value(forKey: "Favorites") as? [String] {
            for title in restoredFavs {
                
                // "Front Page/hot" => ["Front Page", "hot"]
                // "Cats/rising" => ["Cats", "rising"]
                
                let parts = title.split(separator: "/")
                let page = parts[0]
                if parts.count >= 2 {
                    if let filter = Filter(rawValue: String(parts[1])) {
                        if page == "Front Page" {
                            favRedditPages.append(.frontPage(filter))
                        } else {
                            favRedditPages.append(.subreddit(String(page), filter))
                        }
                    }
                }
                //remove from array
            }
        }
        
        NotificationCenter.default.addObserver(forName: loginNotificationCenterName, object: nil, queue: .main) { (_) in
        }
        
        requestSubscriptions { (result) in
            switch result {
            case .success(let subscribePages):
                self.favRedditPages = subscribePages
                self.refreshControl?.endRefreshing()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func onFavButtonPressed(_ sender: UIButton) {
        //let action = favButton.isSelected ? "unsub" : "sub"
        //or you can do it like the line above
        let action: String
        if favButton.isSelected {
            action = "unsub"
        } else {
            action = "sub"
        }
        let name = currentPage.subredditName
        
        updateSubscription(sub: action, name: name) { _ in }
        
        favButton.isSelected = !favButton.isSelected
    }
    
    @IBAction func onRefreshPulled(_ sender: UIRefreshControl) {
        goTo(currentPage)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController {
            if let favoritesVC = navController.childViewControllers.first as? FavoritesViewController {
                favoritesVC.favReddits = favRedditPages
                favoritesVC.currentPage = currentPage
            }
        }
            
        else if let commentsVC = segue.destination as? CommentsTableViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                commentsVC.post = posts[indexPath.row]
            }
        }
    }
    
    @IBAction func unWindFromFavortiesVC(segue: UIStoryboardSegue) {
        let favoritesVC = segue.source as! FavoritesViewController
        if let selectedPage = favoritesVC.userFavSelected {
            goTo(selectedPage)
        }
    }
    
    func goTo(_ page: RedditPage) {
        currentPage = page
        title = currentPage.title
        URLSession.shared.dataTask(with: page.request, completionHandler: onRedditDownloaded).resume()
        favButton.isSelected = favRedditPages.contains(currentPage)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {        
        if let userText = searchBar.text, userText != "" {
            goTo(.subreddit(userText, .hot))
        } else {
            goTo(.frontPage(.hot))
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func onRedditDownloaded(data: Data?, response: URLResponse?, error: Error?) {
        if let data = data, let listing = try? JSONDecoder().decode(Listing.self, from: data) {
            posts = []
            for child in listing.data.children {
                let post = child.data
                posts.append(post)
                
                let imageUrl = post.thumbnail
                
                URLSession.shared.dataTask(with: imageUrl, completionHandler: { (data, response, error) in
                    post.imageData = data
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }).resume()
            }
        } else {
            print(error)
        }
        
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "A", for: indexPath)
        let post = posts[indexPath.row]
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = post.subreddit
        cell.imageView?.image = post.image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CommentTableVC", sender: self)
    }
}
