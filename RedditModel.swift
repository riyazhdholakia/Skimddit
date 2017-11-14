//
//  RedditModel.swift
//  Skimddit
//
//  Created by Riyazh Dholakia on 10/16/17.
//  Copyright © 2017 Riyazh. All rights reserved.
//

import UIKit

class Listing: Decodable {
    let data: Data
    
    class Data: Decodable {
        let children: [Child]
        
        class Child: Decodable {
            let data: Post
        }
    }
}

class Post: Decodable {
    let subreddit: String
    let title: String
    let permalink: String
    var thumbnail: URL
    var imageData: Data?
    var selftext: String
    var is_self: Bool
    var name: String
    var likes: Bool?
    
    var image: UIImage? {
        if let imageData = imageData {
            return UIImage(data: imageData)
        }
        return nil
    }
}

class CommentListing: Decodable {
    let data: Data
    
    class Data: Decodable {
        let children: [Child]
        
        class Child: Decodable {
            let data: Comment
        }
    }
}

class Comment: Decodable {
    let body: String?
    let score: Int?
    let author: String?
}

class SubscriptionListing: Decodable {
    let data: Data
    
    class Data: Decodable {
        let children: [Child]
        
        class Child: Decodable {
            let data: Subscription
        }
    }
}

class Subscription: Decodable {
    let display_name: String
}

enum RedditPage: Equatable {
    case frontPage(Filter)
    case subreddit(String, Filter)
    
    var url: URL {
        let base: String
        if token != nil {
            base = "https://oauth.reddit.com/"
        } else {
            base = "https://www.reddit.com/"
        }
        let suffix = ".json"
        
        switch self {
        case .frontPage(let filter):
            return URL(string: base + filter.rawValue + suffix)!
        case .subreddit(let name, let filter):
            return URL(string: base + "r/" + name + "/" + filter.rawValue + suffix )!
        }
    }
    
    var request: URLRequest {
        var request = URLRequest(url: url)
        if let token = token {
            request.addValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    var title: String {
        switch self {
        case .frontPage(let filter):
            return "Front Page" + "/" + filter.rawValue
        case .subreddit(let name, let filter):
            return name + "/" + filter.rawValue
        }
    }
    
    var subredditName: String {
        switch self {
        case .frontPage(_):
            return "Front Page"
        case .subreddit(let name, _):
            return name
        }
    }
    
    static func ==(lhs: RedditPage, rhs: RedditPage) -> Bool {
        return lhs.title == rhs.title
    }
}

enum Filter: String {
    case hot
    case new
    case rising
    case controversial
    case top
}










