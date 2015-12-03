//
//  AppDelegate.swift
//  WineNotes
//
//  Created by Katie Willison on 11/19/15.
//  Copyright © 2015 Kate Willison. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var document: UIManagedDocument?
    var documentURL: NSURL?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Convenience caller for app delegate
    class var currentAppDelegate : AppDelegate? {
        return ((UIApplication.sharedApplication().delegate) as? AppDelegate)
    }
    
    // Convenience caller to return the document, doing so off of the main queue then excecuting the handler.
    func getContext(handler: ((NSManagedObjectContext, success : Bool) -> Void)){
        if document != nil && documentURL != nil {
            
            // If doc is open, excecute handler
            if document!.documentState == .Normal {
                handler(document!.managedObjectContext, success: true)
                
            } else if document!.documentState == .Closed {
                // Create and open document if it does not exist
                if let path = documentURL!.path where !NSFileManager.defaultManager().fileExistsAtPath(path){
                    document!.saveToURL(document!.fileURL, forSaveOperation: .ForCreating) { success in
                        self.document!.openWithCompletionHandler { (success: Bool) in handler(self.document!.managedObjectContext, success: success) }
                    }
                    
                    // Otherwise open document and execute handler
                } else {
                    document!.openWithCompletionHandler { (success: Bool) in handler(self.document!.managedObjectContext, success: success) }
                }
                
                // Pass success = false back to handler if some other state
            } else {
                handler(document!.managedObjectContext, success: false)
            }
        }
    }


}

