//
//  Auth.swift
//  Skimddit
//
//  Created by Riyazh Dholakia on 10/23/17.
//  Copyright © 2017 Riyazh. All rights reserved.
//

import Foundation

let clientID = "oyhQ3y8pu_dI2w"
let redirect = "skimddit://login/"

var token: String? {
    return UserDefaults.standard.string(forKey: "Token")
}

var oauth: URL? {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "www.reddit.com"
    components.path = "/api/v1/authorize.compact"
    
    //https://www.reddit.com/api/v1/authorize?client_id=CLIENT_ID&response_type=TYPE&state=RANDOM_STRING&redirect_uri=URI&duration=DURATION&scope=SCOPE_STRING // this is what we referenced for the components
    
    let params = [
        "client_id" : clientID,
        "response_type" : "token",
        "state" : UUID().uuidString,
        "redirect_uri" : redirect,
        "scope" : "mysubreddits,read,subscribe,vote,submit",
    ]
    
    var items: [URLQueryItem] = []
    for pair in params {
        let item = URLQueryItem(name: pair.key, value: pair.value)
        items.append(item)
    }
    
    components.queryItems = items
    return components.url
}
