//
//  API.swfit.swift
//  Skimddit
//
//  Created by Riyazh Dholakia on 10/25/17.
//  Copyright © 2017 Riyazh. All rights reserved.
//

import UIKit

enum Result<T> { //T can be anything its just a placeholder for example you can use foo or Ll #anything
    case success(T)
    case failure(Error)
}


func requestSubscriptions(completion: @escaping (Result<[RedditPage]>) -> Void) {
    if let token = token {
        let newUrl = "https://oauth.reddit.com/subreddits/mine/subscriber"
        let url = URL(string: newUrl)!
        var request = URLRequest(url: url)
        request.addValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                if let data = data {
                    let listing = try JSONDecoder().decode(SubscriptionListing.self, from: data)
                    
                    var subs = [String]()
                    for child in listing.data.children {
                        subs.append(child.data.display_name)
                    }
                    
                    var favorites: [RedditPage] = []
                    for subscription in subs {
                        favorites.append(.subreddit(subscription, .hot))
                    }
                    
                    DispatchQueue.main.async {
                        completion(.success(favorites))
                    }
                    
                } else {
                    throw error!
                }
            } catch {
                completion(.failure(error))
            }
            }.resume()
    }
}

func updateSubscription(sub: String, name: String, completion: @escaping (Result<Void>) -> Void) {
    if let token = token {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "oauth.reddit.com"
        components.path = "/api/subscribe"
        
        let params = [
            "action" : sub,
            //"skip_initial_defaults" : "true",
            "sr_name" : name,
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
                    print("FOOOO", error, response!)
                } else if let data = data, let str = String(data: data, encoding: .utf8) {
                    print("FOOOO", str, response!)
                }
                DispatchQueue.main.async {
                    completion(.success(()))
                }
                
            }).resume()
        }
    }
}

func updateVote(dir: String, post: Post, completion: @escaping (Result<Void>) -> Void) {
    if let token = token {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "oauth.reddit.com"
        components.path = "/api/vote"
        
        let params = [
            "dir" : String(dir),
            "id" : post.name
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
                    print("FOOOO", error, response!)
                } else if let data = data, let str = String(data: data, encoding: .utf8) {
                    print("FOOOO", str, response!)
                }
                DispatchQueue.main.async {
                    completion(.success(()))
                }
                
            }).resume()
        }
    }
}

//func fetchComments(post: Post, completion: @escaping (Result<Void>) -> Void) {
//    if let token = token {
//        let urlString = "https://www.reddit.com/" + post.permalink + ".json"
//        let url = URL(string: urlString)!
//        var comments: [Comment] = []
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            do {
//                if let data = data {
//                    let listings = try JSONDecoder().decode([CommentListing].self, from: data)
//                    for child in listings[1].data.children {
//                        comments.append(child.data)
//                    }
//                    DispatchQueue.main.async {
//                        completion(.success(()))
//                    }
//                } else {
//                    throw error!
//                }
//            } catch {
//                print(error)
//            }
//            }.resume()
//    }
//}

