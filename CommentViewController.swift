//
//  CommentViewController.swift
//  Skimddit
//
//  Created by Riyazh Dholakia on 10/26/17.
//  Copyright © 2017 Riyazh. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController, UITextViewDelegate {
    
    var commentFromUser = ""
    var post: Post!
    
    @IBOutlet weak var commentTextFromUser: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onSubmitCommentPressed(_ sender: UIBarButtonItem) {
        onCommentPost()
    }
    
    func onCommentPost() {
        if let token = token {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "oauth.reddit.com"
            components.path = "/api/comment"
            
            commentFromUser = commentTextFromUser.text
            
            let params = [
                //"api_type" : ".json",
                "text" : commentFromUser,
                "thing_id" : post.name
            ]
            
            var items: [URLQueryItem] = []
            for pair in params {
                let item = URLQueryItem(name: pair.key, value: pair.value)
                items.append(item)
            }
            
            components.queryItems = items
            
            if let url = components.url {
                var request = URLRequest(url: url)
                request.addValue("bearer \(token)", forHTTPHeaderField: "Authorization")
                request.httpMethod = "POST"
                
                print(request)
                
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let error = error {
                        print(#function, error, response!)
                    } else if let data = data, let str = String(data: data, encoding: .utf8) {
                        print(#function, str, response!)
                    }
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "MAX_IS_COOL", sender: nil)
                    }
                    
                }).resume()
            }
        }
    }
    
}
