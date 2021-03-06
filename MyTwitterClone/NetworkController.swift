//
//  NetworkController.swift
//  MyTwitterClone
//
//  Created by Randall Leung on 10/8/14.
//  Copyright (c) 2014 Randall. All rights reserved.
//

import Foundation
import Accounts
import Social

class NetworkController {
    
    var twitterAccount: ACAccount?
    let imageQueue = NSOperationQueue()
    //var cachedImage = [String:UIImage]()
    var imageCache = NSCache()
    
    init() {
        self.imageQueue.maxConcurrentOperationCount = 10
    }
    
    //Fetch is to download, fetching to the network now
    func fetchHomeTimeLine( sinceId: String?, maxId: String?, completionHandler: (errorDescription: String?, tweets: [Tweet]?)-> (Void)) {
        
        let accountStore = ACAccountStore()
        //Want account type of Twitter
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error: NSError!) -> Void in
            //If granted, set the Account to the SLRequest
            if granted {
                let accounts = accountStore.accountsWithAccountType(accountType)
                self.twitterAccount = accounts.first as! ACAccount?
                let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
                
                var twitterRequest : SLRequest!
                
                if sinceId != nil && maxId == nil {
                    twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: ["since_id": sinceId!])
                } else if maxId != nil && sinceId == nil {
                    twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: ["max_id": maxId!])
                } else {
                    twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil)
                }
                
                twitterRequest.account = self.twitterAccount
                
                //Also becomes a background thread here
                twitterRequest.performRequestWithHandler({ (data, httpResponse, error) -> Void in
                    
                    switch httpResponse.statusCode {
                    case 200...299:
                        print("This is good!")
                        //Right here, we are on a background queue (thread).
                        //Never do network calls in the main queue.  Social framework takes care of this automatically.
                        let tweets = Tweet.parseJSONDataIntoTweets(data)
                        print(tweets?.count)
                        //Need to return back to main thread through.  Now getting back on the main quene.
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            //self.tableView.reloadData()
                            
                            //Instead, now we call on the compeletion handler
                            completionHandler(errorDescription: nil, tweets: tweets)
                        })
                        //Now we are back on the main queue, aka thread
                        
                        
                    case 400...499:
                        print("This is the clients fault")
                        print(httpResponse.description)
                        completionHandler(errorDescription: "This is the clients fault", tweets: nil)
                    case 500...599:
                        print("This is the servers fault")
                        completionHandler(errorDescription: "This is the servers fault", tweets: nil)
                    default:
                        print("Something bad happened")
                    }
                })
                
            }
        }

        
    }
    
    
    //Making the network call to fetch profile picture
    func downloadUserImageForTweet(tweet: Tweet, completionHandler: (image: UIImage)->(Void)) {
        self.imageQueue.addOperationWithBlock { () -> Void in
            //Caching the image
            var avatarImage: UIImage?
            //Retrieving the value associated with the tweet.avatarURL
            let data:NSData? = self.imageCache.objectForKey(tweet.avatarURL) as? NSData
            
            //If the image is already cached...
            if let cachedImageData = data {
                avatarImage = UIImage(data: cachedImageData)
            } else {
                //If the image is not yet cached...
                let url = NSURL(string: tweet.avatarURL)
                //Network call
                let imageData = NSData(contentsOfURL: url!)
                avatarImage = UIImage(data: imageData!)
                //Setting imageData: NSData, as the value for the key tweet.avatarURL
                self.imageCache.setObject(imageData!, forKey: tweet.avatarURL)
            }
            tweet.avatarImage = avatarImage
            
            //Return back to main thread
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                completionHandler(image: avatarImage!)
            }
            //let url = NSURL(string: tweet.avatarURL)
            //Network Call
            //let imageData = NSData(contentsOfURL: url)
            //let avatarImage = UIImage(data: imageData)
            //tweet.avatarImage = avatarImage
            //NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
              //  completionHandler(image: avatarImage)
            //}
        }
        
    }
    
    //Making a network to get favorite Tweets
    func fetchSingleTweet ( tweet: Tweet, completionHandler: (errorDescription: String?, tweet: Tweet?)-> (Void)) {
        
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/show.json?id="+tweet.id)
        let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil)
        twitterRequest.account = self.twitterAccount

        twitterRequest.performRequestWithHandler { (data, httpResponse, error) -> Void in
            switch httpResponse.statusCode {
            case 200...299:
                print("This is good!")
                let tweetInfo = Tweet.paraseJSONDataIntoSingleTweet(data, tweet: tweet)

                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    completionHandler(errorDescription: nil, tweet: tweetInfo)
                })
                
            case 400...499:
                print("This is the clients fault")
                print(httpResponse.description)
                completionHandler(errorDescription: "This is the clients fault", tweet: nil)
            case 500...599:
                print("This is the servers fault")
                completionHandler(errorDescription: "This is the servers fault", tweet: nil)
            default:
                print("Something bad happened")
            }
        }
        
    }
    
    //Making a network call for the user Timeline
    func fetchUserTimeLine ( tweet: Tweet?, sinceId: String?, maxId: String?, completionHandler: (errorDescription: String?, tweets: [Tweet]?)->(Void)) {
        
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=\(tweet!.screenName)")
        
        var twitterRequest : SLRequest!
        
        if sinceId != nil && maxId == nil {
            twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: ["since_id": sinceId!])
        } else if maxId != nil && sinceId == nil {
            twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: ["max_id": maxId!])
        } else {
            twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil)
        }
        
        twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil)
        twitterRequest.account = self.twitterAccount
        
        twitterRequest.performRequestWithHandler { (data, httpResponse, error) -> Void in
            switch httpResponse.statusCode {
            case 200...299:
                print("This is good!")
                //Need to parse JSON now.
                let tweets = Tweet.parseJSONDataIntoTweets(data)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    completionHandler(errorDescription: nil, tweets: tweets)
                })
                
            case 400...499:
                print("This is the clients fault")
                print(httpResponse.description)
                completionHandler(errorDescription: "This is the clients fault", tweets: nil)
            case 500...599:
                print("This is the servers fault")
                completionHandler(errorDescription: "This is the servers fault", tweets: nil)
            default:
                print("Something bad happened")
            }
        }
        
    }
    
    
    
    
}