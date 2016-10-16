//
//  Tweet.swift
//  MyTwitterClone
//
//  Created by Randall Leung on 10/6/14.
//  Copyright (c) 2014 Randall. All rights reserved.
//

import UIKit

class Tweet {
    var text: String
    var username: String
    var screenName: String
    var avatarURL: String
    var avatarImage: UIImage?
    var retweet: Int
    var id: String
    var favorited: Int?
    var userId: String

    
    init(tweetInfo: NSDictionary) {
        self.text = tweetInfo["text"] as! String
        let userInfo = tweetInfo["user"] as! NSDictionary
        //For username
        self.username = userInfo["name"] as! String
        //For screenname
        self.screenName = userInfo["screen_name"] as! String
        //For image
        self.avatarURL = userInfo["profile_image_url"] as! String
        //For retweet
        self.retweet = tweetInfo["retweet_count"] as! Int
        //For id
        self.id = tweetInfo["id_str"] as! String
        self.userId = userInfo["id_str"] as! String
    }
    
    
    // Method
    class func parseJSONDataIntoTweets(rawJSONData: NSData) throws -> [Tweet]? {
        var error: NSError?
        if let JSONArray = (try? NSJSONSerialization.JSONObjectWithData(rawJSONData, options: [])) as? NSArray{
            var tweets = [Tweet]()
            
            for JSONDictionary in JSONArray {
                if let tweetDictionary = JSONDictionary as? NSDictionary {
                    let newTweet = Tweet(tweetInfo: tweetDictionary)
                    tweets.append(newTweet)
                }
            }
            
            //Sorting with Closures
            //tweets.sort{$1.text > $0.text}
            return tweets
        }
        return nil
    }
    
    
    class func paraseJSONDataIntoSingleTweet(rawJSONData: NSData, tweet: Tweet) throws -> Tweet{
        var error: NSError?

        if let tweetDictionary = try NSJSONSerialization.JSONObjectWithData(rawJSONData, options: []) as? NSDictionary {
            tweet.favorited = tweetDictionary["favorite_count"] as? Int
            }
            return tweet

    }
    
}




