//
//  ViewController.swift
//  TestSwift
//
//  Created by Jameson Quave on 6/2/14.
//  Copyright (c) 2014 JQ Software LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    @IBOutlet var appsTableView : UITableView
    var data: NSMutableData = NSMutableData()
    var tableData: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchItunesFor("Angry Birds");
    }
    
    func searchItunesFor(searchTerm: String) {
        
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        var itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        var escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=software"
        var url: NSURL = NSURL(string: urlPath)
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)
        
        println("Search iTunes API at URL \(url)")
        
        connection.start()
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        
        var rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        cell.text = rowData["trackName"] as String
        
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        var urlString: NSString = rowData["artworkUrl60"] as NSString
        var imgURL: NSURL = NSURL(string: urlString)
        
        // Download an NSData representation of the image at the URL
        var imgData: NSData = NSData(contentsOfURL: imgURL)
        cell.image = UIImage(data: imgData)
        
        // Get the formatted price string for display in the subtitle
        var formattedPrice: NSString = rowData["formattedPrice"] as NSString
        
        cell.detailTextLabel.text = formattedPrice
        
        return cell
    }
    
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        println("Connection failed.\(error.localizedDescription)")
    }
    
    func connection(connection: NSURLConnection, didRecieveResponse response: NSURLResponse)  {
        println("Recieved response")
    }
    
    
    
    
    
    
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        // Recieved a new request, clear out the data object
        self.data = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        // Append the recieved chunk of data to our data object
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        // Request complete, self.data should now hold the resulting info
        // Convert it to a string
        var dataAsString: NSString = NSString(data: self.data, encoding: NSUTF8StringEncoding)
        
        // Convert the retrieved data in to an object through JSON deserialization
        var err: NSError
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        
        if jsonResult.count>0 && jsonResult["results"].count>0 {
            var results: NSArray = jsonResult["results"] as NSArray
            self.tableData = results
            self.appsTableView.reloadData()
            
        }
        
    }
    
}