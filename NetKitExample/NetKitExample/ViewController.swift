//
//  ViewController.swift
//  NetKitExample
//
//  Created by Aziz Uysal on 2/17/16.
//  Copyright © 2016 Aziz Uysal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: DownloadService.FileDownloaded), object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: GlobalWeatherService.ReceivedWeather), object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: GlobalWeatherService.ReceivedCities), object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ServiceWithDelegate.CommentsDownloaded), object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: JsonService.PostsDownloaded), object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: JsonService.PostsCreated), object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: JsonService.PostsUpdated), object: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(postsDownloaded(_:)), name: NSNotification.Name(rawValue: JsonService.PostsDownloaded), object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(postsCreated(_:)), name: NSNotification.Name(rawValue: JsonService.PostsCreated), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(postsUpdated(_:)), name: NSNotification.Name(rawValue: JsonService.PostsUpdated), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(commentsDownloaded(_:)), name: NSNotification.Name(rawValue: ServiceWithDelegate.CommentsDownloaded), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(receivedCities(_:)), name: NSNotification.Name(rawValue: GlobalWeatherService.ReceivedCities), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(receivedWeather(_:)), name: NSNotification.Name(rawValue: GlobalWeatherService.ReceivedWeather), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(fileDownloaded(_:)), name: NSNotification.Name(rawValue: DownloadService.FileDownloaded), object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Important: use json-server with following options, otherwise below steps will not execute as expected
    // json-server --delay 2000 --watch db.json
    
    // This will timeout as the sync method has a timeout value of 1 second.
    let json = ServiceController.getPostsSync()
    print("waiting")
    print(json)
    
    print("starting async methods")

    // This will execute and finish before weather service even though it is delayed 2 seconds
    // If you change resumeAndWait() to resume(), it will start execution before weather call, but weather call will finish earlier.
    ServiceController.getPosts()
    
    let post1 = Post()
    post1.id = 2
    post1.title = "TEST CREATE"
    post1.author = "netkit"
    ServiceController.addPost(post1)
    
    let post2 = Post()
    post2.id = 1
    post2.title = "TEST UPDATE"
    post2.author = "netkit"
    ServiceController.updatePost(post2)
    
    ServiceController.getPosts()
    
    // This will finish after weather call below because they are both in the same serial queue, but this is executed by resume() which returns before the call is finalized.
    ServiceController.getComments()
    
    ServiceController.getCities("Turkey")
    
    // Experiment changing downloadQueue from serial to concurrent, or use resume() instead of resumeAndWait(), or use dispatch_async instead of dispatch_sync
    for _ in 1...10 {
      ServiceController.downloadFile("5MB.zip")
      ServiceController.downloadFile("20MB.zip")
      ServiceController.downloadFile("100MB.zip")
    }
    print("********* finished queueing *********")
  }
  
  func postsDownloaded(_ notification: Notification) {
    print("POSTS DOWNLOADED")
  }
  
  func postsCreated(_ notification: Notification) {
    print("POST CREATED")
  }
  
  func postsUpdated(_ notification: Notification) {
    print("POST UPDATED")
  }
  
  func commentsDownloaded(_ notification: Notification) {
    print("COMMENTS DOWNLOADED")
  }
  
  func receivedCities(_ notification: Notification) {
    print("RECEIVED CITIES")
  }
  
  func receivedWeather(_ notification: Notification) {
    print("RECEIVED WEATHER")
  }
  
  func fileDownloaded(_ notification: Notification) {
    if let userInfo = (notification as NSNotification).userInfo, let filename = userInfo[DownloadService.FileName] {
      print("FILE DOWNLOADED: \(filename)")
    } else {
      print("FILE DOWNLOADED")
    }
  }
}
