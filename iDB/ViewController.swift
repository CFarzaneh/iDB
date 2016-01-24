//
//  ViewController.swift
//  iDB
//
//  Created by Cameron Farzaneh on 12/13/15.
//  Copyright © 2015 Cameron Farzaneh. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UITableViewDelegate, SFSafariViewControllerDelegate, UITableViewDataSource, FeedParserDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var parser: FeedParser?
    var entries: [FeedItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entries = []
            self.parser = FeedParser(feedURL: "http://www.idownloadblog.com/feed/")
            self.parser?.delegate = self
            self.parser?.parse()

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries?.count ?? 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("FeedItemCell", forIndexPath: indexPath) as UITableViewCell
        let item = entries![indexPath.row]
        

            cell.textLabel?.text = item.feedTitle
            //print(item.imageURLsFromDescription)
            cell.detailTextLabel?.text = item.feedContentSnippet ?? item.feedContent?.stringByDecodingHTMLEntities() ?? ""
        
        cell.textLabel!.numberOfLines = 2

        return cell
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if let feedItem = entries?[indexPath.row] {
            if let url = NSURL(string: feedItem.feedLink ?? "") {
                let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
                vc.delegate = self
                
                presentViewController(vc, animated: true, completion: nil)
            }
        }
        
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - FeedParserDelegate methods
    
    func feedParser(parser: FeedParser, didParseChannel channel: FeedChannel) {
        // Here you could react to the FeedParser identifying a feed channel.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("Feed parser did parse channel \(channel)")
        })
    }
    
    func feedParser(parser: FeedParser, didParseItem item: FeedItem) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("Feed parser did parse item \(item.feedTitle)")
            self.entries?.append(item)
        })
    }
    
    func feedParser(parser: FeedParser, successfullyParsedURL url: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (self.entries?.count > 0) {
                print("All feeds parsed.")
                self.tableView.hidden = false
                self.tableView.reloadData()
            } else {
                print("No feeds found at url \(url).")
                self.tableView.hidden = true
            }
        })
    }
    
    func feedParser(parser: FeedParser, parsingFailedReason reason: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("Feed parsed failed: \(reason)")
            self.entries = []
            self.tableView.hidden = true
        })
    }
    
    func feedParserParsingAborted(parser: FeedParser) {
        print("Feed parsing aborted by the user")
        self.entries = []
        self.tableView.hidden = true
    }
    
    // MARK: - Network methods
    func loadImageSynchronouslyFromURLString(urlString: String) -> UIImage? {
        if let url = NSURL(string: urlString) {
            let request = NSMutableURLRequest(URL: url)
            request.timeoutInterval = 30.0
            var response: NSURLResponse?
            let error: NSErrorPointer = nil
            var data: NSData?
            do {
                data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            } catch let error1 as NSError {
                error.memory = error1
                data = nil
            }
            if (data != nil) {
                return UIImage(data: data!)
            }
        }
        return nil
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

