//
//  CommentsTableViewController.swift
//  Skimddit
//
//  Created by Riyazh Dholakia on 10/19/17.
//  Copyright © 2017 Riyazh. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController {
    
    var comments: [Comment] = []
    var post: Post!
    var commentFromUser = ""
    
    @IBOutlet weak var upvoteOutlet: UIButton!
    @IBOutlet weak var downvoteOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        let urlString = "https://www.reddit.com/" + post.permalink + ".json"
        let url = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            do {
                if let data = data {
                    let listings = try JSONDecoder().decode([CommentListing].self, from: data)
                    for child in listings[1].data.children {
                        self.comments.append(child.data)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    throw error!
                }
            } catch {
                print(error)
            }
            }.resume()
        
//        fetchComments(post: self.post) { (result) in
//            switch result {
//            case .success(let newComments):
//                self.comments = newComments
//                self.tableView.reloadData()
//                self.refreshControl?.endRefreshing()
//            case .failure(let error):
//                print(error)
//            }
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if post.likes == true {
            upvoteOutlet.isSelected = true
        } else if post.likes == false {
            downvoteOutlet.isSelected = true
        } else {
            upvoteOutlet.isSelected = false
            downvoteOutlet.isSelected = false
        }
    }
    
    @IBAction func onUpvotePressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if upvoteOutlet.isSelected {
            downvoteOutlet.isSelected = false
        }
        
        var dir: Int
        if upvoteOutlet.isSelected {
            dir = 1
        } else {
            dir = 0
        }
        updateVote(dir: String(dir), post: self.post, completion: { (result) in
            switch result {
            case .success():
                break
            case .failure(let error):
                print(error)
            }
        })
    }
    
    @IBAction func onDownvotePressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if downvoteOutlet.isSelected {
            upvoteOutlet.isSelected = false
        }
        
        var dir: Int
        if downvoteOutlet.isSelected {
            dir = -1
        } else {
            dir = 0
        }
        updateVote(dir: String(dir), post: self.post, completion: { (result) in
            switch result {
            case .success():
                break
            case .failure(let error):
                print(error)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let commentVC = segue.destination as? CommentViewController {
            commentVC.post = post
        }
    }
    
    @IBAction func unwindCommentVC(segue: UIStoryboardSegue){
        let commentVC = segue.source as! CommentViewController
        commentFromUser = commentVC.commentFromUser
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return comments.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Top Comments"
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if post.is_self {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelfTextCell", for: indexPath)
                cell.textLabel?.text = post.title
                cell.detailTextLabel?.text = post.selftext
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "D", for: indexPath)
                cell.textLabel?.text = post.title
                cell.imageView?.image = post.image
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "C", for: indexPath) as! CommentsCell
            cell.userNameLabel.text = "u/" + (comments[indexPath.item].author ?? "mxcl")
            cell.scoreLabel.text = String(comments[indexPath.item].score ?? 0)
            cell.bodyLabel.text = comments[indexPath.row].body
            return cell
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}
